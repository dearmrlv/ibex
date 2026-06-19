#include "third_party/json.hpp"

#include "Array.h"
#include "Cell.h"
#include "Instance.h"
#include "Map.h"
#include "Message.h"
#include "Net.h"
#include "Netlist.h"
#include "PortRef.h"
#include "Set.h"
#include "Strings.h"
#include "VeriBaseValue_Stat.h"
#include "VeriExpression.h"
#include "VeriId.h"
#include "VeriModule.h"
#include "VeriModuleItem.h"
#include "veri_file.h"

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

#ifdef VERIFIC_NAMESPACE
using namespace Verific;
#endif
using json = nlohmann::json;
namespace fs = std::filesystem;

namespace {

struct ResolvedFiles {
  std::vector<std::string> sources;
  std::vector<std::string> incdirs;
  std::vector<std::string> defines;
};

std::vector<std::string> Split(const std::string& line) {
  std::istringstream stream(line);
  std::vector<std::string> out;
  std::string item;
  while (stream >> item) out.push_back(item);
  return out;
}

std::string StripComment(const std::string& line) {
  const size_t hash = line.find('#');
  size_t slash = std::string::npos;
  for (size_t pos = line.find("//"); pos != std::string::npos; pos = line.find("//", pos + 2)) {
    if (pos == 0 || std::isspace(static_cast<unsigned char>(line[pos - 1]))) {
      slash = pos;
      break;
    }
  }
  const size_t pos = std::min(hash == std::string::npos ? line.size() : hash,
                              slash == std::string::npos ? line.size() : slash);
  return line.substr(0, pos);
}

void AddUnique(std::vector<std::string>& out, const std::string& value) {
  if (!value.empty() && std::find(out.begin(), out.end(), value) == out.end()) out.push_back(value);
}

std::string ResolvePath(const fs::path& base, const std::string& value) {
  fs::path path(value);
  if (path.is_relative()) path = base / path;
  return fs::absolute(path).lexically_normal().string();
}

void ReadFilelist(const std::string& name, ResolvedFiles& out, std::set<std::string>& active) {
  const fs::path path = fs::absolute(name).lexically_normal();
  if (!active.insert(path.string()).second) throw std::runtime_error("recursive filelist: " + path.string());
  std::ifstream input(path);
  if (!input) throw std::runtime_error("cannot open filelist: " + path.string());
  std::string line;
  while (std::getline(input, line)) {
    auto tokens = Split(StripComment(line));
    for (size_t i = 0; i < tokens.size(); ++i) {
      const std::string& token = tokens[i];
      if (token.rfind("+incdir+", 0) == 0) {
        AddUnique(out.incdirs, ResolvePath(path.parent_path(), token.substr(8)));
      } else if (token.rfind("+define+", 0) == 0) {
        AddUnique(out.defines, token.substr(8));
      } else if ((token == "-f" || token == "-F") && i + 1 < tokens.size()) {
        ReadFilelist(ResolvePath(path.parent_path(), tokens[++i]), out, active);
      } else if (token == "-D" && i + 1 < tokens.size()) {
        AddUnique(out.defines, tokens[++i]);
      } else if (token.rfind("-D", 0) == 0 && token.size() > 2) {
        AddUnique(out.defines, token.substr(2));
      } else if (token.size() > 2 && (token.rfind(".sv") == token.size() - 3 ||
                                      token.rfind(".v") == token.size() - 2)) {
        AddUnique(out.sources, ResolvePath(path.parent_path(), token));
      }
    }
  }
  active.erase(path.string());
}

int ValidWidth(unsigned width) {
  return width > 0 && width < 0x7fffffffU ? static_cast<int>(width) : 0;
}

int WidthOfDataType(VeriDataType* type) {
  if (!type) return 0;
  if (int width = ValidWidth(type->Size(nullptr))) return width;
  if (int width = ValidWidth(type->BaseTypeSize())) return width;
  if (int width = ValidWidth(type->ElementSize())) return width;
  VeriRange* range = type->GetDimensionAt(0);
  if (range) {
    const int msb = range->GetMsbOfRange();
    const int lsb = range->GetLsbOfRange();
    if (msb != 0 || lsb != 0) return std::abs(msb - lsb) + 1;
  }
  return type->PackedDimension() == 0 ? 1 : 0;
}

int WidthOf(VeriIdDef* id) {
  if (!id) return 0;
  VeriDataType* type = id->GetDataType();
  if (type && type->IsEnumType()) {
    if (int width = WidthOfDataType(type)) return width;
  }
  int msb = 0, lsb = 0;
  const unsigned width = id->GetPackedWidth(&msb, &lsb);
  if (int valid_width = ValidWidth(width)) return valid_width;
  return id->PackedDimension() == 0 ? 1 : 0;
}

std::string Normalize(const char* raw) {
  if (!raw) return "";
  std::string value(raw);
  const size_t paren = value.find('(');
  if (paren != std::string::npos) value.resize(paren);
  if (!value.empty() && value.front() == '\\') value.erase(value.begin());
  while (!value.empty() && std::isspace(static_cast<unsigned char>(value.back()))) value.pop_back();
  return value;
}

VeriModule* ModuleFor(Netlist* netlist) {
  if (!netlist) return nullptr;
  std::string name;
  if (netlist->Owner() && netlist->Owner()->Name()) name = Normalize(netlist->Owner()->Name());
  if (name.empty() && netlist->Name()) name = Normalize(netlist->Name());
  return name.empty() ? nullptr : veri_file::GetModule(name.c_str(), 1, "work");
}

bool HasSequentialDriver(Net* net) {
  if (!net) return false;
  SetIter iterator;
  PortRef* ref = nullptr;
  FOREACH_PORTREF_OF_NET(net, iterator, ref) {
    if (!ref || (!ref->IsOutput() && !ref->IsInout())) continue;
    Instance* inst = ref->GetInst();
    if (inst && inst->IsRegister()) return true;
  }
  return false;
}

bool LooksLikeCurrentStateName(const std::string& name) {
  return name.size() > 2 &&
         (name.compare(name.size() - 2, 2, "_q") == 0 ||
          name.compare(name.size() - 3, 3, "_cs") == 0);
}

std::vector<json> EnumValues(VeriDataType* type, int width) {
  std::vector<json> out;
  Array* enums = type ? type->GetEnums() : nullptr;
  if (!enums || width <= 0 || width > 63) return out;
  unsigned index = 0;
  unsigned i = 0;
  VeriIdDef* id = nullptr;
  FOREACH_ARRAY_ITEM(enums, i, id) {
    long long value = index;
    if (id && id->GetInitialValue()) {
      VeriBaseValue* evaluated = id->GetInitialValue()->StaticEvaluate(width, nullptr);
      if (evaluated) {
        value = evaluated->GetIntegerValue();
        delete evaluated;
      }
    }
    const unsigned long long mask = width == 64 ? ~0ULL : ((1ULL << width) - 1ULL);
    const unsigned long long bits = static_cast<unsigned long long>(value) & mask;
    std::string binary(static_cast<size_t>(width), '0');
    for (int bit = 0; bit < width; ++bit) {
      if ((bits >> bit) & 1ULL) binary[static_cast<size_t>(width - 1 - bit)] = '1';
    }
    out.push_back({{"name", id && id->Name() ? id->Name() : ""},
                   {"value", bits}, {"literal", std::to_string(width) + "'b" + binary}});
    index = static_cast<unsigned>(bits + 1ULL);
  }
  return out;
}

void Collect(Netlist* netlist, Instance* parent, const std::string& hierarchy,
             std::vector<json>& signals, std::set<std::string>& visited) {
  if (!netlist) return;
  const std::string visit_key = hierarchy + "@" + std::to_string(reinterpret_cast<uintptr_t>(netlist));
  if (!visited.insert(visit_key).second) return;
  VeriModule* module = ModuleFor(netlist);
  const std::string module_name = module && module->GetId() && module->GetId()->Name()
                                      ? Normalize(module->GetId()->Name()) : Normalize(netlist->Name());

  MapIter iterator;
  Net* net = nullptr;
  std::set<std::string> emitted;
  FOREACH_NET_OF_NETLIST(netlist, iterator, net) {
    if (!net || !net->Name() || !module) continue;
    const std::string net_name = Normalize(net->Name());
    VeriIdDef* id = module->FindDeclared(net_name.c_str());
    if (!id) continue;
    const int width = WidthOf(id);
    VeriDataType* type = id->GetDataType();
    const bool is_enum = type && type->IsEnumType();
    std::string kind;
    std::vector<json> values;
    if (is_enum && (HasSequentialDriver(net) || LooksLikeCurrentStateName(net_name))) {
      kind = "FsmState";
      values = EnumValues(type, width);
      if (values.empty()) continue;
    } else if (width == 1 && !is_enum) {
      kind = "OneBit";
      values = {{{"name", "0"}, {"value", 0}, {"literal", "1'b0"}},
                {{"name", "1"}, {"value", 1}, {"literal", "1'b1"}}};
    } else {
      continue;
    }
    signals.push_back({{"name", net_name}, {"instance", hierarchy}, {"module", module_name},
                       {"width", width}, {"type", kind}, {"values", values}});
    emitted.insert(net_name);
  }

  Array* items = module ? module->GetModuleItems() : nullptr;
  if (items) {
    unsigned item_index = 0;
    VeriModuleItem* item = nullptr;
    FOREACH_ARRAY_ITEM(items, item_index, item) {
      Array* ids = item ? item->GetIds() : nullptr;
      if (!ids) continue;
      unsigned id_index = 0;
      VeriIdDef* id = nullptr;
      FOREACH_ARRAY_ITEM(ids, id_index, id) {
        if (!id || !id->Name()) continue;
        const std::string name = Normalize(id->Name());
        if (emitted.count(name)) continue;
        VeriDataType* type = id->GetDataType();
        if (!type || !type->IsEnumType() || !LooksLikeCurrentStateName(name)) continue;
        const int width = WidthOf(id);
        std::vector<json> values = EnumValues(type, width);
        if (values.empty()) continue;
        signals.push_back({{"name", name}, {"instance", hierarchy}, {"module", module_name},
                           {"width", width}, {"type", "FsmState"}, {"values", values}});
        emitted.insert(name);
      }
    }
  }

  Instance* inst = nullptr;
  FOREACH_INSTANCE_OF_NETLIST(netlist, iterator, inst) {
    if (!inst || !inst->View() || inst->IsPrimitive()) continue;
    const std::string child = hierarchy.empty() ? Normalize(inst->Name())
                                                 : hierarchy + "." + Normalize(inst->Name());
    Collect(inst->View(), inst, child, signals, visited);
  }
}

}  // namespace

int main(int argc, char** argv) {
  try {
    if (argc != 3 || std::string(argv[1]) != "--request") {
      std::cerr << "usage: bsdcov_sig_extract --request request.json\n";
      return 2;
    }
    std::ifstream stream(argv[2]);
    if (!stream) throw std::runtime_error("cannot open request JSON");
    json request = json::parse(stream);
    Message::SetConsoleOutput(0);
    ResolvedFiles files;
    std::set<std::string> active;
    for (const auto& item : request.at("filelists")) ReadFilelist(item.get<std::string>(), files, active);
    for (const auto& item : request.value("include_dirs", json::array())) AddUnique(files.incdirs, item.get<std::string>());
    for (const auto& item : request.value("defines", json::array())) AddUnique(files.defines, item.get<std::string>());

    veri_file::RemoveAllModules();
    Message::ClearErrorCount();
    for (const auto& dir : files.incdirs) veri_file::AddIncludeDir(dir.c_str());
    for (const auto& define : files.defines) {
      const size_t equals = define.find('=');
      if (equals == std::string::npos) veri_file::DefineCmdLineMacro(define.c_str());
      else veri_file::DefineCmdLineMacro(define.substr(0, equals).c_str(), define.substr(equals + 1).c_str());
    }
    Array sources(files.sources.size());
    for (const auto& source : files.sources) sources.Insert(source.c_str());
    if (!veri_file::AnalyzeMultipleFiles(&sources, veri_file::SYSTEM_VERILOG) || Message::ErrorCount()) {
      throw std::runtime_error("Verific RTL analysis failed");
    }
    Map* parameters = nullptr;
    if (request.contains("parameters") && !request["parameters"].empty()) {
      parameters = new Map(STRING_HASH);
      for (auto it = request["parameters"].begin(); it != request["parameters"].end(); ++it) {
        const std::string value = it.value().is_string() ? it.value().get<std::string>() : it.value().dump();
        parameters->Insert(Strings::save(it.key().c_str()), Strings::save(value.c_str()));
      }
    }
    const std::string top = request.at("top").get<std::string>();
    if (!veri_file::Elaborate(top.c_str(), "work", parameters) || Message::ErrorCount()) {
      throw std::runtime_error("Verific elaboration failed for top " + top);
    }
    Netlist* root = Netlist::PresentDesign();
    if (!root) throw std::runtime_error("Verific did not produce an elaborated netlist");
    std::vector<json> signals;
    std::set<std::string> visited;
    Collect(root, nullptr, top, signals, visited);
    std::sort(signals.begin(), signals.end(), [](const json& a, const json& b) {
      return a.at("instance").get<std::string>() + "." + a.at("name").get<std::string>() <
             b.at("instance").get<std::string>() + "." + b.at("name").get<std::string>();
    });
    std::cout << json({{"status", "success"}, {"top", top}, {"signals", signals}}).dump(2) << '\n';
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "bsdcov_sig_extract: " << error.what() << '\n';
    return 1;
  }
}

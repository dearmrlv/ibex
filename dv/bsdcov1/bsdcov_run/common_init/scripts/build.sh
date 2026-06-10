#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_INIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IBEX_ROOT="$(cd "$COMMON_INIT_DIR/../../../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
CPU_INIT_BIN="$IBEX_ROOT/dv/bsdcov1/cpu_init/build/init_only.bin"
BUILD_DIR="$COMMON_INIT_DIR/build"

pushd "$CORE_IBEX_DIR" >/dev/null
# shellcheck disable=SC1091
source ./setup_env.sh
popd >/dev/null

mkdir -p "$BUILD_DIR"

"$RISCV_GCC" \
  -march=rv32imc -mabi=ilp32 -mcmodel=medany \
  -nostdlib -nostartfiles -static \
  -Wl,--build-id=none \
  -Wl,-Map,"$BUILD_DIR/common_init.map" \
  -T "$COMMON_INIT_DIR/src/link.ld" \
  -o "$BUILD_DIR/common_init.elf" \
  "$COMMON_INIT_DIR/src/common_init.S"

"$RISCV_OBJCOPY" -O binary "$BUILD_DIR/common_init.elf" "$BUILD_DIR/common_init.bin"
"$RISCV_OBJDUMP" -d -S "$BUILD_DIR/common_init.elf" > "$BUILD_DIR/common_init.dump"
"$RISCV_READELF" -h -S -s "$BUILD_DIR/common_init.elf" > "$BUILD_DIR/common_init.readelf"

entry="$($RISCV_READELF -h "$BUILD_DIR/common_init.elf" | awk '/Entry point address:/ {print $4}')"
size="$(stat -c %s "$BUILD_DIR/common_init.bin")"
[[ "$entry" == "0x80000080" ]] || { echo "ERROR: unexpected ELF entry: $entry" >&2; exit 1; }
[[ "$size" == "288" ]] || { echo "ERROR: common_init.bin is $size bytes, expected 288" >&2; exit 1; }

if [[ ! -s "$CPU_INIT_BIN" ]]; then
  "$IBEX_ROOT/dv/bsdcov1/cpu_init/scripts/build.sh"
fi
cmp -n 288 "$BUILD_DIR/common_init.bin" "$CPU_INIT_BIN"

echo "Built $BUILD_DIR/common_init.bin"
echo "ELF entry: $entry"
echo "Verified byte-identical cpu_init prefix through 0x8000011c"

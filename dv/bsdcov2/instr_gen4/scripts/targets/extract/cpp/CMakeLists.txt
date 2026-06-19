cmake_minimum_required(VERSION 3.16)
project(bsdcov_sig_extract LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

get_filename_component(BSDCOV_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../../../../../../../.." ABSOLUTE)

add_executable(bsdcov_sig_extract sig_extract.cpp)
target_include_directories(bsdcov_sig_extract PRIVATE
  "${BSDCOV_ROOT}/src/tools/verific_conegen"
  "${BSDCOV_ROOT}/src/tools/verific_conegen/third_party"
)

add_subdirectory("${BSDCOV_ROOT}/thirdparty/verific" "${CMAKE_BINARY_DIR}/verific")
target_link_libraries(bsdcov_sig_extract PRIVATE verific)

set (IWASM_FAST_JIT_DIR ${CMAKE_CURRENT_LIST_DIR})
add_definitions(-DWASM_ENABLE_FAST_JIT=1)
if (WAMR_BUILD_FAST_JIT_DUMP EQUAL 1)
    add_definitions(-DWASM_ENABLE_FAST_JIT_DUMP=1)
endif ()

include_directories (${IWASM_FAST_JIT_DIR})
enable_language(CXX)

if (WAMR_BUILD_TARGET STREQUAL "X86_64" OR WAMR_BUILD_TARGET STREQUAL "AMD_64")
    find_package(asmjit REQUIRED)
    # include_directories(${asmjit_INCLUDE_DIRECTORIES})
    # link_directories(${asmjit_LIBRARY_DIRECTORIES})
    link_libraries(asmjit)
    if (WAMR_BUILD_FAST_JIT_DUMP EQUAL 1)
        find_package(zycore REQUIRED)
        include_directories(${zycore_INCLUDE_DIRECTORIES})
        find_package(zydis REQUIRED)
        include_directories(${zydis_INCLUDE_DIRECTORIES})
    endif ()
endif ()

file (GLOB c_source_jit ${IWASM_FAST_JIT_DIR}/*.c ${IWASM_FAST_JIT_DIR}/fe/*.c)

if (WAMR_BUILD_TARGET STREQUAL "X86_64" OR WAMR_BUILD_TARGET STREQUAL "AMD_64")
  file (GLOB_RECURSE cpp_source_jit_cg ${IWASM_FAST_JIT_DIR}/cg/x86-64/*.cpp)
else ()
  message (FATAL_ERROR "Fast JIT codegen for target ${WAMR_BUILD_TARGET} isn't implemented")
endif ()

set (IWASM_FAST_JIT_SOURCE ${c_source_jit} ${cpp_source_jit_cg}
                           ${cpp_source_asmjit} ${c_source_zycore} ${c_source_zydis})


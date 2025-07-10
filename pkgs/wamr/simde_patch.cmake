include(FindPkgConfig)
pkg_check_modules(simde REQUIRED)
add_definitions (-DWASM_ENABLE_SIMDE=1)
# include_directories(${simde_INCLUDE_DIRECTORIES})

# include(FetchContent)

# FetchContent_Declare(
#     simde
#     GIT_REPOSITORY  https://github.com/simd-everywhere/simde
#     GIT_TAG v0.8.2
# )

# message("-- Fetching simde ..")
# FetchContent_MakeAvailable(simde)
# include_directories("${simde_SOURCE_DIR}")


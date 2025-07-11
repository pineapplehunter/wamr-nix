cmake_minimum_required(VERSION 3.31)
project(main C)

find_package(iwasm REQUIRED COMPONENTS vmlib GLOBAL)

add_executable(main main.c)
target_link_directories(main PUBLIC ${iwasm_LINK_DRICTORIES})
target_link_libraries(main iwasm)

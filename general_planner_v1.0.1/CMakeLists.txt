cmake_minimum_required(VERSION 3.19)
project(general_planner)

set(CMAKE_CXX_STANDARD 14)

find_package( Boost REQUIRED COMPONENTS program_options system filesystem)
include_directories( ${Boost_INCLUDE_DIRS} )

add_executable(general_planner main.cpp CBSNode.h ANode.h conflict.cpp conflict.h instance.cpp instance.h CBS.cpp CBS.h common.h)
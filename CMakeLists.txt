cmake_minimum_required(VERSION 3.20)

project(PWMCilver VERSION 0.1)

message(STATUS "Project version: ${PROJECT_VERSION}")

add_definitions(-DPROJECT_VERSION="${PROJECT_VERSION}")

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

add_subdirectory(FluentUI)
add_subdirectory(src)

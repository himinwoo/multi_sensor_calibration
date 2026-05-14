cmake_minimum_required(VERSION 2.8.3)
project(common)

find_package(catkin REQUIRED COMPONENTS)
find_package(Eigen3 REQUIRED)

catkin_package(INCLUDE_DIRS
    include
    DEPENDS EIGEN3
    LIBRARIES ${PROJECT_NAME}
)
include_directories(
    include/${PROJECT_NAME}
    ${EIGEN3_INCLUDE_DIRS}
 )

add_library(${PROJECT_NAME} src/robust_least_squares.cpp)
target_link_libraries(${PROJECT_NAME}  ${catkin_LIBRARIES})

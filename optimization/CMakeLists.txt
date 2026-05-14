cmake_minimum_required(VERSION 2.8.3)
project(optimization)

find_package(catkin REQUIRED COMPONENTS message_generation rospy std_msgs accumulator)
catkin_package()
catkin_python_setup()

catkin_install_python(PROGRAMS src/server.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})

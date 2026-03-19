cmake_minimum_required(VERSION 3.5)
project(std_msgs)
set(CMAKE_VERBOSE_MAKEFILE ON)
# Set CMAKE_BUILD_TYPE
set(CMAKE_BUILD_TYPE Release)
# Default to C99
if(NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 99)
endif()
# Default to C++17
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()
if(ALIAS_ROS2_TF2)
  add_definitions(-Dtf2=ros2_tf2)
  add_definitions(-Dtf2_ros=ros2_tf2_ros)
  add_definitions(-Dmessage_filters=ros2_message_filters)
endif()
# find dependencies
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_ros REQUIRED)
find_package(rosidl_typesupport_c REQUIRED)
find_package(rosidl_typesupport_cpp REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package( builtin_interfaces REQUIRED)
find_package( class_loader REQUIRED)
find_package( console_bridge REQUIRED)
find_package( rclcpp REQUIRED)
find_package( rcutils REQUIRED)
include_directories("/usr/local/MATLAB/R2024b/extern/include")
include_directories("/usr/local/MATLAB/R2024b/extern/include/MatlabDataArray")
include_directories("/usr/local/MATLAB/R2024b/toolbox/ros/include/ros2")
include_directories("include/std_msgs")
set (CMAKE_SKIP_BUILD_RPATH false)
set (CMAKE_BUILD_WITH_INSTALL_RPATH true)
set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(msg_files
  "msg/Bool.msg"
  "msg/Byte.msg"
  "msg/ByteMultiArray.msg"
  "msg/Char.msg"
  "msg/ColorRGBA.msg"
  "msg/Empty.msg"
  "msg/Float32.msg"
  "msg/Float32MultiArray.msg"
  "msg/Float64.msg"
  "msg/Float64MultiArray.msg"
  "msg/Header.msg"
  "msg/Int16.msg"
  "msg/Int16MultiArray.msg"
  "msg/Int32.msg"
  "msg/Int32MultiArray.msg"
  "msg/Int64.msg"
  "msg/Int64MultiArray.msg"
  "msg/Int8.msg"
  "msg/Int8MultiArray.msg"
  "msg/MultiArrayDimension.msg"
  "msg/MultiArrayLayout.msg"
  "msg/String.msg"
  "msg/UInt16.msg"
  "msg/UInt16MultiArray.msg"
  "msg/UInt32.msg"
  "msg/UInt32MultiArray.msg"
  "msg/UInt64.msg"
  "msg/UInt64MultiArray.msg"
  "msg/UInt8.msg"
  "msg/UInt8MultiArray.msg"
)
set(srv_files
)
set(action_files
)
rosidl_generate_interfaces(${PROJECT_NAME}
  ${msg_files}
  ${srv_files}
  ${action_files}
  DEPENDENCIES 
  builtin_interfaces
)
link_directories("/usr/local/MATLAB/R2024b/extern/bin/glnxa64")
# Library
add_library(
    std_msgs_matlab 
    SHARED
    src/std_msgs_Bool_message.cpp
    src/std_msgs_Byte_message.cpp
    src/std_msgs_ByteMultiArray_message.cpp
    src/std_msgs_Char_message.cpp
    src/std_msgs_ColorRGBA_message.cpp
    src/std_msgs_Empty_message.cpp
    src/std_msgs_Float32_message.cpp
    src/std_msgs_Float32MultiArray_message.cpp
    src/std_msgs_Float64_message.cpp
    src/std_msgs_Float64MultiArray_message.cpp
    src/std_msgs_Header_message.cpp
    src/std_msgs_Int16_message.cpp
    src/std_msgs_Int16MultiArray_message.cpp
    src/std_msgs_Int32_message.cpp
    src/std_msgs_Int32MultiArray_message.cpp
    src/std_msgs_Int64_message.cpp
    src/std_msgs_Int64MultiArray_message.cpp
    src/std_msgs_Int8_message.cpp
    src/std_msgs_Int8MultiArray_message.cpp
    src/std_msgs_MultiArrayDimension_message.cpp
    src/std_msgs_MultiArrayLayout_message.cpp
    src/std_msgs_String_message.cpp
    src/std_msgs_UInt16_message.cpp
    src/std_msgs_UInt16MultiArray_message.cpp
    src/std_msgs_UInt32_message.cpp
    src/std_msgs_UInt32MultiArray_message.cpp
    src/std_msgs_UInt64_message.cpp
    src/std_msgs_UInt64MultiArray_message.cpp
    src/std_msgs_UInt8_message.cpp
    src/std_msgs_UInt8MultiArray_message.cpp
)
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
target_compile_options(std_msgs_matlab PUBLIC 
  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:
  -Wall -Wextra -Wpedantic
  >)
endif()
target_include_directories(std_msgs_matlab PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)
target_link_libraries( std_msgs_matlab
	"/usr/local/MATLAB/R2024b/sys/os/glnxa64/orig/libstdc++.so.6"
	"/usr/local/MATLAB/R2024b/extern/bin/glnxa64/libMatlabDataArray.so"
	${CMAKE_DL_LIBS}
	)
ament_target_dependencies(
  std_msgs_matlab
  "builtin_interfaces"
  "class_loader"
  "console_bridge"
  "rclcpp"
  "rcutils"
)
rosidl_get_typesupport_target(cpp_typesupport_target "${PROJECT_NAME}" "rosidl_typesupport_cpp")
target_link_libraries(std_msgs_matlab "${cpp_typesupport_target}")
# Causes the visibility macros to use dllexport rather than dllimport,
# which is appropriate when building the dll but not consuming it.
target_compile_definitions(std_msgs_matlab PRIVATE "STD_MSGS_BUILDING_LIBRARY")
install(
  DIRECTORY include/
  DESTINATION include
)
install(
  TARGETS std_msgs_matlab
  EXPORT export_${PROJECT_NAME}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)
install (DIRECTORY m/ DESTINATION m/ FILES_MATCHING PATTERN "*.m")
ament_export_include_directories(
  include
)
ament_export_libraries(
  std_msgs_matlab
)
foreach(file_i ${CUDA_BINS})
add_custom_command(
                   TARGET 
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND}
                   ARGS -E copy ${PROJECT_SOURCE_DIR}/src/${file_i} ${CMAKE_INSTALL_PREFIX}/_ert_rtw/${file_i}
				   )
add_custom_command(
                   TARGET 
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND}
                   ARGS -E copy ${PROJECT_SOURCE_DIR}/src/${file_i} ${CMAKE_INSTALL_PREFIX}/codegen/exe//${file_i}
				   )				   
endforeach(file_i)
ament_package()
# Generated on Thu Mar 19 16:18:12 2026

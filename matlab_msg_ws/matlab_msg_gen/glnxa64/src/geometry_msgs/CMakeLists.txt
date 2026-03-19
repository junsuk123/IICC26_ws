cmake_minimum_required(VERSION 3.5)
project(geometry_msgs)
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
find_package( class_loader REQUIRED)
find_package( console_bridge REQUIRED)
find_package( rclcpp REQUIRED)
find_package( rcutils REQUIRED)
find_package( std_msgs REQUIRED)
include_directories("/usr/local/MATLAB/R2024b/extern/include")
include_directories("/usr/local/MATLAB/R2024b/extern/include/MatlabDataArray")
include_directories("/usr/local/MATLAB/R2024b/toolbox/ros/include/ros2")
include_directories("include/geometry_msgs")
set (CMAKE_SKIP_BUILD_RPATH false)
set (CMAKE_BUILD_WITH_INSTALL_RPATH true)
set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(msg_files
  "msg/Accel.msg"
  "msg/AccelStamped.msg"
  "msg/AccelWithCovariance.msg"
  "msg/AccelWithCovarianceStamped.msg"
  "msg/Inertia.msg"
  "msg/InertiaStamped.msg"
  "msg/Point.msg"
  "msg/Point32.msg"
  "msg/PointStamped.msg"
  "msg/Polygon.msg"
  "msg/PolygonInstance.msg"
  "msg/PolygonInstanceStamped.msg"
  "msg/PolygonStamped.msg"
  "msg/Pose.msg"
  "msg/Pose2D.msg"
  "msg/PoseArray.msg"
  "msg/PoseStamped.msg"
  "msg/PoseWithCovariance.msg"
  "msg/PoseWithCovarianceStamped.msg"
  "msg/Quaternion.msg"
  "msg/QuaternionStamped.msg"
  "msg/Transform.msg"
  "msg/TransformStamped.msg"
  "msg/Twist.msg"
  "msg/TwistStamped.msg"
  "msg/TwistWithCovariance.msg"
  "msg/TwistWithCovarianceStamped.msg"
  "msg/Vector3.msg"
  "msg/Vector3Stamped.msg"
  "msg/VelocityStamped.msg"
  "msg/Wrench.msg"
  "msg/WrenchStamped.msg"
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
  std_msgs
)
link_directories("/usr/local/MATLAB/R2024b/extern/bin/glnxa64")
# Library
add_library(
    geometry_msgs_matlab 
    SHARED
    src/geometry_msgs_Accel_message.cpp
    src/geometry_msgs_AccelStamped_message.cpp
    src/geometry_msgs_AccelWithCovariance_message.cpp
    src/geometry_msgs_AccelWithCovarianceStamped_message.cpp
    src/geometry_msgs_Inertia_message.cpp
    src/geometry_msgs_InertiaStamped_message.cpp
    src/geometry_msgs_Point_message.cpp
    src/geometry_msgs_Point32_message.cpp
    src/geometry_msgs_PointStamped_message.cpp
    src/geometry_msgs_Polygon_message.cpp
    src/geometry_msgs_PolygonInstance_message.cpp
    src/geometry_msgs_PolygonInstanceStamped_message.cpp
    src/geometry_msgs_PolygonStamped_message.cpp
    src/geometry_msgs_Pose_message.cpp
    src/geometry_msgs_Pose2D_message.cpp
    src/geometry_msgs_PoseArray_message.cpp
    src/geometry_msgs_PoseStamped_message.cpp
    src/geometry_msgs_PoseWithCovariance_message.cpp
    src/geometry_msgs_PoseWithCovarianceStamped_message.cpp
    src/geometry_msgs_Quaternion_message.cpp
    src/geometry_msgs_QuaternionStamped_message.cpp
    src/geometry_msgs_Transform_message.cpp
    src/geometry_msgs_TransformStamped_message.cpp
    src/geometry_msgs_Twist_message.cpp
    src/geometry_msgs_TwistStamped_message.cpp
    src/geometry_msgs_TwistWithCovariance_message.cpp
    src/geometry_msgs_TwistWithCovarianceStamped_message.cpp
    src/geometry_msgs_Vector3_message.cpp
    src/geometry_msgs_Vector3Stamped_message.cpp
    src/geometry_msgs_VelocityStamped_message.cpp
    src/geometry_msgs_Wrench_message.cpp
    src/geometry_msgs_WrenchStamped_message.cpp
)
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
target_compile_options(geometry_msgs_matlab PUBLIC 
  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:
  -Wall -Wextra -Wpedantic
  >)
endif()
target_include_directories(geometry_msgs_matlab PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)
target_link_libraries( geometry_msgs_matlab
	"/usr/local/MATLAB/R2024b/sys/os/glnxa64/orig/libstdc++.so.6"
	"/usr/local/MATLAB/R2024b/extern/bin/glnxa64/libMatlabDataArray.so"
	${CMAKE_DL_LIBS}
	)
ament_target_dependencies(
  geometry_msgs_matlab
  "class_loader"
  "console_bridge"
  "rclcpp"
  "rcutils"
  "std_msgs"
)
rosidl_get_typesupport_target(cpp_typesupport_target "${PROJECT_NAME}" "rosidl_typesupport_cpp")
target_link_libraries(geometry_msgs_matlab "${cpp_typesupport_target}")
# Causes the visibility macros to use dllexport rather than dllimport,
# which is appropriate when building the dll but not consuming it.
target_compile_definitions(geometry_msgs_matlab PRIVATE "GEOMETRY_MSGS_BUILDING_LIBRARY")
install(
  DIRECTORY include/
  DESTINATION include
)
install(
  TARGETS geometry_msgs_matlab
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
  geometry_msgs_matlab
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
# Generated on Thu Mar 19 16:18:11 2026

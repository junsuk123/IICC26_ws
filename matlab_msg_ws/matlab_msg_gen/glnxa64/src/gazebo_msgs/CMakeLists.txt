cmake_minimum_required(VERSION 3.5)
project(gazebo_msgs)
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
find_package( geometry_msgs REQUIRED)
find_package( rclcpp REQUIRED)
find_package( rcutils REQUIRED)
find_package( std_msgs REQUIRED)
find_package( trajectory_msgs REQUIRED)
include_directories("/usr/local/MATLAB/R2024b/extern/include")
include_directories("/usr/local/MATLAB/R2024b/extern/include/MatlabDataArray")
include_directories("/usr/local/MATLAB/R2024b/toolbox/ros/include/ros2")
include_directories("include/gazebo_msgs")
set (CMAKE_SKIP_BUILD_RPATH false)
set (CMAKE_BUILD_WITH_INSTALL_RPATH true)
set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(msg_files
  "msg/ContactState.msg"
  "msg/ContactsState.msg"
  "msg/EntityState.msg"
  "msg/LinkState.msg"
  "msg/LinkStates.msg"
  "msg/ModelState.msg"
  "msg/ModelStates.msg"
  "msg/ODEJointProperties.msg"
  "msg/ODEPhysics.msg"
  "msg/PerformanceMetrics.msg"
  "msg/SensorPerformanceMetric.msg"
  "msg/WheelSlip.msg"
  "msg/WorldState.msg"
)
set(srv_files
  "srv/ApplyBodyWrench.srv"
  "srv/ApplyJointEffort.srv"
  "srv/ApplyLinkWrench.srv"
  "srv/BodyRequest.srv"
  "srv/DeleteEntity.srv"
  "srv/DeleteLight.srv"
  "srv/DeleteModel.srv"
  "srv/GetEntityState.srv"
  "srv/GetJointProperties.srv"
  "srv/GetLightProperties.srv"
  "srv/GetLinkProperties.srv"
  "srv/GetLinkState.srv"
  "srv/GetModelList.srv"
  "srv/GetModelProperties.srv"
  "srv/GetModelState.srv"
  "srv/GetPhysicsProperties.srv"
  "srv/GetWorldProperties.srv"
  "srv/JointRequest.srv"
  "srv/LinkRequest.srv"
  "srv/SetEntityState.srv"
  "srv/SetJointProperties.srv"
  "srv/SetJointTrajectory.srv"
  "srv/SetLightProperties.srv"
  "srv/SetLinkProperties.srv"
  "srv/SetLinkState.srv"
  "srv/SetModelConfiguration.srv"
  "srv/SetModelState.srv"
  "srv/SetPhysicsProperties.srv"
  "srv/SpawnEntity.srv"
  "srv/SpawnModel.srv"
)
set(action_files
)
rosidl_generate_interfaces(${PROJECT_NAME}
  ${msg_files}
  ${srv_files}
  ${action_files}
  DEPENDENCIES 
  builtin_interfaces
  geometry_msgs
  std_msgs
  trajectory_msgs
)
link_directories("/usr/local/MATLAB/R2024b/extern/bin/glnxa64")
# Library
add_library(
    gazebo_msgs_matlab 
    SHARED
    src/gazebo_msgs_ContactState_message.cpp
    src/gazebo_msgs_ContactsState_message.cpp
    src/gazebo_msgs_EntityState_message.cpp
    src/gazebo_msgs_LinkState_message.cpp
    src/gazebo_msgs_LinkStates_message.cpp
    src/gazebo_msgs_ModelState_message.cpp
    src/gazebo_msgs_ModelStates_message.cpp
    src/gazebo_msgs_ODEJointProperties_message.cpp
    src/gazebo_msgs_ODEPhysics_message.cpp
    src/gazebo_msgs_PerformanceMetrics_message.cpp
    src/gazebo_msgs_SensorPerformanceMetric_message.cpp
    src/gazebo_msgs_WheelSlip_message.cpp
    src/gazebo_msgs_WorldState_message.cpp
    src/gazebo_msgs_ApplyBodyWrench_service.cpp
    src/gazebo_msgs_ApplyJointEffort_service.cpp
    src/gazebo_msgs_ApplyLinkWrench_service.cpp
    src/gazebo_msgs_BodyRequest_service.cpp
    src/gazebo_msgs_DeleteEntity_service.cpp
    src/gazebo_msgs_DeleteLight_service.cpp
    src/gazebo_msgs_DeleteModel_service.cpp
    src/gazebo_msgs_GetEntityState_service.cpp
    src/gazebo_msgs_GetJointProperties_service.cpp
    src/gazebo_msgs_GetLightProperties_service.cpp
    src/gazebo_msgs_GetLinkProperties_service.cpp
    src/gazebo_msgs_GetLinkState_service.cpp
    src/gazebo_msgs_GetModelList_service.cpp
    src/gazebo_msgs_GetModelProperties_service.cpp
    src/gazebo_msgs_GetModelState_service.cpp
    src/gazebo_msgs_GetPhysicsProperties_service.cpp
    src/gazebo_msgs_GetWorldProperties_service.cpp
    src/gazebo_msgs_JointRequest_service.cpp
    src/gazebo_msgs_LinkRequest_service.cpp
    src/gazebo_msgs_SetEntityState_service.cpp
    src/gazebo_msgs_SetJointProperties_service.cpp
    src/gazebo_msgs_SetJointTrajectory_service.cpp
    src/gazebo_msgs_SetLightProperties_service.cpp
    src/gazebo_msgs_SetLinkProperties_service.cpp
    src/gazebo_msgs_SetLinkState_service.cpp
    src/gazebo_msgs_SetModelConfiguration_service.cpp
    src/gazebo_msgs_SetModelState_service.cpp
    src/gazebo_msgs_SetPhysicsProperties_service.cpp
    src/gazebo_msgs_SpawnEntity_service.cpp
    src/gazebo_msgs_SpawnModel_service.cpp
)
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
target_compile_options(gazebo_msgs_matlab PUBLIC 
  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:
  -Wall -Wextra -Wpedantic
  >)
endif()
target_include_directories(gazebo_msgs_matlab PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)
target_link_libraries( gazebo_msgs_matlab
	"/usr/local/MATLAB/R2024b/sys/os/glnxa64/orig/libstdc++.so.6"
	"/usr/local/MATLAB/R2024b/extern/bin/glnxa64/libMatlabDataArray.so"
	${CMAKE_DL_LIBS}
	)
ament_target_dependencies(
  gazebo_msgs_matlab
  "builtin_interfaces"
  "class_loader"
  "console_bridge"
  "geometry_msgs"
  "rclcpp"
  "rcutils"
  "std_msgs"
  "trajectory_msgs"
)
rosidl_get_typesupport_target(cpp_typesupport_target "${PROJECT_NAME}" "rosidl_typesupport_cpp")
target_link_libraries(gazebo_msgs_matlab "${cpp_typesupport_target}")
# Causes the visibility macros to use dllexport rather than dllimport,
# which is appropriate when building the dll but not consuming it.
target_compile_definitions(gazebo_msgs_matlab PRIVATE "GAZEBO_MSGS_BUILDING_LIBRARY")
install(
  DIRECTORY include/
  DESTINATION include
)
install(
  TARGETS gazebo_msgs_matlab
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
  gazebo_msgs_matlab
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
# Generated on Thu Mar 19 16:18:10 2026

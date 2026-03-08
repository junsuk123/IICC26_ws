# sjtu_drone_description

This package contains the xacro/urdf/sdf model description of the sjtu drone and the corresponding plugin for Gazebo 11 and ROS 2 Humble.


## Structure

* __models__: Gazebo sdf model and model meshes
* __include__: Header files for the PID controller and drone plugin
* __src__: Source code for the drone plugin and PID controller
* __urdf__: Xacro and urdf model description files
* __worlds__: Contains one playground world


## Worlds
To fully load the world you need to donwload the gazebo models first:
```

World files included in this workspace:
- `playground.world`
- `landingPad.world` (used by bringup default world argument)

If `landingPad.world` changes in source, rebuild this package so install-space launch can find it:

```bash
colcon build --packages-select sjtu_drone_description
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

## Wind Plugin Integration

This workspace includes a wind world plugin (`libwind_plugin.so`) that:
- subscribes to `/wind_command` (`std_msgs/msg/Float32MultiArray`, `[speed, direction_deg]`)
- publishes `/wind_condition` (`std_msgs/msg/Float32MultiArray`)
- supports service-based control via `/set_wind` (`sjtu_drone_interfaces/srv/SetWind`)

Quick test:

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [4.0, 45.0]" -1
ros2 topic echo /wind_condition --once
```

## AprilTag-Assisted Landing Pipeline

When bringup is launched with `use_apriltag:=true`, detector components run under camera namespace and a bridge node can publish:
- `/landing_tag_state` (`std_msgs/msg/Float32MultiArray`)

This bridge enables MATLAB landing logic without requiring MATLAB custom ROS2 message generation for `apriltag_msgs`.
curl -L https://github.com/osrf/gazebo_models/archive/refs/heads/master.zip -o /tmp/gazebo_models.zip \
    && unzip /tmp/gazebo_models.zip -d /tmp && mkdir -p ~/.gazebo/models/ && mv /tmp/gazebo_models-master/* ~/.gazebo/models/ \
    && rm -r /tmp/gazebo_models.zip
```

## TF Tree

![TF Tree](../imgs/tf_tree.png)

## Generate urdf and sdf files

To generate the urdf file run the following command:

```bash
ros2 run xacro xacro -o ./urdf/sjtu_drone.urdf ./urdf/sjtu_drone.urdf.xacro params_path:="$(ros2 pkg prefix sjtu_drone_bringup)/share/sjtu_drone_bringup/config/drone.yaml"  # Generate urdf file, you need to change the mesh path to the gazebo model
```

To generate the sdf file run the following command:
```bash
gz sdf -p ./urdf/sjtu_drone.urdf > ./models/sjtu_drone/model.sdf  # Generate sdf file, you need to change the mesh path to the gazebo model
```
function [data, info] = setModelConfigurationRequest
%SetModelConfiguration gives an empty data for gazebo_msgs/SetModelConfigurationRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/SetModelConfigurationRequest';
[data.model_name, info.model_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.urdf_param_name, info.urdf_param_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.joint_names, info.joint_names] = ros.internal.ros2.messages.ros2.char('string',NaN,NaN,0);
[data.joint_positions, info.joint_positions] = ros.internal.ros2.messages.ros2.default_type('double',NaN,0);
info.MessageType = 'gazebo_msgs/SetModelConfigurationRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,4);
info.MatPath{1} = 'model_name';
info.MatPath{2} = 'urdf_param_name';
info.MatPath{3} = 'joint_names';
info.MatPath{4} = 'joint_positions';

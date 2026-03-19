function [data, info] = applyJointEffortRequest
%ApplyJointEffort gives an empty data for gazebo_msgs/ApplyJointEffortRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/ApplyJointEffortRequest';
[data.joint_name, info.joint_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.effort, info.effort] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
[data.start_time, info.start_time] = ros.internal.ros2.messages.builtin_interfaces.time;
info.start_time.MLdataType = 'struct';
[data.duration, info.duration] = ros.internal.ros2.messages.builtin_interfaces.duration;
info.duration.MLdataType = 'struct';
info.MessageType = 'gazebo_msgs/ApplyJointEffortRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,8);
info.MatPath{1} = 'joint_name';
info.MatPath{2} = 'effort';
info.MatPath{3} = 'start_time';
info.MatPath{4} = 'start_time.sec';
info.MatPath{5} = 'start_time.nanosec';
info.MatPath{6} = 'duration';
info.MatPath{7} = 'duration.sec';
info.MatPath{8} = 'duration.nanosec';

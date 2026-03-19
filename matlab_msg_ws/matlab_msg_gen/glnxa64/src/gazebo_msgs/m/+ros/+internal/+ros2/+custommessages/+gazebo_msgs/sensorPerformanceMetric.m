function [data, info] = sensorPerformanceMetric
%SensorPerformanceMetric gives an empty data for gazebo_msgs/SensorPerformanceMetric
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/SensorPerformanceMetric';
[data.name, info.name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.sim_update_rate, info.sim_update_rate] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
[data.real_update_rate, info.real_update_rate] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
[data.fps, info.fps] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
info.MessageType = 'gazebo_msgs/SensorPerformanceMetric';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,4);
info.MatPath{1} = 'name';
info.MatPath{2} = 'sim_update_rate';
info.MatPath{3} = 'real_update_rate';
info.MatPath{4} = 'fps';

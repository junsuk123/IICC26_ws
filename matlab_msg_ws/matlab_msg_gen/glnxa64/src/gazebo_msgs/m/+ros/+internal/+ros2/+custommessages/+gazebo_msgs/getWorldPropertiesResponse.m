function [data, info] = getWorldPropertiesResponse
%GetWorldProperties gives an empty data for gazebo_msgs/GetWorldPropertiesResponse
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/GetWorldPropertiesResponse';
[data.sim_time, info.sim_time] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
[data.model_names, info.model_names] = ros.internal.ros2.messages.ros2.char('string',NaN,NaN,0);
[data.rendering_enabled, info.rendering_enabled] = ros.internal.ros2.messages.ros2.default_type('logical',1,0);
[data.success, info.success] = ros.internal.ros2.messages.ros2.default_type('logical',1,0);
[data.status_message, info.status_message] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
info.MessageType = 'gazebo_msgs/GetWorldPropertiesResponse';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,5);
info.MatPath{1} = 'sim_time';
info.MatPath{2} = 'model_names';
info.MatPath{3} = 'rendering_enabled';
info.MatPath{4} = 'success';
info.MatPath{5} = 'status_message';

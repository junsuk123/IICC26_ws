function [data, info] = getModelStateRequest
%GetModelState gives an empty data for gazebo_msgs/GetModelStateRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/GetModelStateRequest';
[data.model_name, info.model_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.relative_entity_name, info.relative_entity_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
info.MessageType = 'gazebo_msgs/GetModelStateRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,2);
info.MatPath{1} = 'model_name';
info.MatPath{2} = 'relative_entity_name';

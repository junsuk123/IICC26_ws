function [data, info] = deleteEntityRequest
%DeleteEntity gives an empty data for gazebo_msgs/DeleteEntityRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/DeleteEntityRequest';
[data.name, info.name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
info.MessageType = 'gazebo_msgs/DeleteEntityRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,1);
info.MatPath{1} = 'name';

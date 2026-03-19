function [data, info] = bodyRequestRequest
%BodyRequest gives an empty data for gazebo_msgs/BodyRequestRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/BodyRequestRequest';
[data.body_name, info.body_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
info.MessageType = 'gazebo_msgs/BodyRequestRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,1);
info.MatPath{1} = 'body_name';

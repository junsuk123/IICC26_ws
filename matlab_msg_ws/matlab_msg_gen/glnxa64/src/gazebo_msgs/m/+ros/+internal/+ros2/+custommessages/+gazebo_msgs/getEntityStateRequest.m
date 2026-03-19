function [data, info] = getEntityStateRequest
%GetEntityState gives an empty data for gazebo_msgs/GetEntityStateRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/GetEntityStateRequest';
[data.name, info.name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.reference_frame, info.reference_frame] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
info.MessageType = 'gazebo_msgs/GetEntityStateRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,2);
info.MatPath{1} = 'name';
info.MatPath{2} = 'reference_frame';

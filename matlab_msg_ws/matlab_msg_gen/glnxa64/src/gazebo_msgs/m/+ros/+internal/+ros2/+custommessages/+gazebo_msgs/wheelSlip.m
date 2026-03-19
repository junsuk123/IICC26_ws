function [data, info] = wheelSlip
%WheelSlip gives an empty data for gazebo_msgs/WheelSlip
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/WheelSlip';
[data.name, info.name] = ros.internal.ros2.messages.ros2.char('string',NaN,NaN,0);
[data.lateral_slip, info.lateral_slip] = ros.internal.ros2.messages.ros2.default_type('double',NaN,0);
[data.longitudinal_slip, info.longitudinal_slip] = ros.internal.ros2.messages.ros2.default_type('double',NaN,0);
info.MessageType = 'gazebo_msgs/WheelSlip';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,3);
info.MatPath{1} = 'name';
info.MatPath{2} = 'lateral_slip';
info.MatPath{3} = 'longitudinal_slip';

function [data, info] = setLightPropertiesRequest
%SetLightProperties gives an empty data for gazebo_msgs/SetLightPropertiesRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/SetLightPropertiesRequest';
[data.light_name, info.light_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.diffuse, info.diffuse] = ros.internal.ros2.messages.std_msgs.colorRGBA;
info.diffuse.MLdataType = 'struct';
[data.attenuation_constant, info.attenuation_constant] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
[data.attenuation_linear, info.attenuation_linear] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
[data.attenuation_quadratic, info.attenuation_quadratic] = ros.internal.ros2.messages.ros2.default_type('double',1,0);
info.MessageType = 'gazebo_msgs/SetLightPropertiesRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,9);
info.MatPath{1} = 'light_name';
info.MatPath{2} = 'diffuse';
info.MatPath{3} = 'diffuse.r';
info.MatPath{4} = 'diffuse.g';
info.MatPath{5} = 'diffuse.b';
info.MatPath{6} = 'diffuse.a';
info.MatPath{7} = 'attenuation_constant';
info.MatPath{8} = 'attenuation_linear';
info.MatPath{9} = 'attenuation_quadratic';

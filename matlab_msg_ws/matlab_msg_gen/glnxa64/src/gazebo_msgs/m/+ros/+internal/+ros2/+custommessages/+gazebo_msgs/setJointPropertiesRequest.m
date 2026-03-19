function [data, info] = setJointPropertiesRequest
%SetJointProperties gives an empty data for gazebo_msgs/SetJointPropertiesRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/SetJointPropertiesRequest';
[data.joint_name, info.joint_name] = ros.internal.ros2.messages.ros2.char('string',1,NaN,0);
[data.ode_joint_config, info.ode_joint_config] = ros.internal.ros2.custommessages.gazebo_msgs.oDEJointProperties;
info.ode_joint_config.MLdataType = 'struct';
info.MessageType = 'gazebo_msgs/SetJointPropertiesRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,12);
info.MatPath{1} = 'joint_name';
info.MatPath{2} = 'ode_joint_config';
info.MatPath{3} = 'ode_joint_config.damping';
info.MatPath{4} = 'ode_joint_config.hi_stop';
info.MatPath{5} = 'ode_joint_config.lo_stop';
info.MatPath{6} = 'ode_joint_config.erp';
info.MatPath{7} = 'ode_joint_config.cfm';
info.MatPath{8} = 'ode_joint_config.stop_erp';
info.MatPath{9} = 'ode_joint_config.stop_cfm';
info.MatPath{10} = 'ode_joint_config.fudge_factor';
info.MatPath{11} = 'ode_joint_config.fmax';
info.MatPath{12} = 'ode_joint_config.vel';

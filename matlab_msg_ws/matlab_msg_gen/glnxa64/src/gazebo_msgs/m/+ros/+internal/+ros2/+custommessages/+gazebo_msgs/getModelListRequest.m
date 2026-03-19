function [data, info] = getModelListRequest
%GetModelList gives an empty data for gazebo_msgs/GetModelListRequest
% Copyright 2019-2021 The MathWorks, Inc.
data = struct();
data.MessageType = 'gazebo_msgs/GetModelListRequest';
info.MessageType = 'gazebo_msgs/GetModelListRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,0);

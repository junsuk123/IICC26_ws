function rosCtx = autosimCreateRosContext(cfg)
    rosCtx = struct();

    nodeName = sprintf('/matlab_autosim_%s', autosimTimestamp());
    node = ros2node(nodeName);

    rosCtx.node = node;
    rosCtx.subState = ros2subscriber(node, cfg.topics.state, 'std_msgs/Int8');
    rosCtx.subPose = ros2subscriber(node, cfg.topics.pose, 'geometry_msgs/Pose');
    rosCtx.subVel = ros2subscriber(node, cfg.topics.vel, 'geometry_msgs/Twist');
    rosCtx.tag_callback_enabled = false;
    rosCtx.tag_cache_key = "";
    tagCallbackRequested = isfield(cfg, 'ros') && isfield(cfg.ros, 'prioritize_tag_callback') && cfg.ros.prioritize_tag_callback;
    if tagCallbackRequested
        tagCacheKey = regexprep(sprintf('autosim_tag_cache_%s', nodeName), '[^a-zA-Z0-9_]', '_');
        autosimInitTagStateCache(tagCacheKey);
        try
            rosCtx.subTag = ros2subscriber(node, cfg.topics.tag_state, 'std_msgs/Float32MultiArray', ...
                @(varargin) autosimTagStateCallback(tagCacheKey, varargin{:}));
            rosCtx.tag_callback_enabled = true;
            rosCtx.tag_cache_key = string(tagCacheKey);
            fprintf('[AUTOSIM] AprilTag callback-priority subscriber enabled on %s\n', cfg.topics.tag_state);
        catch ME
            autosimClearTagStateCache(tagCacheKey);
            rosCtx.subTag = ros2subscriber(node, cfg.topics.tag_state, 'std_msgs/Float32MultiArray');
            warning('[AUTOSIM] AprilTag callback mode unavailable; fallback to polling: %s', ME.message);
        end
    else
        rosCtx.subTag = ros2subscriber(node, cfg.topics.tag_state, 'std_msgs/Float32MultiArray');
    end
    rosCtx.subWind = ros2subscriber(node, cfg.topics.wind_condition, 'std_msgs/Float32MultiArray');

    rosCtx.subImu = [];
    if isfield(cfg, 'ros') && isfield(cfg.ros, 'enable_imu_subscription') && cfg.ros.enable_imu_subscription
        try
            rosCtx.subImu = ros2subscriber(node, cfg.topics.imu, 'sensor_msgs/msg/Imu');
        catch
            rosCtx.subImu = [];
        end
    end

    rosCtx.subBumpers = [];
    rosCtx.bumper_msg_type = "";
    rosCtx.bumper_msg_unsupported = false;
    if isfield(cfg, 'ros') && isfield(cfg.ros, 'enable_bumper_subscription') && cfg.ros.enable_bumper_subscription
        [rosCtx.subBumpers, rosCtx.bumper_msg_type, bumperDiag] = autosimCreateBumperSubscriber(node, cfg, false);
        if isstruct(bumperDiag) && isfield(bumperDiag, 'msg_unsupported')
            rosCtx.bumper_msg_unsupported = logical(bumperDiag.msg_unsupported);
        end
    end

    rosCtx.pubWind = ros2publisher(node, cfg.topics.wind_command, 'std_msgs/Float32MultiArray');
    rosCtx.pubTakeoff = ros2publisher(node, cfg.topics.takeoff_cmd, 'std_msgs/Empty');
    rosCtx.pubLand = ros2publisher(node, cfg.topics.land_cmd, 'std_msgs/Empty');
    rosCtx.pubReset = ros2publisher(node, cfg.topics.reset_cmd, 'std_msgs/Empty');
    rosCtx.pubCmd = ros2publisher(node, cfg.topics.cmd_vel, 'geometry_msgs/Twist');
    rosCtx.pubPosCtrl = ros2publisher(node, [char(string(cfg.runtime.drone_namespace)) '/posctrl'], 'std_msgs/Bool');
    rosCtx.pubTrajectoryGuidance = [];
    rosCtx.pubTrajectoryGuidanceMarker = [];
    if isfield(cfg, 'trajectory') && isfield(cfg.trajectory, 'guidance_topic_enable') && cfg.trajectory.guidance_topic_enable && ...
            isfield(cfg, 'topics') && isfield(cfg.topics, 'trajectory_guidance') && strlength(string(cfg.topics.trajectory_guidance)) > 0
        try
            rosCtx.pubTrajectoryGuidance = ros2publisher(node, cfg.topics.trajectory_guidance, 'std_msgs/Float32MultiArray');
            if isfield(cfg.topics, 'trajectory_guidance_marker') && strlength(string(cfg.topics.trajectory_guidance_marker)) > 0
                rosCtx.pubTrajectoryGuidanceMarker = ros2publisher(node, cfg.topics.trajectory_guidance_marker, 'visualization_msgs/Marker');
            end
        catch ME
            rosCtx.pubTrajectoryGuidance = [];
            rosCtx.pubTrajectoryGuidanceMarker = [];
            warning('[AUTOSIM ROS] Trajectory guidance publisher disabled: %s', ME.message);
        end
    end

    rosCtx.follower_namespaces = strings(0, 1);
    rosCtx.subTagFollowers = {};
    rosCtx.subStateFollowers = {};
    rosCtx.subPoseFollowers = {};
    rosCtx.pubTakeoffFollowers = {};
    rosCtx.pubLandFollowers = {};
    rosCtx.pubResetFollowers = {};
    rosCtx.pubCmdFollowers = {};
    rosCtx.pubPosCtrlFollowers = {};

    multiCount = 1;
    if isfield(cfg, 'runtime') && isfield(cfg.runtime, 'multi_drone_count')
        multiCount = max(1, round(double(cfg.runtime.multi_drone_count)));
    end

    if multiCount > 1
        nsPrefix = "drone_w";
        if isfield(cfg, 'runtime') && isfield(cfg.runtime, 'multi_drone_namespace_prefix')
            nsPrefix = string(cfg.runtime.multi_drone_namespace_prefix);
        end
        nsPrefix = regexprep(strtrim(nsPrefix), '^/+', '');
        if strlength(nsPrefix) == 0
            nsPrefix = "drone_w";
        end

        primaryNs = string(cfg.runtime.drone_namespace);
        allNs = strings(multiCount, 1);
        for i = 1:multiCount
            allNs(i) = sprintf('/%s%02d', char(nsPrefix), i);
        end
        followers = allNs(allNs ~= primaryNs);
        rosCtx.follower_namespaces = followers;
        
        fprintf('[AUTOSIM ROS] Multi-drone context: primary=%s | followers=[%s]\n', ...
            char(primaryNs), strjoin(followers, ', '));

        for i = 1:numel(followers)
            ns = char(followers(i));
            rosCtx.subTagFollowers{end+1, 1} = ros2subscriber(node, [ns '/landing_tag_state'], 'std_msgs/Float32MultiArray'); %#ok<AGROW>
            rosCtx.subStateFollowers{end+1, 1} = ros2subscriber(node, [ns '/state'], 'std_msgs/Int8'); %#ok<AGROW>
            rosCtx.subPoseFollowers{end+1, 1} = ros2subscriber(node, [ns '/gt_pose'], 'geometry_msgs/Pose'); %#ok<AGROW>
            rosCtx.pubTakeoffFollowers{end+1, 1} = ros2publisher(node, [ns '/takeoff'], 'std_msgs/Empty'); %#ok<AGROW>
            rosCtx.pubLandFollowers{end+1, 1} = ros2publisher(node, [ns '/land'], 'std_msgs/Empty'); %#ok<AGROW>
            rosCtx.pubResetFollowers{end+1, 1} = ros2publisher(node, [ns '/reset'], 'std_msgs/Empty'); %#ok<AGROW>
            rosCtx.pubCmdFollowers{end+1, 1} = ros2publisher(node, [ns '/cmd_vel'], 'geometry_msgs/Twist'); %#ok<AGROW>
            rosCtx.pubPosCtrlFollowers{end+1, 1} = ros2publisher(node, [ns '/posctrl'], 'std_msgs/Bool'); %#ok<AGROW>
        end
        fprintf('[AUTOSIM ROS] Created %d follower publishers\n', numel(followers));
    else
        fprintf('[AUTOSIM ROS] Single-drone mode: primary=%s | followers=none\n', char(string(cfg.runtime.drone_namespace)));
    end

    rosCtx.msgWind = ros2message(rosCtx.pubWind);
    rosCtx.msgTakeoff = ros2message(rosCtx.pubTakeoff);
    rosCtx.msgLand = ros2message(rosCtx.pubLand);
    rosCtx.msgReset = ros2message(rosCtx.pubReset);
    rosCtx.msgCmd = ros2message(rosCtx.pubCmd);
    rosCtx.msgPosCtrl = ros2message(rosCtx.pubPosCtrl);
    rosCtx.msgPosCtrl.data = true;
    rosCtx.msgTrajectoryGuidance = [];
    if ~isempty(rosCtx.pubTrajectoryGuidance)
        rosCtx.msgTrajectoryGuidance = ros2message(rosCtx.pubTrajectoryGuidance);
    end
    rosCtx.msgTrajectoryGuidanceMarker = [];
    if ~isempty(rosCtx.pubTrajectoryGuidanceMarker)
        rosCtx.msgTrajectoryGuidanceMarker = ros2message(rosCtx.pubTrajectoryGuidanceMarker);
    end
    rosCtx.cleanupHandles = {rosCtx.msgCmd, rosCtx.msgReset, rosCtx.msgLand, rosCtx.msgTakeoff, rosCtx.msgWind, ...
        rosCtx.msgPosCtrl, rosCtx.msgTrajectoryGuidance, rosCtx.msgTrajectoryGuidanceMarker, ...
        rosCtx.pubTrajectoryGuidance, rosCtx.pubTrajectoryGuidanceMarker, ...
        rosCtx.pubPosCtrlFollowers{:}, rosCtx.pubCmdFollowers{:}, rosCtx.pubResetFollowers{:}, rosCtx.pubLandFollowers{:}, rosCtx.pubTakeoffFollowers{:}, ...
        rosCtx.subPoseFollowers{:}, rosCtx.subStateFollowers{:}, rosCtx.subTagFollowers{:}, ...
        rosCtx.pubPosCtrl, rosCtx.pubCmd, rosCtx.pubReset, rosCtx.pubLand, rosCtx.pubTakeoff, rosCtx.pubWind, ...
        rosCtx.subBumpers, rosCtx.subImu, rosCtx.subWind, rosCtx.subTag, rosCtx.subVel, rosCtx.subPose, rosCtx.subState, rosCtx.node};
end



% landing_decision_matlab.m
% MATLAB script to run an ontology-based landing decision node for ROS2/Gazebo.
% Features:
% - Optional: start ROS2/Gazebo bringup launch (uses system call set in cfg.launchCMD)
% - Subscribes to /wind_condition (std_msgs/Float32MultiArray) and to drone gt_pose
% - Builds a minimal ontology (WindCondition, DroneState, LandingZone) as structs
% - Implements two simple decision methods: Decision Tree and Bayesian score
% - Publishes decision on /landing_decision (std_msgs/String) with values: "land","wait","caution"
%
% Usage:
% 1) Source ROS2 and workspace in shell or let this script launch it (see cfg.launchCMD)
% 2) From MATLAB: run this script. It will optionally start the launch and then run a loop.
%
% Notes: requires MATLAB ROS2 support (ros2node, ros2subscriber, ros2publisher, ros2message, receive/send)

clear; clc; close all;

% Ensure helper functions in this folder are resolvable regardless of current folder.
thisDir = fileparts(mfilename('fullpath'));
if ~isempty(thisDir)
    addpath(thisDir);
end

%% Configuration
cfg.use_launch = false; % if true the script will attempt to start the configured launch command
cfg.launchCMD = '';
% Example if you want MATLAB to start the ros2 launch (adjust paths):
% cfg.launchCMD = 'bash -lc "source /opt/ros/humble/setup.bash; source /home/user/INCSL/IICC26_ws/install/setup.bash; ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py use_gui:=false &"';

% Topics (tune if your namespace differs)
ns = '/drone'; % model namespace used by the bringup launch
topic_wind = '/wind_condition';                     % Float32MultiArray [speed, direction]
topic_pose = [ns '/gt_pose'];                       % geometry_msgs/Pose
topic_decision = '/landing_decision';               % std_msgs/String
topic_tags = [ns '/bottom/tags'];                   % apriltag_msgs/AprilTagDetectionArray
topic_tag_state = '/landing_tag_state';             % Float32MultiArray from apriltag_state_bridge

% Decision params
params.wind_speed_unsafe = 7.0;   % m/s above -> unsafe
params.wind_speed_caution = 4.0;  % m/s between caution and unsafe
params.max_attitude = deg2rad(10);% roll/pitch limit
params.max_vz_land = 0.5;         % vertical speed limit for safe landing
params.decision_rate = 2.0;       % Hz
params.tag_require_detection = true;
params.tag_target_id_enabled = true;
params.tag_target_id = 0;
params.tag_center_tolerance = 0.35; % normalized frame distance (0=center, 1=edge)
params.tag_jitter_warn_px = 8.0;    % caution threshold
params.tag_jitter_unsafe_px = 20.0; % wait threshold
params.tag_area_jitter_warn_ratio = 0.03; % std(area)/mean(area)
params.tag_area_jitter_unsafe_ratio = 0.08;
params.tag_min_area_px2 = 2000.0;   % too small means landing marker is far/uncertain
params.tag_margin_warn = 30.0;
params.tag_margin_unsafe = 15.0;
params.tag_stability_score_warn = 0.65;
params.tag_stability_score_land = 0.85;
params.tag_min_samples = 5;         % minimum samples before trusting jitter

% Camera image size for normalized tag center calculations
tag_cfg.image_width = 640;
tag_cfg.image_height = 480;
tag_cfg.history_len = 20;

% Wind publisher integration: if true, MATLAB will generate and publish wind to /wind_command
cfg.start_wind_publisher = true; % enable built-in wind generator
cfg.wind_pub_params = struct();   % see wind_publisher_matlab.startWindPublisher options (rate, steady_speed, etc.)
cfg.wind_pub_params.use_set_wind_service = false;   % publish /wind_command continuously
cfg.wind_pub_params.topic_publish_mode = 'matlab';  % 'matlab' publisher per tick, or 'cli'
% Optional topic fallback mode inside startWindPublisher:
% cfg.wind_pub_params.topic_publish_mode = 'cli';
% cfg.wind_pub_params.cli_setup_cmd = 'source /home/j/INCSL/IICC26_ws/install/setup.bash';
% When enabled and /set_wind service fails, MATLAB runs:
% ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [speed, direction]" -1

% Bayesian model params (simple Gaussian assumptions)
bayes.mu_safe = [0.0, 0.0];        % mean [wind_speed, attitude_score]
bayes.sigma_safe = [1.5, 0.5];     % std deviations
bayes.threshold = 0.5;             % probability threshold to consider safe

%% Launch if requested
if cfg.use_launch && ~isempty(cfg.launchCMD)
    fprintf('[MATLAB] Starting configured launch (background)...\n');
    [st,out] = system(cfg.launchCMD);
    if st ~= 0
        warning('Launch command returned non-zero: %s', out);
    else
        pause(2.0); % give launch a moment
    end
end

%% ROS2 node and pubs/subs
try
    node = ros2node('/matlab_landing_decision');
catch ME
    error('Failed to create ros2 node. Make sure ROS2 MATLAB support is installed and ROS2 env is sourced.\nError: %s', ME.message);
end

sub_wind = ros2subscriber(node, topic_wind, 'std_msgs/Float32MultiArray');
sub_pose = ros2subscriber(node, topic_pose, 'geometry_msgs/Pose');
pub_dec = ros2publisher(node, topic_decision, 'std_msgs/String');

% Optional AprilTag detection subscriber for landing zone reasoning.
sub_tags = [];
sub_tag_state = [];
try
    % Prefer canonical ROS2 type string first.
    sub_tags = ros2subscriber(node, topic_tags, 'apriltag_msgs/msg/AprilTagDetectionArray');
    fprintf('[MATLAB] AprilTag subscriber enabled on %s (type=apriltag_msgs/msg/AprilTagDetectionArray)\n', topic_tags);
catch ME
    try
        % Fallback for environments that accept legacy shorthand.
        sub_tags = ros2subscriber(node, topic_tags, 'apriltag_msgs/AprilTagDetectionArray');
        fprintf('[MATLAB] AprilTag subscriber enabled on %s (type=apriltag_msgs/AprilTagDetectionArray)\n', topic_tags);
    catch ME2
        fprintf('[MATLAB] AprilTag custom subscriber unavailable (%s | %s). Trying bridge topic %s.\n', ...
                ME.message, ME2.message, topic_tag_state);
        try
            sub_tag_state = ros2subscriber(node, topic_tag_state, 'std_msgs/Float32MultiArray');
            fprintf('[MATLAB] AprilTag bridge subscriber enabled on %s\n', topic_tag_state);
        catch ME3
            warning(['AprilTag bridge subscriber also disabled (%s). ', ...
                     'Tag-based landing stability will remain unavailable.'], ME3.message);
        end
    end
end

% Keep recent tag centers to estimate frame jitter.
tag_history = nan(tag_cfg.history_len, 2);
tag_hist_count = 0;
tag_area_history = nan(tag_cfg.history_len, 1);
tag_margin_history = nan(tag_cfg.history_len, 1);

% Optionally start the MATLAB wind publisher which will publish to /wind_command
windTimer = [];
if cfg.start_wind_publisher
    try
        % ensure wind_publisher_matlab is on path
        windTimer = startWindPublisher(cfg.wind_pub_params);
        % ensure cleanup on exit
        cleanupWind = onCleanup(@() safeStopWind(windTimer));
    catch ME
        warning('Failed to start MATLAB wind publisher: %s', ME.message);
    end
end

% Template message
msg_dec = ros2message(pub_dec);

fprintf('[MATLAB] Node ready. Subscribed to %s and %s. Publishing decisions to %s\n', topic_wind, topic_pose, topic_decision);

%% Minimal ontology constructors
makeWind = @(speed,dir) struct('wind_speed',double(speed),'wind_direction',double(dir));
makeDrone = @(pos,quat,vel,ang) struct('position',pos,'orientation',quat,'velocity',vel,'angular',ang);
makeLandingZone = @(area_size,obstacles) struct('landing_area_size',area_size,'obstacle_presence',obstacles);
makeTagObs = @(det,n,tid,u,v,jit,arj,area,margin,qok,stb,score,ctr) struct( ...
    'detected',det,'num_tags',n,'tag_id',tid,'u_norm',u,'v_norm',v, ...
    'jitter_px',jit,'area_jitter_ratio',arj,'area_px2',area, ...
    'margin',margin,'quality_ok',qok,'stable',stb,'stability_score',score,'centered',ctr);

% A simple landing zone (user may override)
landingZone = makeLandingZone([3.0,3.0], false);

%% Decision functions
function out = decision_tree(wind, drone, lz, tagObs, params)
    % returns 'land','wait' or 'caution'
    ws = wind.wind_speed;
    % small attitude proxy: estimate from orientation quaternion to roll/pitch
    q = drone.orientation; % quaternion w,x,y,z
    [roll,pitch,yaw] = quat2eul_local([q.w, q.x, q.y, q.z]);
    att = max(abs(roll), abs(pitch));
    vz = 0; if isfield(drone,'velocity') && ~isempty(drone.velocity), vz = drone.velocity(3); end
    if ws >= params.wind_speed_unsafe || att > params.max_attitude*1.5
        out = 'wait';
        return;
    end
    if ws >= params.wind_speed_caution || att > params.max_attitude
        out = 'caution';
        return;
    end
    if abs(vz) > params.max_vz_land
        out = 'caution';
        return;
    end

    % Tag-based landing-zone observability checks
    if params.tag_require_detection && ~tagObs.detected
        out = 'wait';
        return;
    end

    if tagObs.detected
        if ~tagObs.quality_ok
            if tagObs.margin < params.tag_margin_unsafe
                out = 'wait';
            else
                out = 'caution';
            end
            return;
        end

        if tagObs.area_px2 < params.tag_min_area_px2
            out = 'caution';
            return;
        end

        if ~tagObs.centered
            out = 'caution';
            return;
        end
        if tagObs.jitter_px >= params.tag_jitter_unsafe_px
            out = 'wait';
            return;
        end
        if ~tagObs.stable || tagObs.jitter_px >= params.tag_jitter_warn_px
            out = 'caution';
            return;
        end
        if tagObs.stability_score < params.tag_stability_score_warn
            out = 'caution';
            return;
        end
    end

    % landing area check (very simple): if obstacles present -> caution
    if lz.obstacle_presence
        out = 'caution';
        return;
    end
    out = 'land';
end

function p = bayesian_score(wind, drone, bayes)
    % Compute a toy probability that it's safe using wind_speed and an attitude score
    ws = wind.wind_speed;
    q = drone.orientation; [roll,pitch,~] = quat2eul_local([q.w, q.x, q.y, q.z]);
    att_score = max(abs(roll), abs(pitch));
    % Gaussian likelihoods (independent approx)
    lw = exp(-0.5*((ws - bayes.mu_safe(1))/bayes.sigma_safe(1))^2);
    la = exp(-0.5*((att_score - bayes.mu_safe(2))/bayes.sigma_safe(2))^2);
    % normalized-ish score
    p = (lw * la) / (1 + lw * la);
end

%% Helper: quaternion->euler
function [roll,pitch,yaw] = quat2eul_local(qwxyz)
    w = qwxyz(1); x = qwxyz(2); y = qwxyz(3); z = qwxyz(4);
    % roll
    sinr = 2*(w*x + y*z); cosr = 1 - 2*(x*x + y*y);
    roll = atan2(sinr, cosr);
    % pitch
    sinp = 2*(w*y - z*x);
    if abs(sinp) >= 1, pitch = sign(sinp)*pi/2; else pitch = asin(sinp); end
    % yaw
    siny = 2*(w*z + x*y); cosy = 1 - 2*(y*y + z*z);
    yaw = atan2(siny, cosy);
end

%% Main loop: poll topics and decide
dec_method = 'decision_tree'; % or 'bayesian'
rate = rateControl(params.decision_rate);

fprintf('[MATLAB] Entering decision loop (method=%s). Ctrl-C to stop.\n', dec_method);
while true
    % get latest wind
    wind_msg = tryReceive(sub_wind, 0.1);
    if isempty(wind_msg)
        wind = makeWind(0.0, 0.0);
    else
        % expect at least two values [speed, direction]
        dat = double(wind_msg.data);
        if numel(dat) < 2, dat = [dat(:); zeros(2-numel(dat),1)]; end
        wind = makeWind(dat(1), dat(2));
    end

    % get latest pose
    pose_msg = tryReceive(sub_pose, 0.01);
    if isempty(pose_msg)
        drone = makeDrone(struct('x',0,'y',0,'z',0), struct('w',1,'x',0,'y',0,'z',0), [0;0;0], [0;0;0]);
    else
        pos = [pose_msg.position.x; pose_msg.position.y; pose_msg.position.z];
        q = pose_msg.orientation; quat = struct('w',q.w,'x',q.x,'y',q.y,'z',q.z);
        % velocity not available from Pose message; set zero or extend to subscribe to twist
        vel = [0;0;0]; ang = [0;0;0];
        drone = makeDrone(pos, quat, vel, ang);
    end

    % get latest apriltag detections and derive frame-center + jitter features
    detected = false; n_tags = 0; tag_id = -1; cx_px = nan; cy_px = nan; area_px2 = nan; margin = nan;
    tag_msg = [];
    if ~isempty(sub_tags)
        tag_msg = tryReceive(sub_tags, 0.01);
    end

    if ~isempty(tag_msg)
        [detected, n_tags, tag_id, cx_px, cy_px, area_px2, margin] = extractTagFeatures(tag_msg, params.tag_target_id_enabled, params.tag_target_id);
    elseif ~isempty(sub_tag_state)
        bridge_msg = tryReceive(sub_tag_state, 0.01);
        [detected, n_tags, tag_id, cx_px, cy_px, area_px2, margin] = extractTagFeaturesFromBridge(bridge_msg);
    end
    if detected
        [tag_history, tag_hist_count] = pushTagCenter(tag_history, tag_hist_count, cx_px, cy_px);
        [tag_area_history, ~] = pushTagScalar(tag_area_history, area_px2);
        [tag_margin_history, ~] = pushTagScalar(tag_margin_history, margin);
    end

    [u_norm, v_norm, centered] = computeFrameCenterMetrics(cx_px, cy_px, tag_cfg.image_width, tag_cfg.image_height, params.tag_center_tolerance);
    jitter_px = computeTagJitter(tag_history, tag_hist_count, params.tag_min_samples);
    area_jitter_ratio = computeScalarJitterRatio(tag_area_history, tag_hist_count, params.tag_min_samples);
    margin_mean = computeScalarMean(tag_margin_history, tag_hist_count, params.tag_min_samples);
    quality_ok = detected && isfinite(margin_mean) && margin_mean >= params.tag_margin_warn;
    stability_score = computeTagStabilityScore(jitter_px, area_jitter_ratio, margin_mean, params);
    stable = detected && isfinite(jitter_px) && isfinite(area_jitter_ratio) && ...
        (jitter_px < params.tag_jitter_warn_px) && ...
        (area_jitter_ratio < params.tag_area_jitter_warn_ratio) && ...
        (stability_score >= params.tag_stability_score_warn);
    tagObs = makeTagObs(detected, n_tags, tag_id, u_norm, v_norm, jitter_px, area_jitter_ratio, area_px2, margin_mean, quality_ok, stable, stability_score, centered);

    % run decision method
    if strcmp(dec_method,'decision_tree')
        decision = decision_tree(wind, drone, landingZone, tagObs, params);
    else
        p_safe = bayesian_score(wind, drone, bayes);
        if p_safe >= bayes.threshold, decision = 'land'; else decision = 'wait'; end
    end

    % publish decision
    msg_dec.data = char(decision);
    send(pub_dec, msg_dec);

    % print small status
    fprintf('[%s] wind=%.2fm/s dir=%.1fdeg tag_detect=%d id=%d n=%d center=(%.2f,%.2f) jitter=%.2fpx areaJ=%.4f margin=%.1f score=%.2f -> %s\n', ...
        datestr(now,'HH:MM:SS'), wind.wind_speed, wind.wind_direction, tagObs.detected, tagObs.tag_id, tagObs.num_tags, ...
        tagObs.u_norm, tagObs.v_norm, tagObs.jitter_px, tagObs.area_jitter_ratio, tagObs.margin, tagObs.stability_score, decision);

    waitfor(rate);
end

%% small helper functions
function x = tryReceive(sub, timeout)
    % wrapper to avoid exceptions
    try
        x = receive(sub, timeout);
    catch
        x = [];
    end
end

function r = rateControl(freq)
    % return a simple rate controller object with waitfor method
    r.period = 1.0/freq;
    r.tlast = tic;
    r.waitfor = @() local_wait(r);
    function local_wait(self)
        elapsed = toc(r.tlast);
        towait = r.period - elapsed;
        if towait > 0, pause(towait); end
        r.tlast = tic;
    end
end

function safeStopWind(timerHandle)
    % Stop and delete a MATLAB timer safely
    try
        if ~isempty(timerHandle) && isvalid(timerHandle)
            stop(timerHandle);
            delete(timerHandle);
            fprintf('[MATLAB] Wind publisher stopped and timer deleted.\n');
        end
    catch
        % ignore cleanup errors
    end
end

function [detected, n_tags, tag_id, cx, cy, area_px2, margin] = extractTagFeatures(tagMsg, useTargetId, targetId)
    detected = false;
    n_tags = 0;
    tag_id = -1;
    cx = nan;
    cy = nan;
    area_px2 = nan;
    margin = nan;
    if isempty(tagMsg)
        return;
    end

    detections = [];
    try
        detections = tagMsg.detections;
    catch
        return;
    end
    if isempty(detections)
        return;
    end

    n_tags = numel(detections);

    % Select detection: target ID preferred, otherwise highest decision margin.
    selectedIdx = -1;
    bestMargin = -inf;
    for i = 1:n_tags
        det = detections(i);
        thisId = -1;
        try
            thisId = double(det.id);
        catch
        end
        thisMargin = 0.0;
        try
            thisMargin = double(det.decision_margin);
        catch
        end

        if useTargetId && thisId == targetId
            selectedIdx = i;
            break;
        end
        if ~useTargetId && thisMargin > bestMargin
            bestMargin = thisMargin;
            selectedIdx = i;
        end
    end

    if selectedIdx < 0
        return;
    end

    det = detections(selectedIdx);
    try
        tag_id = double(det.id);
    catch
        tag_id = -1;
    end
    try
        margin = double(det.decision_margin);
    catch
        margin = nan;
    end

    % Try common apriltag center naming variants.
    try
        c = det.center;
        cx = double(c.x); cy = double(c.y);
    catch
        try
            c = det.centre;
            cx = double(c.x); cy = double(c.y);
        catch
        end
    end

    % Fallback: average corners if center field is unavailable.
    corners = [];
    try
        corners = det.corners;
    catch
    end
    if (~isfinite(cx) || ~isfinite(cy)) && ~isempty(corners)
        [cx, cy] = cornersCenter(corners);
    end

    if ~isempty(corners)
        area_px2 = cornersArea(corners);
    end

    detected = isfinite(cx) && isfinite(cy);
end

function [hist, count] = pushTagCenter(hist, count, cx, cy)
    if any(~isfinite([cx cy]))
        return;
    end
    hist(1:end-1,:) = hist(2:end,:);
    hist(end,:) = [cx, cy];
    count = min(size(hist,1), count + 1);
end

function [hist, count] = pushTagScalar(hist, value)
    if ~isfinite(value)
        return;
    end
    hist(1:end-1,:) = hist(2:end,:);
    hist(end,:) = value;
    validCount = sum(isfinite(hist));
    count = min(size(hist,1), validCount);
end

function [u_norm, v_norm, centered] = computeFrameCenterMetrics(cx, cy, w, h, tol)
    if ~isfinite(cx) || ~isfinite(cy) || w <= 0 || h <= 0
        u_norm = nan;
        v_norm = nan;
        centered = false;
        return;
    end
    % normalize to [-1,1], where (0,0) is image center
    u_norm = (cx - (w/2.0)) / (w/2.0);
    v_norm = (cy - (h/2.0)) / (h/2.0);
    centered = sqrt(u_norm^2 + v_norm^2) <= tol;
end

function jitter = computeTagJitter(hist, count, minSamples)
    jitter = inf;
    if count < max(minSamples, 2)
        return;
    end

    rows = hist(end-count+1:end, :);
    rows = rows(all(isfinite(rows),2), :);
    if size(rows,1) < max(minSamples, 2)
        return;
    end

    % Use RMS of frame-to-frame center displacement as jitter metric.
    dxy = diff(rows, 1, 1);
    d = sqrt(sum(dxy.^2, 2));
    jitter = sqrt(mean(d.^2));
end

function ratio = computeScalarJitterRatio(hist, count, minSamples)
    ratio = inf;
    if count < max(minSamples, 2)
        return;
    end
    rows = hist(end-count+1:end, :);
    rows = rows(isfinite(rows));
    if numel(rows) < max(minSamples, 2)
        return;
    end
    mu = mean(rows);
    if mu <= 1e-6
        return;
    end
    ratio = std(rows) / mu;
end

function mu = computeScalarMean(hist, count, minSamples)
    mu = nan;
    if count < max(minSamples, 1)
        return;
    end
    rows = hist(end-count+1:end, :);
    rows = rows(isfinite(rows));
    if numel(rows) < max(minSamples, 1)
        return;
    end
    mu = mean(rows);
end

function score = computeTagStabilityScore(centerJitter, areaJitter, margin, params)
    if ~isfinite(centerJitter) || ~isfinite(areaJitter) || ~isfinite(margin)
        score = 0.0;
        return;
    end

    s1 = 1.0 - min(1.0, centerJitter / max(params.tag_jitter_unsafe_px, 1e-6));
    s2 = 1.0 - min(1.0, areaJitter / max(params.tag_area_jitter_unsafe_ratio, 1e-6));
    s3 = min(1.0, margin / max(params.tag_margin_warn, 1e-6));
    score = max(0.0, min(1.0, 0.5*s1 + 0.3*s2 + 0.2*s3));
end

function [cx, cy] = cornersCenter(corners)
    xs = zeros(numel(corners),1);
    ys = zeros(numel(corners),1);
    for k = 1:numel(corners)
        xs(k) = double(corners(k).x);
        ys(k) = double(corners(k).y);
    end
    cx = mean(xs);
    cy = mean(ys);
end

function area = cornersArea(corners)
    area = nan;
    if isempty(corners)
        return;
    end
    n = numel(corners);
    if n < 3
        return;
    end
    xs = zeros(n,1);
    ys = zeros(n,1);
    for k = 1:n
        xs(k) = double(corners(k).x);
        ys(k) = double(corners(k).y);
    end
    xs2 = [xs; xs(1)];
    ys2 = [ys; ys(1)];
    area = 0.5 * abs(sum(xs2(1:end-1).*ys2(2:end) - xs2(2:end).*ys2(1:end-1)));
end

function [detected, n_tags, tag_id, cx, cy, area_px2, margin] = extractTagFeaturesFromBridge(msg)
    detected = false;
    n_tags = 0;
    tag_id = -1;
    cx = nan;
    cy = nan;
    area_px2 = nan;
    margin = nan;

    if isempty(msg)
        return;
    end

    try
        d = double(msg.data);
    catch
        return;
    end

    if numel(d) < 7
        return;
    end

    detected = d(1) > 0.5;
    tag_id = d(2);
    cx = d(3);
    cy = d(4);
    area_px2 = d(5);
    margin = d(6);
    n_tags = d(7);
end

% EOF

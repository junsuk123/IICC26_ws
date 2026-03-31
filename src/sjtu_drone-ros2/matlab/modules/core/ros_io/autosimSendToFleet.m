function autosimSendToFleet(rosCtx, channel, msg)
% autosimSendToFleet Publish one command to primary namespace and followers.

persistent spawnWaitWarnTs
persistent spawnGateStartTs
if isempty(spawnWaitWarnTs)
    spawnWaitWarnTs = containers.Map('KeyType', 'char', 'ValueType', 'double');
end
if isempty(spawnGateStartTs)
    spawnGateStartTs = containers.Map('KeyType', 'char', 'ValueType', 'double');
end

switch lower(string(channel))
    case "cmd"
        primaryPub = rosCtx.pubCmd;
        followerField = 'pubCmdFollowers';
    case "takeoff"
        primaryPub = rosCtx.pubTakeoff;
        followerField = 'pubTakeoffFollowers';
    case "land"
        primaryPub = rosCtx.pubLand;
        followerField = 'pubLandFollowers';
    case "reset"
        primaryPub = rosCtx.pubReset;
        followerField = 'pubResetFollowers';
    case "posctrl"
        primaryPub = rosCtx.pubPosCtrl;
        followerField = 'pubPosCtrlFollowers';
    otherwise
        error('Unknown fleet channel: %s', channel);
end

if lower(string(channel)) == "takeoff"
    [fleetReady, readyCount, expectedCount, fleetKey, missingNs] = autosimFleetSpawnReadyForTakeoff(rosCtx);
    nowSec = now * 86400.0;
    gateKey = char(fleetKey);

    if ~isKey(spawnGateStartTs, gateKey)
        spawnGateStartTs(gateKey) = nowSec;
    end
    waitSec = max(0.0, nowSec - spawnGateStartTs(gateKey));

    relaxWaitSec = 8.0;
    hardBypassWaitSec = 20.0;
    minReadyToRelax = max(1, expectedCount - 1);
    relaxByPartialReady = (~fleetReady) && (readyCount >= minReadyToRelax) && (waitSec >= relaxWaitSec);
    relaxByHardBypass = (~fleetReady) && (waitSec >= hardBypassWaitSec);
    relaxAllowed = relaxByPartialReady || relaxByHardBypass;

    if ~fleetReady
        warnKey = gateKey;
        lastWarn = -inf;
        if isKey(spawnWaitWarnTs, warnKey)
            lastWarn = spawnWaitWarnTs(warnKey);
        end
        if (nowSec - lastWarn) >= 2.0
            if relaxAllowed
                if relaxByHardBypass && ~relaxByPartialReady
                    fprintf('[AUTOSIM ROS] Takeoff gate hard-bypass after %.1fs: proceeding despite unresolved readiness (%d/%d), missing=[%s]\n', ...
                        waitSec, readyCount, expectedCount, strjoin(cellstr(missingNs), ', '));
                else
                fprintf('[AUTOSIM ROS] Takeoff gate relaxed after %.1fs: proceeding with partial readiness (%d/%d), missing=[%s]\n', ...
                    waitSec, readyCount, expectedCount, strjoin(cellstr(missingNs), ', '));
                end
            else
                fprintf('[AUTOSIM ROS] Takeoff gated: waiting for fleet spawn readiness (%d/%d, waited %.1fs), missing=[%s]\n', ...
                    readyCount, expectedCount, waitSec, strjoin(cellstr(missingNs), ', '));
            end
            spawnWaitWarnTs(warnKey) = nowSec;
        end
        if ~relaxAllowed
            return;
        end
    else
        if isKey(spawnGateStartTs, gateKey)
            remove(spawnGateStartTs, gateKey);
        end
    end
end

send(primaryPub, msg);

if ~isfield(rosCtx, followerField)
    return;
end

pubs = rosCtx.(followerField);
if isempty(pubs)
    return;
end

for i = 1:numel(pubs)
    try
        followerMsg = autosimBuildFleetMsg(pubs{i}, channel, msg);
        send(pubs{i}, followerMsg);
    catch exc
        % Keep primary control path alive even if one follower publisher fails.
        fprintf('[AUTOSIM ROS] Warning: follower[%d] send failed on %s: %s\n', i, followerField, exc.message);
    end
end

% Extra safety path: in multi-drone runs, broadcast takeoff via ROS2 CLI once.
if lower(string(channel)) == "takeoff"
    autosimFleetTakeoffCliFallback(rosCtx);
end
end

function [isReady, readyCount, expectedCount, fleetKey, missingNs] = autosimFleetSpawnReadyForTakeoff(rosCtx)
[nsList, fleetKey] = autosimFleetNamespaces(rosCtx);
expectedCount = numel(nsList);
readyCount = 0;
isReady = true;
missingNs = strings(0, 1);

if expectedCount == 0
    return;
end

readyMask = false(expectedCount, 1);
for i = 1:expectedCount
    ns = string(nsList(i));
    [subState, subPose] = autosimFleetSubsForNamespace(rosCtx, ns);
    readyMask(i) = autosimSubHasSample(subState) || autosimSubHasSample(subPose);
end

readyCount = nnz(readyMask);
isReady = (readyCount == expectedCount);
if ~isReady
    missingNs = nsList(~readyMask);
end
end

function [subState, subPose] = autosimFleetSubsForNamespace(rosCtx, ns)
subState = [];
subPose = [];

primaryNs = "";
if isfield(rosCtx, 'pubTakeoff') && ~isempty(rosCtx.pubTakeoff)
    try
        topic = string(rosCtx.pubTakeoff.TopicName);
        tok = regexp(topic, '^(.*)/takeoff$', 'tokens', 'once');
        if ~isempty(tok)
            primaryNs = string(tok{1});
        end
    catch
    end
end

if strlength(primaryNs) > 0 && ns == primaryNs
    if isfield(rosCtx, 'subState')
        subState = rosCtx.subState;
    end
    if isfield(rosCtx, 'subPose')
        subPose = rosCtx.subPose;
    end
    return;
end

if isfield(rosCtx, 'follower_namespaces') && ~isempty(rosCtx.follower_namespaces)
    idx = find(string(rosCtx.follower_namespaces(:)) == ns, 1, 'first');
    if ~isempty(idx)
        if isfield(rosCtx, 'subStateFollowers') && numel(rosCtx.subStateFollowers) >= idx
            subState = rosCtx.subStateFollowers{idx};
        end
        if isfield(rosCtx, 'subPoseFollowers') && numel(rosCtx.subPoseFollowers) >= idx
            subPose = rosCtx.subPoseFollowers{idx};
        end
    end
end
end

function tf = autosimSubHasSample(sub)
tf = false;
if isempty(sub)
    return;
end

msg = autosimTryReceive(sub, 0.0);
tf = ~isempty(msg);
end

function [nsList, fleetKey] = autosimFleetNamespaces(rosCtx)
nsList = strings(0, 1);

if isfield(rosCtx, 'pubTakeoff') && ~isempty(rosCtx.pubTakeoff)
    try
        topic = string(rosCtx.pubTakeoff.TopicName);
        tok = regexp(topic, '^(.*)/takeoff$', 'tokens', 'once');
        if ~isempty(tok)
            nsList(end+1, 1) = string(tok{1}); %#ok<AGROW>
        end
    catch
    end
end

if isfield(rosCtx, 'follower_namespaces') && ~isempty(rosCtx.follower_namespaces)
    nsList = [nsList; string(rosCtx.follower_namespaces(:))]; %#ok<AGROW>
end

if isempty(nsList)
    fleetKey = "single";
else
    nsList = unique(nsList);
    fleetKey = strjoin(sort(nsList), '|');
end
end

function outMsg = autosimBuildFleetMsg(pub, channel, inMsg)
% Build a publisher-local message instance to avoid cross-publisher reuse issues.
outMsg = ros2message(pub);

switch lower(string(channel))
    case "cmd"
        outMsg.linear.x = inMsg.linear.x;
        outMsg.linear.y = inMsg.linear.y;
        outMsg.linear.z = inMsg.linear.z;
        outMsg.angular.x = inMsg.angular.x;
        outMsg.angular.y = inMsg.angular.y;
        outMsg.angular.z = inMsg.angular.z;
    case "takeoff"
        % std_msgs/Empty has no fields to copy.
    case "land"
        % std_msgs/Empty has no fields to copy.
    case "reset"
        % std_msgs/Empty has no fields to copy.
    case "posctrl"
        outMsg.data = logical(inMsg.data);
    otherwise
        % Keep empty message for unknown channels.
end
end

function autosimFleetTakeoffCliFallback(rosCtx)
if ~isfield(rosCtx, 'follower_namespaces')
    return;
end

nsList = string(rosCtx.follower_namespaces);
if isempty(nsList)
    return;
end

% Include primary namespace when available.
primaryNs = "";
if isfield(rosCtx, 'pubTakeoff') && ~isempty(rosCtx.pubTakeoff)
    try
        topic = string(rosCtx.pubTakeoff.TopicName);
        tok = regexp(topic, '^(.*)/takeoff$', 'tokens', 'once');
        if ~isempty(tok)
            primaryNs = string(tok{1});
        end
    catch
    end
end
if strlength(primaryNs) > 0
    nsList = unique([primaryNs; nsList]);
end

for i = 1:numel(nsList)
    ns = char(nsList(i));
    if isempty(ns)
        continue;
    end
    cmd = sprintf([ ...
        'cd /home/j/INCSL/IICC26_ws && ' ...
        'source /opt/ros/humble/setup.bash && ' ...
        'source /home/j/INCSL/IICC26_ws/install/setup.bash && ' ...
        'ros2 topic pub --once %s/takeoff std_msgs/msg/Empty "{}" >/dev/null 2>&1' ...
        ], ns);
    try
        system(sprintf('bash -lc "%s"', cmd));
    catch
    end
end
end


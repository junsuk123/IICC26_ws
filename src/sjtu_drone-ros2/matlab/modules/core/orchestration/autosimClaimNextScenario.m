function [scenarioId, queueInfo] = autosimClaimNextScenario(cfg)
scenarioId = [];
queueInfo = struct('enabled', false, 'reason', "queue_disabled", 'queue_state_file', "", 'next_id', NaN, 'total_count', NaN, 'claimed', false);

if ~autosimEnvBool('AUTOSIM_SCENARIO_QUEUE_ENABLED', false)
    queueInfo.reason = "queue_disabled";
    return;
end

queueStateFile = strtrim(string(getenv('AUTOSIM_SCENARIO_QUEUE_STATE')));
if strlength(queueStateFile) == 0
    sessionRoot = strtrim(string(getenv('AUTOSIM_SESSION_ROOT')));
    if strlength(sessionRoot) > 0
        queueStateFile = fullfile(char(sessionRoot), 'scenario_queue_state.txt');
    end
end

queueInfo.queue_state_file = queueStateFile;
if strlength(queueStateFile) == 0
    queueInfo.reason = "queue_state_missing";
    return;
end

if ~isfile(queueStateFile)
    queueInfo.reason = "queue_state_missing";
    return;
end

lockDir = char(queueStateFile + ".lock");
lockAcquired = false;
for attempt = 1:250
    [lockAcquired, ~, ~] = mkdir(lockDir);
    if lockAcquired
        break;
    end
    pause(0.02);
end

if ~lockAcquired
    queueInfo.reason = "queue_lock_timeout";
    return;
end

cleanupObj = onCleanup(@() autosimReleaseQueueLock(lockDir));

state = autosimReadQueueState(queueStateFile);
if ~isfield(state, 'next_id') || ~isfield(state, 'total_count')
    queueInfo.reason = "queue_state_invalid";
    return;
end

nextId = state.next_id;
totalCount = state.total_count;
queueInfo.next_id = nextId;
queueInfo.total_count = totalCount;

if ~isfinite(nextId) || ~isfinite(totalCount) || totalCount < 1
    queueInfo.reason = "queue_state_invalid";
    return;
end

if nextId > totalCount
    queueInfo.enabled = true;
    queueInfo.reason = "queue_empty";
    return;
end

scenarioId = round(nextId);
state.next_id = nextId + 1;
state.updated_at = string(datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX'));
autosimWriteQueueState(queueStateFile, state);

queueInfo.enabled = true;
queueInfo.reason = "queue_claimed";
queueInfo.claimed = true;
queueInfo.next_id = state.next_id;
end

function state = autosimReadQueueState(queueStateFile)
state = struct();
fid = fopen(queueStateFile, 'r');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
while true
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    line = strtrim(string(line));
    if strlength(line) == 0 || startsWith(line, "#")
        continue;
    end
    parts = split(line, "=");
    if numel(parts) < 2
        continue;
    end
    key = strtrim(parts(1));
    value = strtrim(strjoin(parts(2:end), "="));
    switch key
        case "next_id"
            state.next_id = str2double(value);
        case "total_count"
            state.total_count = str2double(value);
        case "updated_at"
            state.updated_at = value;
    end
end
end

function autosimWriteQueueState(queueStateFile, state)
tmpFile = char(queueStateFile + ".tmp");
fid = fopen(tmpFile, 'w');
if fid < 0
    error('autosimClaimNextScenario:QueueWriteFailed', 'Unable to write queue state file: %s', tmpFile);
end
fprintf(fid, 'next_id=%g\n', state.next_id);
fprintf(fid, 'total_count=%g\n', state.total_count);
if isfield(state, 'updated_at')
    fprintf(fid, 'updated_at=%s\n', char(string(state.updated_at)));
else
    fprintf(fid, 'updated_at=%s\n', datestr(now, 'yyyy-mm-ddTHH:MM:SS.FFF'));
end
fclose(fid);
movefile(tmpFile, queueStateFile, 'f');
end

function autosimReleaseQueueLock(lockDir)
if isfolder(lockDir)
    try
        rmdir(lockDir);
    catch
    end
end
end

function tf = autosimEnvBool(name, defaultValue)
raw = strtrim(lower(getenv(name)));
if isempty(raw)
    tf = logical(defaultValue);
    return;
end
tf = any(strcmp(raw, {'1', 'true', 'yes', 'y', 'on'}));
end
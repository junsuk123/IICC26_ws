function softOK = autosimSoftReset(cfg, scenarioId)
% Try /reset_world first, then /reset_simulation. Return true on success.
    if nargin < 2
        scenarioId = -1;
    end

    softOK = false;

    setupCmd = "";
    if isfield(cfg, 'ros2env') && strlength(string(cfg.ros2env)) > 0
        setupCmd = string(cfg.ros2env);
    elseif isfield(cfg, 'shell') && isfield(cfg.shell, 'setup_cmd')
        setupCmd = string(cfg.shell.setup_cmd);
    end

    timeoutSec = 6.0;
    if isfield(cfg, 'process') && isfield(cfg.process, 'soft_reset_service_timeout_sec') && isfinite(cfg.process.soft_reset_service_timeout_sec)
        timeoutSec = max(1.0, cfg.process.soft_reset_service_timeout_sec);
    end

    discoverRetry = 3;
    discoverRetryPauseSec = 0.8;
    if isfield(cfg, 'process')
        if isfield(cfg.process, 'soft_reset_discovery_retry_count') && isfinite(cfg.process.soft_reset_discovery_retry_count)
            discoverRetry = max(1, round(cfg.process.soft_reset_discovery_retry_count));
        end
        if isfield(cfg.process, 'soft_reset_discovery_retry_pause_sec') && isfinite(cfg.process.soft_reset_discovery_retry_pause_sec)
            discoverRetryPauseSec = max(0.1, cfg.process.soft_reset_discovery_retry_pause_sec);
        end
    end

    try
        stList = 1;
        svcs = '';
        for attempt = 1:discoverRetry
            if attempt > 1
                autosimRefreshRos2Daemon();
                pause(discoverRetryPauseSec);
            end
            if strlength(setupCmd) > 0
                listCore = char(setupCmd + " && ros2 service list");
            else
                listCore = 'ros2 service list';
            end
            listCmd = sprintf('bash -i -c "%s"', autosimEscapeDq(listCore));
            [stList, svcs] = system(listCmd);
            if stList == 0 && strlength(strtrim(string(svcs))) > 0
                break;
            end
        end
        if stList ~= 0
            warning('[AUTOSIM] s%03d soft reset: service list failed after %d retries.', scenarioId, discoverRetry);
            return;
        end

        hasResetWorld = contains(string(svcs), "/reset_world");
        hasResetSim = contains(string(svcs), "/reset_simulation");
        hasGazeboResetWorld = contains(string(svcs), "/gazebo/reset_world");
        hasGazeboResetSim = contains(string(svcs), "/gazebo/reset_simulation");

        targets = strings(0,1);
        if hasResetWorld
            targets(end+1,1) = "/reset_world"; %#ok<AGROW>
        end
        if hasGazeboResetWorld
            targets(end+1,1) = "/gazebo/reset_world"; %#ok<AGROW>
        end
        if hasResetSim
            targets(end+1,1) = "/reset_simulation"; %#ok<AGROW>
        end
        if hasGazeboResetSim
            targets(end+1,1) = "/gazebo/reset_simulation"; %#ok<AGROW>
        end
        if ~isempty(targets)
            targets = unique(targets, 'stable');
        end

        if isempty(targets)
            fprintf('[AUTOSIM] s%03d soft reset: no reset service found.\n', scenarioId);
            return;
        end

        for i = 1:numel(targets)
            svc = char(targets(i));
            for attempt = 1:2
                if strlength(setupCmd) > 0
                    callCore = sprintf('%s && timeout %.1fs ros2 service call %s std_srvs/srv/Empty {}', char(setupCmd), timeoutSec, svc);
                else
                    callCore = sprintf('timeout %.1fs ros2 service call %s std_srvs/srv/Empty {}', timeoutSec, svc);
                end
                callCmd = sprintf('bash -i -c "%s"', autosimEscapeDq(callCore));

                fprintf('[AUTOSIM] s%03d soft reset: calling %s (try %d/2) ...\n', scenarioId, svc, attempt);
                [stCall, outCall] = system(callCmd);
                if stCall == 0
                    fprintf('[AUTOSIM] s%03d soft reset succeeded via %s\n', scenarioId, svc);
                    softOK = true;
                    return;
                end
                if attempt == 1
                    autosimRefreshRos2Daemon();
                    pause(0.3);
                end
            end
            warning('[AUTOSIM] s%03d soft reset failed via %s: %s', scenarioId, svc, strtrim(outCall));
        end
    catch ME
        warning('[AUTOSIM] s%03d soft reset error: %s', scenarioId, ME.message);
        softOK = false;
    end
end

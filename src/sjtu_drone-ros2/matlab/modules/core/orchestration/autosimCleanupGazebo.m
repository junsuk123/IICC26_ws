function autosimCleanupGazebo()
% autosimCleanupGazebo
% Kill all lingering Gazebo processes and clear ports before simulation startup.
% This prevents "Address already in use" errors when launching new scenarios.

    fprintf('[AUTOSIM] Cleaning up previous Gazebo processes...\n');
    
    % Kill all gzserver processes
    try
        system('pkill -9 gzserver 2>/dev/null || true');
        fprintf('[AUTOSIM]   - Killed gzserver processes\n');
    catch
        % Silent fail if pkill not available
    end
    
    % Kill all gzclient processes
    try
        system('pkill -9 gzclient 2>/dev/null || true');
        fprintf('[AUTOSIM]   - Killed gzclient processes\n');
    catch
    end
    
    % Small delay to ensure processes terminate
    pause(1.0);
    
    % Verify Gazebo port is free (default is 11345)
    try
        [st, out] = system('lsof -i :11345 2>/dev/null || true');
        if st == 0 && ~isempty(strtrim(out))
            % Port is still in use, wait a bit more and retry
            fprintf('[AUTOSIM]   - Gazebo port 11345 still in use, waiting...\n');
            pause(2.0);
            system('pkill -9 -f gazebo 2>/dev/null || true');
            pause(1.0);
        else
            fprintf('[AUTOSIM]   - Gazebo port 11345 is free\n');
        end
    catch
        % Silent fail if lsof not available
    end
    
    fprintf('[AUTOSIM] Gazebo cleanup complete\n');
end

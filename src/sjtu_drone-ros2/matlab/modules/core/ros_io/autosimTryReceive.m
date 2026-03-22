function x = autosimTryReceive(sub, timeout)
    if nargin < 2 || ~isfinite(timeout)
        timeout = 0.01;
    end
    timeout = max(0.0, double(timeout));
    if isempty(sub)
        x = [];
        return;
    end

    % Prefer non-blocking latest-sample access to keep control loops responsive.
    try
        if isprop(sub, 'LatestMessage')
            latest = sub.LatestMessage;
            if ~isempty(latest)
                x = latest;
                return;
            end
            if timeout <= 0.0
                x = [];
                return;
            end
        end
    catch
        % Fall through to receive() fallback for compatibility.
    end

    % Never let one topic stall the simulation loop for long.
    timeout = min(timeout, 0.005);
    try
        x = receive(sub, timeout);
    catch
        x = [];
    end
end



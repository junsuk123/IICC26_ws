function [targetX, targetY] = autosimComputePoseTrackingCommand(cfg, xNow, yNow, xRef, yRef, mode)
    if nargin < 6 || strlength(string(mode)) == 0
        mode = "direct_ref";
    else
        mode = string(mode);
    end

    if isfinite(xRef) && isfinite(yRef)
        if mode == "png" && isfinite(xNow) && isfinite(yNow)
            navGain = 1.25;
            maxStep = 0.40;
            if nargin >= 1 && isstruct(cfg)
                if isfield(cfg, 'guidance') && isstruct(cfg.guidance)
                    if isfield(cfg.guidance, 'png_nav_gain') && isfinite(cfg.guidance.png_nav_gain)
                        navGain = max(0.0, double(cfg.guidance.png_nav_gain));
                    end
                    if isfield(cfg.guidance, 'png_max_step_xy_m') && isfinite(cfg.guidance.png_max_step_xy_m)
                        maxStep = max(0.0, double(cfg.guidance.png_max_step_xy_m));
                    end
                end
                if isfield(cfg, 'control') && isstruct(cfg.control) && ...
                        isfield(cfg.control, 'xy_cmd_limit') && isfinite(cfg.control.xy_cmd_limit)
                    maxStep = min(maxStep, abs(double(cfg.control.xy_cmd_limit)));
                end
            end

            dx = xRef - xNow;
            dy = yRef - yNow;
            stepX = navGain * dx;
            stepY = navGain * dy;
            stepNorm = hypot(stepX, stepY);
            if stepNorm > maxStep && stepNorm > 1e-9
                scale = maxStep / stepNorm;
                stepX = stepX * scale;
                stepY = stepY * scale;
            end
            targetX = xNow + stepX;
            targetY = yNow + stepY;
        else
            targetX = xRef;
            targetY = yRef;
        end
        return;
    end

    targetX = autosimClampNaN(xNow, 0.0);
    targetY = autosimClampNaN(yNow, 0.0);
end

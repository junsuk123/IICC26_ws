function [targetX, targetY, tagLostSearchStartT] = autosimComputeTagTrackingCommand(cfg, tk, xNow, yNow, predOk, uPred, vPred, tagDetected, uTag, vTag, tagLostSearchStartT, poseHoldTargetX, poseHoldTargetY)
    targetX = autosimClampNaN(xNow, 0.0);
    targetY = autosimClampNaN(yNow, 0.0);

    if nargin < 15 || ~isfinite(poseHoldTargetX)
        poseHoldTargetX = 0.0;
    end
    if nargin < 16 || ~isfinite(poseHoldTargetY)
        poseHoldTargetY = 0.0;
    end

    usePred = predOk && isfinite(uPred) && isfinite(vPred);
    useNow = tagDetected && isfinite(uTag) && isfinite(vTag);

    if usePred
        uCtrl = uPred;
        vCtrl = vPred;
    elseif useNow
        uCtrl = uTag;
        vCtrl = vTag;
    else
        uCtrl = nan;
        vCtrl = nan;
    end

    if isfinite(uCtrl) && isfinite(vCtrl)
        tagLostSearchStartT = nan;
        errU = cfg.control.target_u - uCtrl;
        errV = cfg.control.target_v - vCtrl;

        deltaX = autosimClamp(cfg.control.xy_kp * errV, -abs(cfg.control.xy_cmd_limit), abs(cfg.control.xy_cmd_limit));
        deltaY = autosimClamp(cfg.control.xy_kp * errU, -abs(cfg.control.xy_cmd_limit), abs(cfg.control.xy_cmd_limit));

        deltaX = cfg.control.xy_map_sign_x_from_v * deltaX;
        deltaY = cfg.control.xy_map_sign_y_from_u * deltaY;

        if sqrt(errU * errU + errV * errV) <= cfg.control.tag_center_deadband
            deltaX = 0.0;
            deltaY = 0.0;
        end

        if isfinite(xNow)
            targetX = xNow + deltaX;
        else
            targetX = poseHoldTargetX + deltaX;
        end
        if isfinite(yNow)
            targetY = yNow + deltaY;
        else
            targetY = poseHoldTargetY + deltaY;
        end
    else
        if cfg.control.pose_hold_enable && isfinite(xNow) && isfinite(yNow)
            targetX = poseHoldTargetX;
            targetY = poseHoldTargetY;
        elseif cfg.control.search_enable_spiral
            if ~isfinite(tagLostSearchStartT)
                tagLostSearchStartT = tk;
            end

            tSearch = max(0.0, tk - tagLostSearchStartT);
            rSearch = cfg.control.search_spiral_start_radius + cfg.control.search_spiral_growth_per_sec * tSearch;
            rSearch = min(rSearch, cfg.control.search_spiral_cmd_max);
            th = cfg.control.search_spiral_omega_rad_sec * tSearch;
            spiralX = autosimClamp(rSearch * cos(th), -abs(cfg.control.search_spiral_cmd_max), abs(cfg.control.search_spiral_cmd_max));
            spiralY = autosimClamp(rSearch * sin(th), -abs(cfg.control.search_spiral_cmd_max), abs(cfg.control.search_spiral_cmd_max));
            if isfinite(xNow)
                targetX = xNow + spiralX;
            else
                targetX = poseHoldTargetX + spiralX;
            end
            if isfinite(yNow)
                targetY = yNow + spiralY;
            else
                targetY = poseHoldTargetY + spiralY;
            end
        else
            targetX = poseHoldTargetX;
            targetY = poseHoldTargetY;
        end
    end
end



function [cmdX, cmdY, pidX, pidY] = autosimComputePoseTrackingPidCommand(cfg, dtCtrl, xNow, yNow, xRef, yRef, pidX, pidY)
    cmdX = 0.0;
    cmdY = 0.0;

    if ~isfinite(xNow) || ~isfinite(yNow) || ~isfinite(xRef) || ~isfinite(yRef)
        pidX = autosimPidInit();
        pidY = autosimPidInit();
        return;
    end

    kp = autosimClampNaN(cfg.control.pose_hold_kp, 0.45);
    ki = 0.0;
    kd = 0.0;
    iLim = autosimClampNaN(cfg.control.pose_hold_i_limit, 0.40);
    cmdLim = abs(autosimClampNaN(cfg.control.pose_hold_cmd_limit, 0.35));

    if isfield(cfg.control, 'pose_hold_ki') && isfinite(cfg.control.pose_hold_ki)
        ki = cfg.control.pose_hold_ki;
    end
    if isfield(cfg.control, 'pose_hold_kd') && isfinite(cfg.control.pose_hold_kd)
        kd = cfg.control.pose_hold_kd;
    end

    errX = xRef - xNow;
    errY = yRef - yNow;
    [cmdX, pidX] = autosimPidStep(errX, dtCtrl, pidX, kp, ki, kd, iLim, cmdLim);
    [cmdY, pidY] = autosimPidStep(errY, dtCtrl, pidY, kp, ki, kd, iLim, cmdLim);
end

function varargout = autosim_wind_sim(action, varargin)
% autosim_wind_sim
% Wind simulation module for command generation and limit handling.

switch lower(string(action))
    case "compute_command"
        [varargout{1}, varargout{2}] = compute_command(varargin{1}, varargin{2}, varargin{3}, varargin{4});
    case "get_cap"
        varargout{1} = get_cap(varargin{1});
    otherwise
        error("autosim_wind_sim:unknownAction", "Unknown action: %s", string(action));
end
end

function [speedCmd, dirCmd] = compute_command(cfg, scenarioCfg, tNow, windArmed)
if ~windArmed || ~cfg.wind.enable
    speedCmd = 0.0;
    dirCmd = 0.0;
    return;
end

baseSpeed = max(0.0, scenarioCfg.wind_speed);
baseDir = scenarioCfg.wind_dir;

ramp = 1.0;
if isfield(cfg.wind, 'model_ramp_sec') && isfinite(cfg.wind.model_ramp_sec) && cfg.wind.model_ramp_sec > 0
    ramp = min(max(tNow / cfg.wind.model_ramp_sec, 0.0), 1.0);
end

gustScale = 1.0;
if isfield(scenarioCfg, 'gust_amp_scale') && isfinite(scenarioCfg.gust_amp_scale)
    gustScale = max(0.0, scenarioCfg.gust_amp_scale);
end
gustAmp = baseSpeed * cfg.wind.model_gust_amp_ratio * gustScale;
gust = gustAmp * sin(2.0 * pi * cfg.wind.model_gust_freq_hz * tNow);
noise = cfg.wind.model_noise_std_speed * randn();
speedCmd = max(0.0, ramp * (baseSpeed + gust + noise));

cap = get_cap(cfg);
if isfinite(cap) && cap > 0
    speedCmd = min(speedCmd, cap);
end

dirOscAmp = cfg.wind.model_dir_osc_amp_deg;
dirScale = 1.0;
if isfield(scenarioCfg, 'dir_osc_scale') && isfinite(scenarioCfg.dir_osc_scale)
    dirScale = max(0.0, scenarioCfg.dir_osc_scale);
end
dirOscAmp = dirOscAmp * dirScale;
dirOsc = dirOscAmp * sin(2.0 * pi * cfg.wind.model_dir_osc_freq_hz * tNow + pi / 4.0);
dirNoise = cfg.wind.model_dir_noise_std_deg * randn();
dirCmd = baseDir + dirOsc + dirNoise;
dirCmd = mod(dirCmd + 180.0, 360.0) - 180.0;
end

function cap = get_cap(cfg)
cap = inf;
if isfield(cfg, 'wind') && isfield(cfg.wind, 'speed_max') && isfinite(cfg.wind.speed_max) && cfg.wind.speed_max > 0
    cap = min(cap, cfg.wind.speed_max);
end
if isfield(cfg, 'wind') && isfield(cfg.wind, 'hover_limit_mps') && isfinite(cfg.wind.hover_limit_mps) && cfg.wind.hover_limit_mps > 0
    cap = min(cap, cfg.wind.hover_limit_mps);
end
if ~isfinite(cap)
    cap = nan;
end
end

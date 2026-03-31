function [padOffsetU, padOffsetV, padVelU, padVelV, padMoving] = autosimComputeMovingPadMotion(tSec, scenarioCfg)
% Reciprocating straight-line pad motion with triangular velocity profile.
% The path direction is defined by [moving_pad_amp_u, moving_pad_amp_v].

padOffsetU = 0.0;
padOffsetV = 0.0;
padVelU = 0.0;
padVelV = 0.0;
padMoving = false;

if nargin < 2 || ~isstruct(scenarioCfg)
    return;
end

movingEnable = isfield(scenarioCfg, 'moving_pad_enable') && logical(scenarioCfg.moving_pad_enable);
if ~movingEnable
    return;
end

ampU = abs(localField(scenarioCfg, 'moving_pad_amp_u', 0.0));
ampV = abs(localField(scenarioCfg, 'moving_pad_amp_v', 0.0));
freqHz = abs(localField(scenarioCfg, 'moving_pad_freq_hz', 0.0));

pathAmp = hypot(ampU, ampV);
if ~(isfinite(pathAmp) && pathAmp > 0) || ~(isfinite(freqHz) && freqHz > 0)
    return;
end

if pathAmp <= 1e-6
    dirU = 1.0;
    dirV = 0.0;
else
    dirU = ampU / pathAmp;
    dirV = ampV / pathAmp;
end

[sPos, sVel] = localTriVelProfile(max(0.0, tSec), pathAmp, freqHz);
padOffsetU = dirU * sPos;
padOffsetV = dirV * sPos;
padVelU = dirU * sVel;
padVelV = dirV * sVel;
padMoving = abs(sVel) > 1e-5;
end

function [sPos, sVel] = localTriVelProfile(tSec, amp, freqHz)
% Scalar position in [-amp, amp] and scalar velocity using triangular speed.

period = 1.0 / max(freqHz, 1e-6);
halfT = 0.5 * period;
quarterT = 0.25 * period;
vMax = 8.0 * amp * freqHz;
aMag = vMax / max(quarterT, 1e-6);

tm = mod(tSec, period);
if tm < halfT
    if tm < quarterT
        tau = tm;
        sVel = aMag * tau;
        sPos = -amp + 0.5 * aMag * tau^2;
    else
        tau = tm - quarterT;
        sVel = vMax - aMag * tau;
        sPos = 0.0 + vMax * tau - 0.5 * aMag * tau^2;
    end
else
    tm2 = tm - halfT;
    if tm2 < quarterT
        tau = tm2;
        sVel = -aMag * tau;
        sPos = amp - 0.5 * aMag * tau^2;
    else
        tau = tm2 - quarterT;
        sVel = -vMax + aMag * tau;
        sPos = 0.0 - vMax * tau + 0.5 * aMag * tau^2;
    end
end

if ~isfinite(sPos)
    sPos = 0.0;
end
if ~isfinite(sVel)
    sVel = 0.0;
end
sPos = max(-amp, min(amp, sPos));
end

function v = localField(s, name, fallback)
if isfield(s, name)
    vv = double(s.(name));
    if isfinite(vv)
        v = vv;
        return;
    end
end
v = fallback;
end

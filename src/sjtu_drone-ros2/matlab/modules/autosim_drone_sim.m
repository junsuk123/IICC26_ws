function varargout = autosim_drone_sim(action, varargin)
% autosim_drone_sim
% Drone-simulation-focused reusable helpers for ROS IO and contact parsing.

switch lower(string(action))
    case "try_receive"
        varargout{1} = try_receive(varargin{1}, varargin{2});
    case "parse_imu"
        [varargout{1}, varargout{2}] = parse_imu(varargin{1});
    case "parse_contact"
        if numel(varargin) >= 2
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}] = parse_contact(varargin{1}, varargin{2});
        else
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}] = parse_contact(varargin{1}, "");
        end
    otherwise
        error("autosim_drone_sim:unknownAction", "Unknown action: %s", string(action));
end
end

function x = try_receive(sub, timeout)
if isempty(sub)
    x = [];
    return;
end
try
    x = receive(sub, timeout);
catch
    x = [];
end
end

function [angVelNorm, linAccNorm] = parse_imu(msg)
angVelNorm = nan;
linAccNorm = nan;

[okAV, av] = get_field(msg, ["angular_velocity", "angularvelocity"]);
if okAV
    [okX, x] = get_field(av, ["x", "X"]);
    [okY, y] = get_field(av, ["y", "Y"]);
    [okZ, z] = get_field(av, ["z", "Z"]);
    if okX && okY && okZ
        x = double(x); y = double(y); z = double(z);
        if isfinite(x) && isfinite(y) && isfinite(z)
            angVelNorm = sqrt(x*x + y*y + z*z);
        end
    end
end

[okLA, la] = get_field(msg, ["linear_acceleration", "linearacceleration"]);
if okLA
    [okX, x] = get_field(la, ["x", "X"]);
    [okY, y] = get_field(la, ["y", "Y"]);
    [okZ, z] = get_field(la, ["z", "Z"]);
    if okX && okY && okZ
        x = double(x); y = double(y); z = double(z);
        if isfinite(x) && isfinite(y) && isfinite(z)
            linAccNorm = sqrt(x*x + y*y + z*z);
        end
    end
end
end

function [hasContact, totalForce, fFL, fFR, fRL, fRR] = parse_contact(msg, msgTypeHint)
hasContact = 0;
totalForce = nan;
fFL = nan; fFR = nan; fRL = nan; fRR = nan;

[okStates, states] = get_field(msg, ["states", "contacts", "contact_states"]);
if okStates
    nState = numel(states);
    totalForce = 0.0;
    fFL = 0.0; fFR = 0.0; fRL = 0.0; fRR = 0.0;
    for i = 1:nState
        st = states(i);
        c1 = ""; c2 = "";
        [okC1, c1v] = get_field(st, ["collision1_name", "collision1Name", "name1"]);
        [okC2, c2v] = get_field(st, ["collision2_name", "collision2Name", "name2"]);
        if okC1, c1 = string(c1v); end
        if okC2, c2 = string(c2v); end
        arm = arm_key(c1 + " " + c2);

        forceSum = 0.0;
        [okWrenches, wrenches] = get_field(st, ["wrenches", "forces", "contact_wrenches"]);
        if okWrenches
            for j = 1:numel(wrenches)
                wj = wrenches(j);
                [okForceObj, forceObj] = get_field(wj, ["force", "Force", "vector"]);
                if okForceObj
                    [okFx, fx] = get_field(forceObj, ["x", "X"]);
                    [okFy, fy] = get_field(forceObj, ["y", "Y"]);
                    [okFz, fz] = get_field(forceObj, ["z", "Z"]);
                    if okFx && okFy && okFz
                        fx = double(fx); fy = double(fy); fz = double(fz);
                        if isfinite(fx) && isfinite(fy) && isfinite(fz)
                            forceSum = forceSum + sqrt(fx*fx + fy*fy + fz*fz);
                        end
                    end
                end
            end
        end

        totalForce = totalForce + forceSum;
        switch arm
            case "fl", fFL = fFL + forceSum;
            case "fr", fFR = fFR + forceSum;
            case "rl", fRL = fRL + forceSum;
            case "rr", fRR = fRR + forceSum;
        end
    end
    hasContact = double(totalForce > 0.0);
    return;
end

[okData, data] = get_field(msg, ["data", "values", "forces"]);
if okData
    dv = numeric_vector(data);
    if numel(dv) >= 6
        hasContact = double(dv(1) > 0.5);
        totalForce = max(0.0, dv(2));
        fFL = max(0.0, dv(3)); fFR = max(0.0, dv(4));
        fRL = max(0.0, dv(5)); fRR = max(0.0, dv(6));
        return;
    end
end

if contains(lower(string(msgTypeHint)), "contact")
    hasContact = 0;
    totalForce = 0.0;
    fFL = 0.0; fFR = 0.0; fRL = 0.0; fRR = 0.0;
end
end

function [ok, value] = get_field(obj, names)
ok = false;
value = [];
names = string(names(:));
for i = 1:numel(names)
    nm = char(names(i));
    try
        if isstruct(obj) && isfield(obj, nm)
            value = obj.(nm);
            ok = true;
            return;
        end
    catch
    end
    try
        if isobject(obj) && isprop(obj, nm)
            value = obj.(nm);
            ok = true;
            return;
        end
    catch
    end
end
end

function key = arm_key(nameText)
s = lower(char(nameText));
key = "";
if contains(s, 'front_left') || contains(s, 'left_front') || contains(s, 'arm_fl') || contains(s, 'fl_')
    key = "fl";
elseif contains(s, 'front_right') || contains(s, 'right_front') || contains(s, 'arm_fr') || contains(s, 'fr_')
    key = "fr";
elseif contains(s, 'rear_left') || contains(s, 'back_left') || contains(s, 'left_rear') || contains(s, 'arm_rl') || contains(s, 'rl_')
    key = "rl";
elseif contains(s, 'rear_right') || contains(s, 'back_right') || contains(s, 'right_rear') || contains(s, 'arm_rr') || contains(s, 'rr_')
    key = "rr";
end
end

function vec = numeric_vector(x)
try
    vec = double(x(:));
    vec = vec(isfinite(vec));
catch
    vec = [];
end
end

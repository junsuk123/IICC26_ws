function wind_publisher_matlab(varargin)
% wind_publisher_matlab  Publish a realistic near-surface wind field to ROS2
%
% Usage:
%   wind_publisher_matlab()                % run with defaults, infinite loop
%   wind_publisher_matlab('Rate',10)       % publish at 10 Hz
%   wind_publisher_matlab('Duration',60)   % run for 60 seconds
%
% This script simulates a near-surface wind vector (u,v,w) (m/s) using:
% - A slowly time-varying mean wind (base + diurnal cycle)
% - Turbulence as band-limited (AR(1)) filtered white noise
% - Intermittent gust events (Poisson arrivals, Gaussian time shape)
% - Slowly-varying wind direction
%
% The generated wind is published as geometry_msgs/msg/Vector3 on
% topic '/environment/wind' with fields X=u, Y=v, Z=w.
%
% Assumptions/Notes:
% - Parameters (mean speed, turbulence intensity, gust rate) are set to
%   reasonable near-surface defaults for temperate coastal/urban areas in
%   South Korea. If you need site-specific statistics, tune them.
% - Requires MATLAB ROS2 support package (ros2node, ros2publisher, ros2message).
% - Ensure ROS2 network/domain is configured consistently between MATLAB and
%   your ROS2 system.

% Inputs (name-value):
%   'Rate'       - publish rate in Hz (default 10)
%   'Duration'   - duration in seconds; empty/inf for continuous (default inf)
%   'BaseMean'   - base mean wind speed (m/s) (default 4.0)
%   'TI'         - turbulence intensity (ratio of sigma_u / mean) (default 0.20)
%   'GustRate'   - average gust arrivals per minute (default 1.0)
%   'Seed'       - RNG seed (default shuffled)

% Returns: none (publishes until Duration elapses or interrupted)

% Example:
%   wind_publisher_matlab('Rate',20,'Duration',300,'BaseMean',5)

% Author: Generated helper
% Date: 2026-03-07

%% Parse inputs
p = inputParser;
addParameter(p,'Rate',10,@(x)isnumeric(x)&&x>0);
addParameter(p,'Duration',inf,@(x)isnumeric(x)&&x>0);
addParameter(p,'BaseMean',4.0,@(x)isnumeric(x)&&x>=0);
addParameter(p,'TI',0.20,@(x)isnumeric(x)&&x>=0);
addParameter(p,'GustRate',1.0,@(x)isnumeric(x)&&x>=0); % per minute
addParameter(p,'Seed',[],@(x)isnumeric(x)&&isscalar(x));
addParameter(p,'Height',10.0,@(x)isnumeric(x)&&x>=0); % vehicle height (m)
addParameter(p,'ShearExponent',0.14,@(x)isnumeric(x)&&x>=0); % power law exponent (alpha)
addParameter(p,'Lu',200,@(x)isnumeric(x)&&x>0); % Dryden length scales (m)
addParameter(p,'Lv',50,@(x)isnumeric(x)&&x>0);
addParameter(p,'Lw',15,@(x)isnumeric(x)&&x>0);
parse(p,varargin{:});
opts = p.Results;

if ~isempty(opts.Seed)
    rng(opts.Seed);
end

rate_hz = opts.Rate;
dt = 1/ rate_hz;
T = opts.Duration;

height = opts.Height;
alpha = opts.ShearExponent;
Lu = opts.Lu; Lv = opts.Lv; Lw = opts.Lw;

%% Wind model parameters (tunable)
base_mean = opts.BaseMean;    % m/s (reference at z_ref)
z_ref = 10;                   % reference height for base_mean (m)
diurnal_amp = 1.2;            % amplitude of diurnal variation (m/s)
diurnal_phase = 0;            % phase offset (radians)

ti = opts.TI;                 % turbulence intensity (sigma_u / mean)

gust_rate_per_sec = opts.GustRate/60; % convert to per second
gust_amp_mean = 3.0;         % mean gust amplitude (m/s)
gust_amp_std = 1.5;          % gust amplitude variability
gust_tau = 4.0;              % gust duration scale (seconds)

%% Direction model
dir_change_fc = 0.01;  % Hz (slow variation in wind direction)
dir_a = exp(-2*pi*dir_change_fc*dt);
dir_sigma = 0.3;       % standard deviation of direction increments (rad)

%% Dryden turbulence: will try to build continuous-time Dryden filters and
%% discretize them (using Control System Toolbox). If unavailable, fall back
%% to the simple AR(1) approximation.
hasControl = license('test','Control_Toolbox') && exist('tf','file') && exist('c2d','file');
use_dryden = hasControl;

%% Gust/random seed already handled
gust_rate_per_sec = opts.GustRate/60;

%% Prepare ROS2 publisher
% Create node and publisher. Users must have ROS2 network ready.
try
    node = ros2node("matlab_wind_publisher_node");
    pub = ros2publisher(node,'/environment/wind','geometry_msgs/msg/Vector3');
catch ME
    error('Failed to create ROS2 node/publisher. Ensure MATLAB ROS2 is installed and configured.\nOriginal error: %s', ME.message);
end

msg = ros2message(pub);

%% Initialize states
t = 0.0;

% Turbulence filter state initializations
u_turb_prev = 0.0; v_turb_prev = 0.0; w_turb_prev = 0.0;
wind_dir = deg2rad(0); % initial direction (rad) from which wind blows

% For gusts: maintain active gusts as struct array with fields t0, amp, dir
active_gusts = struct('t0',{},'amp',{},'dir',{});

% Rate controller
rateObj = ros2rate(rate_hz);

% If using Dryden, build discrete-time filters once (or rebuild when mean
% speed changes significantly). We'll build initial filters here and update
% adaptively if mean speed changes a lot.
if use_dryden
    % default length scales Lu, Lv, Lw used above
    dryden_filters_valid = false;
    zi_u = [];
    zi_v = [];
    zi_w = [];
else
    % fallback AR(1) filter params
    fc_turb = 0.3;                % turbulence cutoff frequency (Hz) for AR(1)
    turba = exp(-2*pi*fc_turb*dt);
    turb_b = sqrt(1 - turba^2);
end

start_time = tic;
fprintf('Starting wind publisher at %g Hz. Press Ctrl-C to stop.\n', rate_hz);

while true
    elapsed = toc(start_time);
    if elapsed >= T
        break;
    end

    % --- mean wind with diurnal cycle ---
    diurnal = diurnal_amp * sin(2*pi*(elapsed/86400) + diurnal_phase);
    mean_speed_ref = max(0, base_mean + diurnal); % mean at reference height z_ref

    % Apply shear (power law) to compute mean at vehicle height
    if height <= 0
        mean_speed = mean_speed_ref;
    else
        mean_speed = mean_speed_ref * (height / z_ref)^alpha;
    end


    % --- slowly varying wind direction (random walk lowpass) ---
    % AR(1) update for small-angle increments
    dir_noise = dir_sigma * sqrt(1 - dir_a^2) * randn();
    wind_dir = dir_a * wind_dir + dir_noise;

    % Convert mean to components (wind from direction wind_dir)
    % Convention: u is East (positive), v is North (positive). If wind_dir is
    % direction FROM which wind blows, then wind vector = -mean_speed * [cos(dir), sin(dir)]
    u_mean = -mean_speed * cos(wind_dir);
    v_mean = -mean_speed * sin(wind_dir);
    w_mean = 0.0;

    % --- turbulence: Dryden shaping (preferred) or AR(1) fallback ---
    sigma_u = max(0.01, ti * mean_speed);
    sigma_v = 0.8 * sigma_u;
    sigma_w = 0.5 * sigma_u;

    if use_dryden
        % Rebuild discrete Dryden filters if mean speed changed enough to
        % affect the time constants (tau = L / U). We check relative change.
        U = max(mean_speed, 0.1);
        rebuild_threshold = 0.05; % rebuild if >5% change
        if ~dryden_filters_valid || abs(U - last_U)/last_U > rebuild_threshold
            last_U = U;
            % Continuous-time Dryden transfer functions using tau = L / U
            s = tf('s');
            tau_u = Lu / U;
            Gu = sigma_u * sqrt(2*Lu/pi) * (1 / (1 + tau_u * s));

            tau_v = Lv / U;
            Gv = sigma_v * sqrt(Lv/pi) * (1 + (tau_v * s)/sqrt(3)) / (1 + (2 * tau_v * s)/sqrt(3) + (tau_v^2 * s^2)/3);

            tau_w = Lw / U;
            Gw = sigma_w * sqrt(Lw/pi) * (1 + (tau_w * s)/sqrt(3)) / (1 + (2 * tau_w * s)/sqrt(3) + (tau_w^2 * s^2)/3);

            try
                Gd_u = c2d(Gu,dt,'tustin');
                Gd_v = c2d(Gv,dt,'tustin');
                Gd_w = c2d(Gw,dt,'tustin');
                [bu,au] = tfdata(Gd_u,'v'); [bv,av] = tfdata(Gd_v,'v'); [bw,aw] = tfdata(Gd_w,'v');
                zi_u = zeros(max(length(au),length(bu))-1,1);
                zi_v = zeros(max(length(av),length(bv))-1,1);
                zi_w = zeros(max(length(aw),length(bw))-1,1);
                dryden_filters_valid = true;
            catch err
                % If c2d/tfdata fails, fall back to AR(1)
                warning('Dryden discretization failed, falling back to AR(1): %s', err.message);
                use_dryden = false;
                fc_turb = 0.3;
                turba = exp(-2*pi*fc_turb*dt);
                turb_b = sqrt(1 - turba^2);
            end
        end
    end

    if use_dryden && dryden_filters_valid
        % drive discrete filters with unit white noise; filter output is turb component
        [u_turb, zi_u] = filter(bu,au,randn(1,1),zi_u);
        [v_turb, zi_v] = filter(bv,av,randn(1,1),zi_v);
        [w_turb, zi_w] = filter(bw,aw,randn(1,1),zi_w);
        % outputs are in m/s already because filters were scaled by sigma
    else
        % fallback AR(1)
        u_turb = turba * u_turb_prev + turb_b * sigma_u * randn();
        v_turb = turba * v_turb_prev + turb_b * sigma_v * randn();
        w_turb = turba * w_turb_prev + turb_b * sigma_w * randn();
        u_turb_prev = u_turb; v_turb_prev = v_turb; w_turb_prev = w_turb;
    end

    % --- gust arrivals (Poisson) ---
    if rand() < gust_rate_per_sec * dt
        % spawn a new gust
        gamp = max(0, gust_amp_mean + gust_amp_std*randn());
        gdir = wind_dir + (randn()*0.3); % gust direction slightly different
        active_gusts(end+1) = struct('t0',elapsed,'amp',gamp,'dir',gdir); %#ok<AGROW>
    end

    % Evaluate gust contributions and remove finished gusts
    gust_u = 0.0; gust_v = 0.0; gust_w = 0.0;
    if ~isempty(active_gusts)
        keep = false(size(active_gusts));
        for k = 1:numel(active_gusts)
            age = elapsed - active_gusts(k).t0;
            if age < 6*gust_tau
                % Gaussian-shaped gust in time
                g = active_gusts(k).amp * exp(-0.5*(age/gust_tau)^2);
                gust_u = gust_u - g * cos(active_gusts(k).dir);
                gust_v = gust_v - g * sin(active_gusts(k).dir);
                keep(k) = true;
            else
                keep(k) = false;
            end
        end
        active_gusts = active_gusts(keep);
    end

    % --- total wind vector (m/s) ---
    u = u_mean + u_turb + gust_u;
    v = v_mean + v_turb + gust_v;
    w = w_mean + w_turb + gust_w;

    % Publish to ROS2 topic
    % geometry_msgs/msg/Vector3 fields are X, Y, Z in MATLAB
    msg.X = u;
    msg.Y = v;
    msg.Z = w;
    try
        publish(pub,msg);
    catch err
        warning('Publish failed: %s', err.message);
    end

    % Optional: print a low-rate status
    if mod(round(elapsed/dt), round(rate_hz*5)) == 0
        fprintf('t=%.1fs mean=%.2fm/s dir=%.1fdeg u=%.2f v=%.2f w=%.2f active_gusts=%d\n', ...
            elapsed, mean_speed, rad2deg(wind_dir), u, v, w, numel(active_gusts));
    end

    % Wait for next cycle
    waitfor(rateObj);
end

fprintf('Wind publisher finished (elapsed %.1fs).\n', toc(start_time));
end

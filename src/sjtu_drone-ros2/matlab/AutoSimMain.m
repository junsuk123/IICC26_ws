function AutoSimMain()
% AutoSimMain
% One-click parallel AutoSim runner for MATLAB Run button.
% Launches single-worker simulation with real-time monitoring.
clear; clc; close all
thisDir = fileparts(mfilename('fullpath'));
if isempty(thisDir)
    error('Failed to resolve AutoSimMain path.');
end

% Keep main script as flow-only: delegate logic to orchestration module.
modDir = fullfile(thisDir, 'modules');
if isfolder(modDir)
    addpath(modDir);
    coreDir = fullfile(modDir, 'core');
    if isfolder(coreDir)
        addpath(genpath(coreDir));
    end
end

% Run parallel workers + realtime 4-panel monitor
fprintf('[AUTOSIM MAIN] Starting parallel simulation with monitor...\n');
autosimMainOrchestrate(thisDir);
fprintf('[AUTOSIM MAIN] Simulation complete.\n');
end

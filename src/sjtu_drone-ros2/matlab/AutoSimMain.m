function AutoSimMain()
% AutoSimMain
% Single-world stable pipeline entrypoint.
% Collects data in one Gazebo world, then merges data and runs train/validation.

thisDir = fileparts(mfilename('fullpath'));
if isempty(thisDir)
    error('Failed to resolve AutoSimMain path.');
end

modDir = fullfile(thisDir, 'modules');
if exist(modDir, 'dir')
    addpath(modDir);
end
coreDir = fullfile(modDir, 'core');
if exist(coreDir, 'dir')
    addpath(genpath(coreDir));
end

autosimSingleWorldPipeline(thisDir);
end

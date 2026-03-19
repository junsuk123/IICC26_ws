function AutoSimMain()
% AutoSimMain
% New main entry point for AutoSim execution.
%
% This keeps backward compatibility with the legacy monolithic AutoSim.m
% while providing a dedicated main function entry for future modular wiring.

thisDir = fileparts(mfilename('fullpath'));
run(fullfile(thisDir, 'AutoSim.m'));
end

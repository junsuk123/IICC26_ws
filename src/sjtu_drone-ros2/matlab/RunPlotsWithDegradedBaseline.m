%% RunPlotsWithDegradedBaseline.m
% Regenerate paper plots using 10000-sample validation data with degraded baseline thresholds

clear; clc; close all force;

paperPlotRunDir = '/home/j/SynologyDrive/INCSL/devel/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/data/validation_holdout_20260330_130522';
paperPlotUseExistingRunDir = true;
baselineComparatorsToPlot = ["threshold"];
modelTypesToPlot = ["ontology_ai"];

fprintf('[RunPlotsWithDegradedBaseline] Starting paper plots regeneration...\n');
fprintf('[RunPlotsWithDegradedBaseline] Using validation data from: %s\n', paperPlotRunDir);

run('AutoSimPaperPlots.m');

fprintf('\n[COMPLETED] Paper plots regenerated with degraded baseline thresholds.\n');
fprintf('[COMPLETED] Check plots/ directory for new confusion matrices.\n');

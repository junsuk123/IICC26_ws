% AutoSimPaperPlots.m
% Standalone script for paper-ready figures/tables from AutoSim outputs.
% Supports comparison of multiple model types: aii_only, ontology_ai
%
% Usage:
% 1) Open this file in MATLAB and Run.
% 2) Optional: set runDir/outputDir/modelTypesToPlot below before running.
close all;
defaultRunDir = "";
modDir = fullfile(fileparts(mfilename('fullpath')), 'modules');
if exist(modDir, 'dir')
    addpath(modDir);
end
coreDir = fullfile(modDir, 'core');
if exist(coreDir, 'dir')
    addpath(genpath(coreDir));
end
% Optional overrides.
% Accept both runDir and run_dir to avoid name-mismatch issues.
explicitRunDir = "";
if exist('paperPlotRunDir', 'var') && strlength(string(paperPlotRunDir)) > 0
    explicitRunDir = string(paperPlotRunDir);
elseif strlength(string(getenv('AUTOSIM_PAPER_PLOTS_RUN_DIR'))) > 0
    explicitRunDir = string(getenv('AUTOSIM_PAPER_PLOTS_RUN_DIR'));
elseif exist('run_dir', 'var') && strlength(string(run_dir)) > 0
    explicitRunDir = string(run_dir);
end

useExistingRunDir = false;
if exist('paperPlotUseExistingRunDir', 'var')
    useExistingRunDir = logical(paperPlotUseExistingRunDir);
elseif strlength(string(getenv('AUTOSIM_PAPER_PLOTS_USE_EXISTING_RUNDIR'))) > 0
    useExistingRunDir = autosimPaperEnvBool('AUTOSIM_PAPER_PLOTS_USE_EXISTING_RUNDIR', false);
end

if strlength(explicitRunDir) > 0
    runDir = explicitRunDir;
elseif ~useExistingRunDir
    runDir = "";
elseif ~exist('runDir', 'var') || strlength(string(runDir)) == 0
    runDir = "";
end

if strlength(string(runDir)) == 0 && strlength(defaultRunDir) > 0
    runDir = defaultRunDir;
end

% Accept both outputDir and output_dir.
explicitOutputDir = "";
if exist('paperPlotOutputDir', 'var') && strlength(string(paperPlotOutputDir)) > 0
    explicitOutputDir = string(paperPlotOutputDir);
elseif strlength(string(getenv('AUTOSIM_PAPER_PLOTS_OUTPUT_DIR'))) > 0
    explicitOutputDir = string(getenv('AUTOSIM_PAPER_PLOTS_OUTPUT_DIR'));
elseif exist('output_dir', 'var') && strlength(string(output_dir)) > 0
    explicitOutputDir = string(output_dir);
end

useExistingOutputDir = false;
if exist('paperPlotUseExistingOutputDir', 'var')
    useExistingOutputDir = logical(paperPlotUseExistingOutputDir);
elseif strlength(string(getenv('AUTOSIM_PAPER_PLOTS_USE_EXISTING_OUTPUTDIR'))) > 0
    useExistingOutputDir = autosimPaperEnvBool('AUTOSIM_PAPER_PLOTS_USE_EXISTING_OUTPUTDIR', false);
end

if strlength(explicitOutputDir) > 0
    outputDir = explicitOutputDir;
elseif ~useExistingOutputDir
    outputDir = "";
elseif ~exist('outputDir', 'var') || strlength(string(outputDir)) == 0
    outputDir = "";
end

% Model types to plot: ["aii_only"], ["ontology_ai"], or ["aii_only", "ontology_ai"]
if ~exist('modelTypesToPlot', 'var') || isempty(modelTypesToPlot)
    modelTypesToPlot = ["ontology_ai"];  % Default to ontology_ai for backward compatibility
end

% Baseline comparators to include against the proposed model.
% Allowed keys: "threshold", "aii_only" (one or more).
if ~exist('baselineComparatorsToPlot', 'var') || isempty(baselineComparatorsToPlot)
    envBaselines = strtrim(string(getenv('AUTOSIM_PAPER_BASELINES')));
    if strlength(envBaselines) > 0
        toks = split(lower(envBaselines), {',', ';', ' '});
        toks = strtrim(toks);
        toks = toks(strlength(toks) > 0);
        baselineComparatorsToPlot = unique(toks, 'stable');
    else
        baselineComparatorsToPlot = ["threshold"];
    end
end
baselineComparatorsToPlot = autosimPaperNormalizeBaselineList(baselineComparatorsToPlot);

rootDir = fileparts(mfilename('fullpath'));
dataRoot = fullfile(rootDir, 'data');
plotRoot = fullfile(rootDir, 'plots');
dataRoots = autosimPaperDiscoverDataRoots(rootDir, dataRoot);

if strlength(string(runDir)) == 0
    runDir = findLatestUsableRunDir(dataRoots);
end
runDir = char(string(runDir));

if strlength(string(outputDir)) == 0
    [~, runName] = fileparts(runDir);
    modelTypesStr = strjoin(string(modelTypesToPlot), '_');
    outputDir = fullfile(plotRoot, sprintf('paper_%s_models_%s_%s', modelTypesStr, runName, datestr(now, 'yyyymmdd_HHMMSS')));
end

% Script variables persist in MATLAB base workspace.
% If outputDir is unchanged from the previous run, force a fresh timestamped folder.
if exist('paperPlotResult', 'var') && isstruct(paperPlotResult) && isfield(paperPlotResult, 'outputDir')
    prevOut = string(paperPlotResult.outputDir);
    if strlength(prevOut) > 0 && string(outputDir) == prevOut
        [~, runName] = fileparts(runDir);
        modelTypesStr = strjoin(string(modelTypesToPlot), '_');
        outputDir = fullfile(plotRoot, sprintf('paper_%s_models_%s_%s', modelTypesStr, runName, datestr(now, 'yyyymmdd_HHMMSS')));
    end
end

outputDir = char(string(outputDir));
ensureDir(outputDir);

fprintf('[AutoSimPaperPlots] runDir=%s\n', runDir);
fprintf('[AutoSimPaperPlots] outputDir=%s\n', outputDir);
fprintf('[AutoSimPaperPlots] model types to plot: %s\n', strjoin(string(modelTypesToPlot), ', '));

FONT_AX = 24;
FONT_LABEL = 24;
FONT_TITLE = 36;
FONT_LEGEND = 24;
PAPER_COMPACT_LABELS = autosimPaperEnvBool('AUTOSIM_PAPER_COMPACT_LABELS', true);

datasetPath = pickFile(runDir, {'autosim_dataset_latest.csv', 'autosim_dataset_*_completed.csv'});
tracePath = pickFile(runDir, {'autosim_trace_latest.csv', 'autosim_trace_*_completed.csv'});
perfPath = pickFile(runDir, {'autosim_performance_*_completed.csv'});
dmetPath = pickFile(runDir, {'autosim_decision_metrics_*_completed.csv'});

if isempty(datasetPath)
    error('AutoSimPaperPlots:NoDataset', 'Dataset CSV not found in %s', runDir);
end

datasetTbl = readtable(datasetPath);
datasetRawCount = height(datasetTbl);
[datasetTbl, recentNUsed] = autosimPaperApplyRecentWindow(datasetTbl);
nTotalScenario = height(datasetTbl);
traceTbl = table();
dmetTblRaw = table(); %#ok<NASGU>

if ~isempty(tracePath)
    traceTbl = readtable(tracePath);
    if isfinite(recentNUsed) && recentNUsed > 0 && height(traceTbl) > round(recentNUsed)
        traceTbl = traceTbl(end - round(recentNUsed) + 1:end, :);
    end
end
if ~isempty(dmetPath)
    dmetTblRaw = readtable(dmetPath); %#ok<NASGU>
end

if isfinite(recentNUsed) && recentNUsed > 0
    fprintf('[AutoSimPaperPlots] recent window: last %d rows (raw=%d, used=%d)\n', ...
        round(recentNUsed), datasetRawCount, nTotalScenario);
end

gtSafe = buildGtSafe(datasetTbl);
decisionMode = autosimPaperResolveDecisionMode();

switch decisionMode
    case "threshold_all"
        proposedPolicy = buildOntologyThresholdPolicy(datasetTbl);
        predProposed = proposedPolicy.predLand;
        methodProposedName = 'Ontology Threshold Policy';
    otherwise
        predProposed = buildDecision(datasetTbl, 'pred_decision', 'landing_cmd_time');
        methodProposedName = 'Ontology+AI (policy)';
end

methodEntries = struct('key', {}, 'name', {}, 'disp', {}, 'predLand', {}, ...
    'decisionMetrics', {}, 'trajMetrics', {}, 'baselineInfo', {});

if PAPER_COMPACT_LABELS
    methodProposedDisp = 'Ont+AI';
else
    methodProposedDisp = methodProposedName;
end

methodEntries(end+1) = struct( ...
    'key', "proposed", ...
    'name', string(methodProposedName), ...
    'disp', string(methodProposedDisp), ...
    'predLand', logical(predProposed(:)), ...
    'decisionMetrics', struct(), ...
    'trajMetrics', struct(), ...
    'baselineInfo', struct()); %#ok<AGROW>

for iBase = 1:numel(baselineComparatorsToPlot)
    baseKey = baselineComparatorsToPlot(iBase);
    try
        switch baseKey
            case "threshold"
                baseSummary = buildThresholdBaseline(datasetTbl);
                baseName = "Physics Threshold Baseline";
                if ~isfield(baseSummary, 'info') || ~isstruct(baseSummary.info)
                    baseSummary.info = struct();
                end
                baseSummary.info.baseline_source = "threshold_rule_based";
            case "aii_only"
                baseSummary = buildAiiOnlyBaseline(datasetTbl, rootDir);
                baseName = "AI-Only baseline";
            otherwise
                continue;
        end
    catch ME
        warning('[AutoSimPaperPlots] baseline "%s" skipped: %s', char(baseKey), ME.message);
        continue;
    end
    methodEntries(end+1) = struct( ...
        'key', string(baseKey), ...
        'name', string(baseName), ...
        'disp', autosimPaperMethodDisplayName(baseKey, PAPER_COMPACT_LABELS), ...
        'predLand', logical(baseSummary.predLand(:)), ...
        'decisionMetrics', struct(), ...
        'trajMetrics', struct(), ...
        'baselineInfo', baseSummary); %#ok<AGROW>
end

if numel(methodEntries) < 2
    error('AutoSimPaperPlots:NoBaselineComparator', ...
        'No baseline comparator selected. Use one or more of ["threshold", "aii_only"].');
end

for iMethod = 1:numel(methodEntries)
    methodEntries(iMethod).decisionMetrics = evalDecision(gtSafe, methodEntries(iMethod).predLand);
    methodEntries(iMethod).trajMetrics = evalTrajectory(datasetTbl, methodEntries(iMethod).predLand);
end

methodNames = strings(numel(methodEntries), 1);
nValid = zeros(numel(methodEntries), 1);
nExecuted = zeros(numel(methodEntries), 1);
executionRate = zeros(numel(methodEntries), 1);
followScore = zeros(numel(methodEntries), 1);
successRate = zeros(numel(methodEntries), 1);
xyzRmse = zeros(numel(methodEntries), 1);
xyRmse = zeros(numel(methodEntries), 1);
zRmse = zeros(numel(methodEntries), 1);
xyMae = zeros(numel(methodEntries), 1);
zMae = zeros(numel(methodEntries), 1);
qualityMean = zeros(numel(methodEntries), 1);
qualityStd = zeros(numel(methodEntries), 1);
metricMode = strings(numel(methodEntries), 1);
for iMethod = 1:numel(methodEntries)
    tm = methodEntries(iMethod).trajMetrics;
    methodNames(iMethod) = methodEntries(iMethod).name;
    nValid(iMethod) = tm.nValid;
    nExecuted(iMethod) = tm.nExecuted;
    executionRate(iMethod) = tm.executionRate;
    followScore(iMethod) = tm.followScore;
    successRate(iMethod) = tm.successRate;
    xyzRmse(iMethod) = tm.xyzRmse;
    xyRmse(iMethod) = tm.xyRmse;
    zRmse(iMethod) = tm.zRmse;
    xyMae(iMethod) = tm.xyMae;
    zMae(iMethod) = tm.zMae;
    qualityMean(iMethod) = tm.qualityMean;
    qualityStd(iMethod) = tm.qualityStd;
    metricMode(iMethod) = string(tm.mode);
end

cmpTbl = table( ...
    methodNames, nValid, nExecuted, executionRate, followScore, successRate, ...
    xyzRmse, xyRmse, zRmse, xyMae, zMae, qualityMean, qualityStd, metricMode, ...
    'VariableNames', {'method','n_valid','n_executed','execution_rate','trajectory_follow_score','trajectory_success_rate', ...
    'trajectory_xyz_rmse_m','trajectory_xy_rmse_m','trajectory_z_rmse_m','trajectory_xy_mae_m','trajectory_z_mae_m', ...
    'trajectory_quality_mean','trajectory_quality_std','trajectory_metric_mode'});

writetable(cmpTbl, fullfile(outputDir, 'paper_table_method_comparison.csv'));

baselineInfoRows = table();
for iMethod = 2:numel(methodEntries)
    bi = methodEntries(iMethod).baselineInfo;
    if isstruct(bi) && isfield(bi, 'info') && isstruct(bi.info)
        row = struct2table(bi.info, 'AsArray', true);
        row.method_key = methodEntries(iMethod).key;
        row.method_name = methodEntries(iMethod).name;
        baselineInfoRows = [baselineInfoRows; row]; %#ok<AGROW>
    end
end
if ~isempty(baselineInfoRows)
    writetable(baselineInfoRows, fullfile(outputDir, 'paper_table_baselines.csv'));
    writetable(baselineInfoRows, fullfile(outputDir, 'paper_table_aii_only_baseline.csv'));
end

mProposed = methodEntries(1).trajMetrics;
mDecisionProposed = methodEntries(1).decisionMetrics;
if numel(methodEntries) >= 2
    mBaseline = methodEntries(2).trajMetrics;
    mDecisionBaseline = methodEntries(2).decisionMetrics;
    baselineSummary = methodEntries(2).baselineInfo;
else
    mBaseline = struct();
    mDecisionBaseline = struct();
    baselineSummary = struct();
end

fig1 = figure('Name', 'MethodComparison', 'Color', 'w', 'Position', [100 100 1180 460]);
tl = tiledlayout(fig1, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

methodDisp = string({methodEntries.disp});
nMethods = numel(methodEntries);

ax1 = nexttile(tl, 1);
barVals = [followScore, successRate, executionRate];
bh = bar(ax1, barVals, 0.88);
bh(1).FaceColor = [0.10 0.45 0.78];
bh(2).FaceColor = [0.13 0.60 0.33];
bh(3).FaceColor = [0.78 0.22 0.22];
xticks(ax1, 1:nMethods);
xticklabels(ax1, cellstr(methodDisp));
ylim(ax1, [0 1]);
ylabel(ax1, 'Score');
if PAPER_COMPACT_LABELS
    title(ax1, 'Trajectory Metrics', 'FontSize', FONT_TITLE);
else
    title(ax1, 'Trajectory Follow Metrics Comparison', 'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax1, nTotalScenario, FONT_AX);
legend(ax1, {'Follow', 'Success', 'Exec'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', FONT_LEGEND);
set(ax1, 'FontSize', FONT_AX);
grid(ax1, 'on');

ax2 = nexttile(tl, 2);
b2vals = [xyzRmse, xyRmse, zRmse];
b2 = bar(ax2, b2vals, 0.82);
b2(1).FaceColor = [0.18 0.45 0.85];
b2(2).FaceColor = [0.15 0.65 0.35];
b2(3).FaceColor = [0.88 0.48 0.16];
xticks(ax2, 1:nMethods);
xticklabels(ax2, cellstr(methodDisp));
ylabel(ax2, 'RMSE [m]');
if PAPER_COMPACT_LABELS
    title(ax2, 'Trajectory RMSE', 'FontSize', FONT_TITLE);
else
    title(ax2, 'Trajectory RMSE Comparison', 'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax2, nTotalScenario, FONT_AX);
legend(ax2, {'XYZ RMSE', 'XY RMSE', 'Z RMSE'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', FONT_LEGEND);
set(ax2, 'FontSize', FONT_AX);
grid(ax2, 'on');

exportgraphics(fig1, fullfile(outputDir, 'paper_fig1_method_comparison.png'), 'Resolution', 220);

n = height(datasetTbl);
sid = getScenarioId(datasetTbl);
if isempty(sid) || numel(sid) ~= n || any(~isfinite(sid))
    sid = (1:n)';
end
trends = cell(nMethods, 1);
for iMethod = 1:nMethods
    trends{iMethod} = cumulativeTrajectoryTrend(datasetTbl, methodEntries(iMethod).predLand);
end

fig2 = figure('Name', 'CumulativeTrends', 'Color', 'w', 'Position', [120 120 1180 520]);
tl2 = tiledlayout(fig2, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

ax21 = nexttile(tl2, 1);
hold(ax21, 'on');
palette = lines(max(3, nMethods));
for iMethod = 1:nMethods
    t = trends{iMethod};
    lw = 2.0;
    if iMethod > 1
        lw = 1.8;
    end
    plot(ax21, sid, smoothAdaptive(t.followScore), '-', 'LineWidth', lw, 'Color', palette(iMethod, :));
end
ylim(ax21, [0 1]);
ylabel(ax21, 'follow score');
if PAPER_COMPACT_LABELS
    title(ax21, 'Cumulative Follow', 'FontSize', FONT_TITLE);
else
    title(ax21, 'Cumulative Trajectory Follow Score', 'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax21, nTotalScenario, FONT_AX);
legend(ax21, cellstr(methodDisp), ...
    'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', FONT_LEGEND);
set(ax21, 'FontSize', FONT_AX);
grid(ax21, 'on');

ax22 = nexttile(tl2, 2);
hold(ax22, 'on');
valsRmse = [];
for iMethod = 1:nMethods
    t = trends{iMethod};
    lw = 2.0;
    if iMethod > 1
        lw = 1.8;
    end
    plot(ax22, sid, smoothAdaptive(t.xyzRmse), '-', 'LineWidth', lw, 'Color', palette(iMethod, :));
    valsRmse = [valsRmse; t.xyzRmse(:)]; %#ok<AGROW>
end
valsRmse = valsRmse(isfinite(valsRmse));
if isempty(valsRmse)
    ylim(ax22, [0 1]);
else
    yMax = max(valsRmse);
    ylim(ax22, [0, max(0.1, 1.15 * yMax)]);
end
xlabel(ax22, 'scenario');
ylabel(ax22, 'XYZ RMSE [m]');
if PAPER_COMPACT_LABELS
    title(ax22, 'Cumulative RMSE', 'FontSize', FONT_TITLE);
else
    title(ax22, 'Cumulative Trajectory RMSE', 'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax22, nTotalScenario, FONT_AX);
legend(ax22, cellstr(methodDisp), ...
    'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', FONT_LEGEND);
set(ax22, 'FontSize', FONT_AX);
grid(ax22, 'on');

exportgraphics(fig2, fullfile(outputDir, 'paper_fig2_cumulative_trends.png'), 'Resolution', 220);

fig3 = figure('Name', 'RiskMap', 'Color', 'w', 'Position', [140 140 1180 500]);
ax3 = axes(fig3);
[xRisk, yRisk] = pickRiskAxes(datasetTbl);
cls = classifyOutcome(gtSafe, predProposed);

drawClass(ax3, xRisk, yRisk, cls == "TP", [0.15 0.65 0.20], 'TP');
drawClass(ax3, xRisk, yRisk, cls == "FP", [0.85 0.25 0.20], 'FP');
drawClass(ax3, xRisk, yRisk, cls == "FN", [0.95 0.70 0.15], 'FN');
drawClass(ax3, xRisk, yRisk, cls == "TN", [0.20 0.45 0.90], 'TN');
xlabel(ax3, 'wind severity (selected feature)');
ylabel(ax3, 'visual/alignment severity');
if PAPER_COMPACT_LABELS
    title(ax3, sprintf('Risk Map (%s)', methodProposedDisp), 'FontSize', FONT_TITLE);
else
    title(ax3, sprintf('Scenario Risk Map (%s decision)', methodProposedName), 'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax3, nTotalScenario, FONT_AX);
grid(ax3, 'on');
legend(ax3, 'Location', 'eastoutside', 'FontSize', FONT_LEGEND);
set(ax3, 'FontSize', FONT_AX);

exportgraphics(fig3, fullfile(outputDir, 'paper_fig3_risk_map.png'), 'Resolution', 220);

fig4 = figure('Name', 'ConfusionMatrices', 'Color', 'w', 'Position', [160 160 420 * nMethods 440]);
tl4 = tiledlayout(fig4, 1, nMethods, 'TileSpacing', 'compact', 'Padding', 'compact');
for iMethod = 1:nMethods
    ax4 = nexttile(tl4, iMethod);
    plotConfusion(ax4, methodEntries(iMethod).decisionMetrics, sprintf('%s (decision)', methodEntries(iMethod).disp));
    annotateTotalScenario(ax4, nTotalScenario, FONT_AX);
end
exportgraphics(fig4, fullfile(outputDir, 'paper_fig4_confusion_matrices.png'), 'Resolution', 220);

if ~isempty(traceTbl) && ismember('pred_stable_prob', traceTbl.Properties.VariableNames)
    fig5 = figure('Name', 'ConfidenceHistogram', 'Color', 'w', 'Position', [180 180 980 420]);
    c = traceTbl.pred_stable_prob;
    c = c(isfinite(c));
    histogram(c, 25, 'FaceColor', [0.10 0.45 0.78], 'EdgeColor', [0.1 0.1 0.1]);
    xlabel('pred\_stable\_prob', 'FontSize', FONT_LABEL);
    ylabel('count', 'FontSize', FONT_LABEL);
    if PAPER_COMPACT_LABELS
        title('Prediction Confidence', 'FontSize', FONT_TITLE);
    else
        title('Prediction Confidence Distribution (trace-level)', 'FontSize', FONT_TITLE);
    end
    ax5 = gca;
    set(ax5, 'FontSize', FONT_AX);
    annotateTotalScenario(ax5, nTotalScenario, FONT_AX);
    grid(ax5, 'on');
    exportgraphics(fig5, fullfile(outputDir, 'paper_fig5_confidence_hist.png'), 'Resolution', 220);
end

decisionScoreP = double(predProposed(:));
riskRefForWind = struct();
for iMethod = 2:nMethods
    bi = methodEntries(iMethod).baselineInfo;
    if isstruct(bi) && isfield(bi, 'risk_ref')
        riskRefForWind = bi.risk_ref;
        if methodEntries(iMethod).key == "threshold"
            break;
        end
    end
end
[windRiskTotal, windMean, windGust] = buildWindRiskSeries(datasetTbl, riskRefForWind);

fig6 = figure('Name', 'ScenarioDecisionAndWindRisk', 'Color', 'w', 'Position', [190 190 1200 420]);
ax6 = axes(fig6);
sidv = sid(:);
hold(ax6, 'on');

% Background shading: AttemptLanding=light blue, HoldLanding=light red, per scenario band.
landMask = decisionScoreP > 0.5;
riskYMax = max(1.05, 1.05 * max(windRiskTotal, [], 'omitnan'));

colLand  = [0.82 0.90 0.98];
colAbort = [0.98 0.86 0.84];

for kk = 1:numel(sidv)
    xL = sidv(kk) - 0.5;
    xR = sidv(kk) + 0.5;
    if landMask(kk)
        fill(ax6, [xL xR xR xL], [0 0 riskYMax riskYMax], colLand, ...
            'EdgeColor', 'none', 'FaceAlpha', 1.0, 'HandleVisibility', 'off');
    else
        fill(ax6, [xL xR xR xL], [0 0 riskYMax riskYMax], colAbort, ...
            'EdgeColor', 'none', 'FaceAlpha', 1.0, 'HandleVisibility', 'off');
    end
end

% Wind risk curve on top (single line, bold enough to read clearly).
hWind = plot(ax6, sidv, smoothAdaptive(windRiskTotal), '-', ...
    'LineWidth', 1.5, 'Color', [0.15 0.15 0.15], 'DisplayName', 'Wind risk');
yline(ax6, 1.0, ':', 'Color', [0.50 0.50 0.50], 'LineWidth', 0.8, 'HandleVisibility', 'off');

ylim(ax6, [0 riskYMax]);
xMin = min(sidv, [], 'omitnan');
xMax = max(sidv, [], 'omitnan');
if ~isfinite(xMin) || ~isfinite(xMax)
    xMin = 1;
    xMax = max(1, numel(sidv));
end
if xMax <= xMin
    xMax = xMin + 1;
end
xlim(ax6, [xMin - 0.5, xMax + 0.5]);
xlabel(ax6, 'Scenario', 'FontSize', FONT_LABEL);
ylabel(ax6, 'Wind risk (normalized)', 'FontSize', FONT_LABEL);
if PAPER_COMPACT_LABELS
    title(ax6, sprintf('Decision vs Wind Risk (%s)', methodProposedDisp), 'FontSize', FONT_TITLE);
else
    title(ax6, sprintf('%s Decision  |  {\\color[rgb]{0.27,0.52,0.79}■ AttemptLanding}  {\\color[rgb]{0.85,0.28,0.22}■ HoldLanding}  —  Wind risk', methodProposedName), ...
        'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax6, nTotalScenario, FONT_AX);
set(ax6, 'FontSize', FONT_AX, 'Box', 'on');
grid(ax6, 'on');

lg6 = legend(ax6, hWind, 'Location', 'northeast', 'FontSize', FONT_LEGEND, 'Box', 'off');

exportgraphics(fig6, fullfile(outputDir, 'paper_fig6_decision_wind_risk.png'), 'Resolution', 220);

% === fig7: Relative correctness and error bias per wind band ===
windVec7  = pickNumeric(datasetTbl, {'mean_wind_speed','wind_speed_cmd','max_wind_speed'}, nan(n,1));
srcVec7   = repmat("", n, 1);
if ismember('action_source', datasetTbl.Properties.VariableNames)
    srcVec7 = string(datasetTbl.action_source);
end
oc7 = classifyOutcome(gtSafe, predProposed);
baselinePredList = cell(max(0, nMethods - 1), 1);
for iBase = 2:nMethods
    baselinePredList{iBase - 1} = logical(methodEntries(iBase).predLand(:));
end

bEdges  = [0, 1.5, 2.0, 2.5, 3.0, Inf];
bLabels = {'0–1.5', '1.5–2.0', '2.0–2.5', '2.5–3.0', '≥3.0'};
nB7 = numel(bLabels);

% Show all non-empty bands while keeping extreme ratio spikes bounded.
ratioCap = 20.0;

% cols: [TP_active | FP_active | FN_passive(timeout/forced) | FN_active | TN]
bCounts7  = zeros(nB7, 5);
bTotal7   = zeros(nB7, 1);
attemptPctBaseline = nan(nB7, max(0, nMethods - 1));

for b = 1:nB7
    mask = windVec7 >= bEdges(b) & windVec7 < bEdges(b+1);
    if ~any(mask); continue; end
    oc_b  = oc7(mask);
    src_b = srcVec7(mask);
    isPassive = contains(src_b, 'timeout', 'IgnoreCase', true) | ...
                contains(src_b, 'forced',  'IgnoreCase', true);
    bCounts7(b,1) = sum(oc_b == "TP");
    bCounts7(b,2) = sum(oc_b == "FP");
    bCounts7(b,3) = sum(oc_b == "FN" &  isPassive);
    bCounts7(b,4) = sum(oc_b == "FN" & ~isPassive);
    bCounts7(b,5) = sum(oc_b == "TN");
    bTotal7(b) = sum(mask);

    for j = 1:numel(baselinePredList)
        predBase = baselinePredList{j};
        attemptCountB = sum(predBase(mask));
        attemptPctBaseline(b, j) = 100 * safeDiv(attemptCountB, bTotal7(b));
    end
end

fig7 = figure('Name', 'WindBandDecisionBreakdown', 'Color', 'w', 'Position', [180 180 1180 520]);
ax7 = axes(fig7);
hold(ax7, 'on');

attemptPct7 = nan(nB7, 1);
holdPct7 = nan(nB7, 1);
for b = 1:nB7
    if bTotal7(b) > 0
        fnTotal = bCounts7(b,3) + bCounts7(b,4);

        attemptCount = bCounts7(b,1) + bCounts7(b,2);  % TP + FP
        holdCount = bCounts7(b,5) + fnTotal;           % TN + FN
        attemptPct7(b) = 100 * safeDiv(attemptCount, bTotal7(b));
        holdPct7(b) = 100 * safeDiv(holdCount, bTotal7(b));
    end
end

validBandMask = bTotal7 > 0;
if ~any(validBandMask)
    validBandMask(:) = true;
end
plotLabels = bLabels(validBandMask);
plotN = bTotal7(validBandMask);
attemptPlot = attemptPct7(validBandMask);
holdPlot = holdPct7(validBandMask);
attemptRatePlot = attemptPct7(validBandMask);
attemptRatePlotB = attemptPctBaseline(validBandMask, :);
x = 1:numel(plotLabels);

yyaxis(ax7, 'left');
countBars = bar(ax7, x, [attemptPlot, holdPlot], 0.70, 'grouped');
set(countBars(1), ...
    'FaceColor', [0.15 0.56 0.86], ...
    'EdgeColor', [0.09 0.39 0.65], ...
    'DisplayName', 'Attempt');
set(countBars(2), ...
    'FaceColor', [0.29 0.70 0.33], ...
    'EdgeColor', [0.20 0.52 0.24], ...
    'DisplayName', 'Hold');

ylabel(ax7, 'Decision ratio (%)', 'FontSize', FONT_LABEL);
ylim(ax7, [0 100]);

yyaxis(ax7, 'right');
pRisk = plot(ax7, x, attemptRatePlot, '-^', ...
    'LineWidth', 2.2, ...
    'Color', [0.86 0.20 0.20], ...
    'MarkerFaceColor', [0.86 0.20 0.20], ...
    'MarkerSize', 7, ...
    'DisplayName', 'Attempt rate');

legendHandles = [countBars(1) countBars(2) pRisk];
legendLabels = {'Attempt', 'Hold', 'Attempt rate'};
basePalette = lines(max(3, nMethods));
for j = 1:size(attemptRatePlotB, 2)
    if all(~isfinite(attemptRatePlotB(:, j)))
        continue;
    end
    colorIdx = min(size(basePalette, 1), j + 1);
    pBase = plot(ax7, x, attemptRatePlotB(:, j), '--^', ...
        'LineWidth', 2.0, ...
        'Color', basePalette(colorIdx, :), ...
        'MarkerFaceColor', basePalette(colorIdx, :), ...
        'MarkerSize', 6, ...
        'DisplayName', sprintf('Attempt rate (%s)', methodEntries(j + 1).disp));
    legendHandles(end+1) = pBase; %#ok<AGROW>
    legendLabels{end+1} = sprintf('Attempt rate (%s)', methodEntries(j + 1).disp); %#ok<AGROW>
end

ylabel(ax7, 'Attempt rate (%)', 'FontSize', FONT_LABEL);
ylim(ax7, [0 100]);
for i = 1:numel(x)
    if isfinite(attemptRatePlot(i))
        text(ax7, x(i), attemptRatePlot(i), sprintf(' %.1f%%', attemptRatePlot(i)), ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', max(11, FONT_AX - 9), ...
            'Color', [0.86 0.20 0.20]);
    end
end

set(ax7, 'XTick', x, 'XTickLabel', plotLabels, 'FontSize', FONT_AX);
xlabel(ax7, 'Wind speed band (m/s)', 'FontSize', FONT_LABEL);
if PAPER_COMPACT_LABELS
    title(ax7, 'Wind Band Decision Shift', 'FontSize', FONT_TITLE);
else
    title(ax7, 'Decision Shift and Landing Attempt Rate by Wind Band', 'FontSize', FONT_TITLE);
end
annotateTotalScenario(ax7, nTotalScenario, FONT_AX);
grid(ax7, 'on');

for i = 1:numel(x)
    yyaxis(ax7, 'left');
    yMark = ax7.YLim(1) + 0.08 * (ax7.YLim(2) - ax7.YLim(1));
    text(ax7, x(i), yMark, sprintf('n=%d', round(plotN(i))), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', max(12, FONT_AX - 8), ...
        'Color', [0.30 0.30 0.30]);
end

legend(ax7, legendHandles, legendLabels, ...
    'Location', 'northoutside', 'Orientation', 'horizontal', ...
    'FontSize', FONT_LEGEND, 'Box', 'off');

exportgraphics(fig7, fullfile(outputDir, 'paper_fig7_wind_band_breakdown.png'), 'Resolution', 220);

save(fullfile(outputDir, 'paper_metrics_struct.mat'), ...
    'mProposed', 'mBaseline', 'mDecisionProposed', 'mDecisionBaseline', 'baselineSummary', ...
    'methodEntries', 'datasetPath', 'tracePath', 'perfPath', 'dmetPath');

infoTxt = fullfile(outputDir, 'paper_summary.txt');
fid = fopen(infoTxt, 'w');
if fid > 0
    fprintf(fid, 'run_dir: %s\n', runDir);
    fprintf(fid, 'dataset: %s\n', datasetPath);
    fprintf(fid, 'trace: %s\n', tracePath);
    fprintf(fid, 'performance: %s\n', perfPath);
    fprintf(fid, 'decision_metrics: %s\n', dmetPath);
    for iMethod = 1:numel(methodEntries)
        fprintf(fid, '\n[%s]\n', char(methodEntries(iMethod).name));
        dumpMetric(fid, methodEntries(iMethod).trajMetrics);
        fprintf(fid, '\n[%s | legacy decision]\n', char(methodEntries(iMethod).name));
        dumpMetric(fid, methodEntries(iMethod).decisionMetrics);
    end
    fclose(fid);
end

paperPlotResult = struct();
paperPlotResult.runDir = runDir;
paperPlotResult.outputDir = outputDir;
paperPlotResult.datasetPath = datasetPath;
paperPlotResult.tracePath = tracePath;
paperPlotResult.performancePath = perfPath;
paperPlotResult.decisionMetricsPath = dmetPath;
paperPlotResult.methodTablePath = fullfile(outputDir, 'paper_table_method_comparison.csv');
paperPlotResult.aiiOnlyTablePath = fullfile(outputDir, 'paper_table_aii_only_baseline.csv');
paperPlotResult.baselinesTablePath = fullfile(outputDir, 'paper_table_baselines.csv');

assignin('base', 'paperPlotResult', paperPlotResult);
fprintf('[AutoSimPaperPlots] done. outputDir=%s\n', outputDir);


function runDir = findLatestRunDir(dataRoots)
    files = autosimPaperCollectFiles(dataRoots, {'autosim_dataset_latest.csv', 'autosim_dataset_*_completed.csv', 'autosim_dataset_*_interrupted.csv'});
    if isempty(files)
        error('AutoSimPaperPlots:NoRunDir', 'No dataset CSV found under discovered data roots.');
    end
    [~, idx] = max([files.datenum]);
    runDir = files(idx).folder;
end


function runDir = findLatestUsableRunDir(dataRoots)
    files = autosimPaperCollectFiles(dataRoots, {'autosim_dataset_latest.csv', 'autosim_dataset_*_completed.csv', 'autosim_dataset_*_interrupted.csv'});
    if isempty(files)
        error('AutoSimPaperPlots:NoRunDir', 'No dataset CSV found under discovered data roots.');
    end

    [~, ord] = sort([files.datenum], 'descend');
    fallbackDir = files(ord(1)).folder;
    for i = 1:numel(ord)
        candidateDir = files(ord(i)).folder;
        if autosimPaperRunHasUsableMetrics(candidateDir)
            runDir = candidateDir;
            if ~strcmp(runDir, fallbackDir)
                fprintf('[AutoSimPaperPlots] Latest run was not usable for paper plots; using %s instead of %s.\n', runDir, fallbackDir);
            end
            return;
        end
    end

    runDir = fallbackDir;
    fprintf('[AutoSimPaperPlots] No fully usable run found; falling back to latest run %s.\n', runDir);
end


function tf = autosimPaperRunHasUsableMetrics(runDir)
    tf = false;
    if ~isfolder(runDir)
        return;
    end

    datasetPath = pickFile(runDir, {'autosim_dataset_latest.csv', 'autosim_dataset_*_completed.csv', 'autosim_dataset_*_interrupted.csv'});
    if isempty(datasetPath) || ~isfile(datasetPath)
        return;
    end

    try
        T = readtable(datasetPath);
    catch
        return;
    end

    if isempty(T) || height(T) == 0
        return;
    end

    if ismember('success', T.Properties.VariableNames)
        successMask = logical(T.success);
        if any(successMask)
            tf = true;
            return;
        end
    end

    if ismember('failure_reason', T.Properties.VariableNames)
        fr = lower(strtrim(string(T.failure_reason)));
        if all(fr == "runtime_exception" | fr == "launch_failure" | fr == "user_interrupt" | fr == "not_run")
            return;
        end
    end

    if ismember('pred_decision', T.Properties.VariableNames)
        pd = normalizeActionLabel(T.pred_decision);
        if any(pd == "AttemptLanding") && any(pd == "HoldLanding")
            tf = true;
            return;
        end
    end

    if ismember('gt_safe_to_land', T.Properties.VariableNames)
        gt = normalizeActionLabel(T.gt_safe_to_land);
        if any(gt == "AttemptLanding") && any(gt == "HoldLanding")
            tf = true;
            return;
        end
    elseif ismember('label', T.Properties.VariableNames)
        lb = normalizeActionLabel(T.label);
        if any(lb == "AttemptLanding") && any(lb == "HoldLanding")
            tf = true;
            return;
        end
    end
end


function roots = autosimPaperDiscoverDataRoots(rootDir, dataRoot)
    roots = string(dataRoot);
    parallelOutputData = autosimPaperFindLatestParallelOutput(rootDir);
    if strlength(parallelOutputData) > 0
        roots(end+1, 1) = parallelOutputData; %#ok<AGROW>
    end
    roots = unique(roots, 'stable');
end


function [T, recentN] = autosimPaperApplyRecentWindow(T)
recentN = autosimPaperResolveRecentDatasetN();
if ~(isfinite(recentN) && recentN > 0)
    return;
end
n = height(T);
if n <= 0
    return;
end
k = min(n, round(recentN));
T = T(n - k + 1:n, :);
end


function recentN = autosimPaperResolveRecentDatasetN()
recentN = inf;
if exist('recentDatasetN', 'var')
    vLocal = double(recentDatasetN);
    if isfinite(vLocal) && vLocal > 0
        recentN = round(vLocal);
        return;
    end
end

raw = string(getenv('AUTOSIM_RECENT_DATASET_N'));
if strlength(raw) == 0
    return;
end
v = str2double(raw);
if isfinite(v) && v > 0
    recentN = round(v);
end
end


function mode = autosimPaperResolveDecisionMode()
mode = "threshold_all";
if exist('paperPlotDecisionMode', 'var') && strlength(string(paperPlotDecisionMode)) > 0
    mode = lower(strtrim(string(paperPlotDecisionMode)));
    return;
end
raw = strtrim(lower(string(getenv('AUTOSIM_PAPER_DECISION_MODE'))));
if strlength(raw) > 0
    mode = raw;
end
end


function out = autosimPaperFindLatestParallelOutput(rootDir)
    out = "";
    parallelRoot = fullfile(rootDir, 'parallel_runs');
    if ~isfolder(parallelRoot)
        return;
    end

    runDirs = dir(parallelRoot);
    runDirs = runDirs([runDirs.isdir]);
    runDirs = runDirs(~ismember({runDirs.name}, {'.', '..'}));
    if isempty(runDirs)
        return;
    end

    [~, ord] = sort([runDirs.datenum], 'descend');
    for i = 1:numel(ord)
        candidate = fullfile(runDirs(ord(i)).folder, runDirs(ord(i)).name, 'output', 'data');
        if isfolder(candidate)
            out = string(candidate);
            return;
        end
    end
end


function files = autosimPaperCollectFiles(roots, patterns)
    files = struct('folder', {}, 'name', {}, 'datenum', {});
    for i = 1:numel(roots)
        root = char(roots(i));
        if ~isfolder(root)
            continue;
        end
        for j = 1:numel(patterns)
            d = dir(fullfile(root, '**', patterns{j}));
            if isempty(d)
                continue;
            end
            if isempty(files)
                files = d;
            else
                files = [files; d]; %#ok<AGROW>
            end
        end
    end

    if isempty(files)
        return;
    end

    fullPaths = strings(numel(files), 1);
    for k = 1:numel(files)
        fullPaths(k) = string(fullfile(files(k).folder, files(k).name));
    end
    [~, ia] = unique(fullPaths, 'stable');
    files = files(ia);
end


function p = pickFile(runDir, candidates)
    p = '';
    for i = 1:numel(candidates)
        q = dir(fullfile(runDir, candidates{i}));
        if ~isempty(q)
            [~, idx] = max([q.datenum]);
            p = fullfile(runDir, q(idx).name);
            return;
        end
    end
end


function ensureDir(p)
    if ~exist(p, 'dir')
        mkdir(p);
    end
end


function sid = getScenarioId(tbl)
    sid = [];
    if ismember('scenario_id', tbl.Properties.VariableNames)
        sid = double(tbl.scenario_id);
    end
    if isrow(sid)
        sid = sid';
    end
end


function gtSafe = buildGtSafe(tbl)
    n = height(tbl);
    gtSafe = false(n, 1);
    if ismember('gt_safe_to_land', tbl.Properties.VariableNames)
        gt = normalizeActionLabel(tbl.gt_safe_to_land);
        gtSafe = (gt == "AttemptLanding");
        return;
    end
    if ismember('label', tbl.Properties.VariableNames)
        lb = normalizeActionLabel(tbl.label);
        gtSafe = (lb == "AttemptLanding");
        return;
    end
    if ismember('success', tbl.Properties.VariableNames)
        gtSafe = logical(tbl.success);
    end
end


function predLand = buildDecision(tbl, decisionField, fallbackNumericField)
    n = height(tbl);
    predLand = false(n, 1);

    if ismember(decisionField, tbl.Properties.VariableNames)
        p = normalizeActionLabel(tbl.(decisionField));
        predLand = (p == "AttemptLanding");
        return;
    end

    if nargin >= 3 && ismember(fallbackNumericField, tbl.Properties.VariableNames)
        v = tbl.(fallbackNumericField);
        predLand = isfinite(v);
    end
end


function b = buildAiiOnlyBaseline(tbl, rootDir)
    n = height(tbl);

    predLand = false(n, 1);
    source = "";
    modelPath = "";
    featureCount = nan;

    candidateCols = { ...
        'pred_decision_aii_only', ...
        'pred_decision_ai_only', ...
        'pred_aii_only_decision', ...
        'aii_only_pred_decision'};

    for i = 1:numel(candidateCols)
        fn = candidateCols{i};
        if ismember(fn, tbl.Properties.VariableNames)
            lbl = normalizeActionLabel(tbl.(fn));
            predLand = (lbl == "AttemptLanding");
            source = "dataset_column:" + string(fn);
            break;
        end
    end

    if strlength(source) == 0
        [predLand, modelPath, featureCount] = predictAiiOnlyWithModel(tbl, rootDir);
        source = "model_inference";
    end

    wind = pickNumeric(tbl, {'mean_wind_speed','wind_speed_cmd','max_wind_speed'}, nan(n,1));
    tagErr = pickNumeric(tbl, {'max_tag_error','mean_tag_error','final_tag_error'}, nan(n,1));
    riskRef = struct();
    if sum(isfinite(wind)) >= 20
        riskRef.wind_threshold = prctile(wind(isfinite(wind)), 90);
    else
        riskRef.wind_threshold = nan;
    end
    if sum(isfinite(tagErr)) >= 20
        riskRef.tag_error_reference = prctile(tagErr(isfinite(tagErr)), 90);
    else
        riskRef.tag_error_reference = nan;
    end

    b = struct();
    b.predLand = logical(predLand(:));
    b.risk_ref = riskRef;
    b.info = struct( ...
        'baseline_source', string(source), ...
        'model_path', string(modelPath), ...
        'feature_count', featureCount, ...
        'n_samples', n);
end


function [predLand, modelPath, featureCount] = predictAiiOnlyWithModel(tbl, rootDir)
    predLand = false(height(tbl), 1);
    modelPath = "";
    featureCount = nan;

    cfg = autosimDefaultConfig();
    cfgModel = autosimGetModelTypeConfig(cfg, "aii_only");
    modelPath = autosimPaperResolveModelPath("", rootDir, cfgModel.paths.model_dir, "aii_only");
    if ~exist(char(modelPath), 'file')
        error('AutoSimPaperPlots:NoAiiOnlyBaseline', ...
            'AI-only baseline model not found. Train AI-only model first or provide AI-only prediction columns.');
    end

    S = load(char(modelPath), 'model');
    if ~isfield(S, 'model')
        error('AutoSimPaperPlots:InvalidAiiOnlyModel', 'Invalid AI-only model file: %s', char(modelPath));
    end
    model = S.model;

    featureNames = string(cfgModel.model.feature_names(:));
    if isfield(model, 'feature_names') && ~isempty(model.feature_names)
        featureNames = string(model.feature_names(:));
    end
    featureCount = numel(featureNames);

    X = zeros(height(tbl), featureCount);
    for i = 1:featureCount
        fn = char(featureNames(i));
        if ismember(fn, tbl.Properties.VariableNames)
            col = tbl.(fn);
            if isnumeric(col) || islogical(col)
                X(:, i) = double(col);
            else
                X(:, i) = str2double(string(col));
            end
        else
            X(:, i) = autosimPaperResolveFeatureFallback(tbl, fn);
        end
    end
    X(~isfinite(X)) = 0.0;

    [predLabel, ~] = autosimPredictGaussianNB(model, X, cfgModel);
    predLand = (normalizeActionLabel(predLabel) == "AttemptLanding");
end

function v = autosimPaperResolveFeatureFallback(T, featureName)
fallbackMap = struct( ...
    'final_roll_deg', {{'mean_abs_roll_deg', 'final_abs_roll_deg'}}, ...
    'final_pitch_deg', {{'mean_abs_pitch_deg', 'final_abs_pitch_deg'}}, ...
    'final_vz', {{'mean_abs_vz', 'max_abs_vz'}}, ...
    'final_tag_error', {{'mean_tag_error', 'max_tag_error'}}, ...
    'wind_velocity_x', {{'wind_velocity'}}, ...
    'wind_velocity_y', {{'wind_velocity'}}, ...
    'wind_acceleration_x', {{'wind_acceleration'}}, ...
    'wind_acceleration_y', {{'wind_acceleration'}} ...
    );

if ~isfield(fallbackMap, featureName)
    v = zeros(height(T), 1);
    return;
end

alts = fallbackMap.(featureName);
for iAlt = 1:numel(alts)
    fn = alts{iAlt};
    if ismember(fn, T.Properties.VariableNames)
        col = T.(fn);
        if isnumeric(col) || islogical(col)
            v = double(col);
        else
            v = str2double(string(col));
        end
        v(~isfinite(v)) = 0.0;
        return;
    end
end

v = zeros(height(T), 1);
end


function modelPathOut = autosimPaperResolveModelPath(modelPathIn, rootDir, defaultModelRoot, modelType)
if strlength(string(modelPathIn)) > 0
    modelPathOut = string(modelPathIn);
    if ~isfile(char(modelPathOut))
        error('AutoSimPaperPlots:ModelPathNotFound', ...
            'Specified model path does not exist: %s', char(modelPathOut));
    end
    return;
end

if nargin < 4 || isempty(modelType)
    modelType = "";
end

roots = string(defaultModelRoot);
parallelRoot = fullfile(rootDir, 'parallel_runs');
if isfolder(parallelRoot)
    runDirs = dir(parallelRoot);
    runDirs = runDirs([runDirs.isdir]);
    runDirs = runDirs(~ismember({runDirs.name}, {'.', '..'}));
    if ~isempty(runDirs)
        [~, ord] = sort([runDirs.datenum], 'descend');
        for i = 1:numel(ord)
            cand = fullfile(runDirs(ord(i)).folder, runDirs(ord(i)).name, 'output', 'models');
            if isfolder(cand)
                roots(end+1, 1) = string(cand); %#ok<AGROW>
                break;
            end
        end
    end
end
roots = unique(roots, 'stable');

files = autosimPaperCollectModelFiles(char(roots(1)), modelType);
for i = 2:numel(roots)
    root = char(roots(i));
    if ~isfolder(root)
        continue;
    end
    d = autosimPaperCollectModelFiles(root, modelType);
    if isempty(d)
        continue;
    end
    if isempty(files)
        files = d;
    else
        files = [files; d]; %#ok<AGROW>
    end
end

if strlength(string(modelType)) > 0
    modelType = lower(string(modelType));
    modelTypePattern = sprintf('autosim_model_%s_', modelType);
    filtered = struct('folder', {}, 'name', {}, 'datenum', {});
    for i = 1:numel(files)
        if contains(files(i).name, modelTypePattern)
            if isempty(filtered)
                filtered = files(i);
            else
                filtered(end+1) = files(i); %#ok<AGROW>
            end
        end
    end
    if ~isempty(filtered)
        files = filtered;
    end
end

if isempty(files)
    if strlength(string(modelType)) > 0
        error('AutoSimPaperPlots:NoModel', ...
            'No model file found for type "%s" under discovered model roots.', modelType);
    else
        error('AutoSimPaperPlots:NoModel', ...
            'No model file found under discovered model roots.');
    end
end

[~, idx] = max([files.datenum]);
modelPathOut = string(fullfile(files(idx).folder, files(idx).name));
end

function files = autosimPaperCollectModelFiles(root, modelType)
files = struct('folder', {}, 'name', {}, 'datenum', {});
if ~isfolder(root)
    return;
end

d1 = dir(fullfile(root, '**', 'autosim_model_final_*.mat'));
d2 = dir(fullfile(root, '**', 'autosim_model_*.mat'));
d = [d1; d2];
if isempty(d)
    return;
end

if strlength(string(modelType)) > 0
    modelType = lower(string(modelType));
    modelTypePattern = sprintf('autosim_model_%s_', modelType);
    filtered = struct('folder', {}, 'name', {}, 'datenum', {});
    for i = 1:numel(d)
        if contains(d(i).name, modelTypePattern)
            if isempty(filtered)
                filtered = d(i);
            else
                filtered(end+1) = d(i); %#ok<AGROW>
            end
        end
    end
    d = filtered;
end

files = d;
end


function b = buildThresholdBaseline(tbl)
    n = height(tbl);
    gtSafe = buildGtSafe(tbl);

    wind = pickNumeric(tbl, {'mean_wind_speed','wind_speed_cmd','max_wind_speed'}, nan(n,1));
    tagErr = pickNumeric(tbl, {'max_tag_error','mean_tag_error','final_tag_error'}, nan(n,1));
    rollAbs = pickNumeric(tbl, {'mean_abs_roll_deg','final_abs_roll_deg'}, nan(n,1));
    pitchAbs = pickNumeric(tbl, {'mean_abs_pitch_deg','final_abs_pitch_deg'}, nan(n,1));

    [hoverWindLimit, landingWindLimit, windLimitMeta] = estimateWindPhysicsLimit(tbl);

    safeMask = gtSafe & isfinite(wind) & isfinite(tagErr);
    if sum(safeMask) >= 20
        windThrData = prctile(wind(safeMask), 80);
        tagThr = prctile(tagErr(safeMask), 80);
    else
        windThrData = 1.2;
        tagThr = 0.12;
    end

    windThr = windThrData;
    if isfinite(landingWindLimit) && landingWindLimit > 0
        windThr = min(windThr, landingWindLimit);
    end

    if sum(gtSafe & isfinite(rollAbs)) >= 20
        rollThr = prctile(rollAbs(gtSafe & isfinite(rollAbs)), 80);
    else
        rollThr = 5.0;
    end

    if sum(gtSafe & isfinite(pitchAbs)) >= 20
        pitchThr = prctile(pitchAbs(gtSafe & isfinite(pitchAbs)), 80);
    else
        pitchThr = 5.0;
    end

    pred = isfinite(wind) & isfinite(tagErr) & isfinite(rollAbs) & isfinite(pitchAbs) & ...
           (wind <= windThr) & (tagErr <= tagThr) & (rollAbs <= rollThr) & (pitchAbs <= pitchThr);

    b = struct();
    b.predLand = pred;
    b.risk_ref = struct('wind_threshold', windThr, 'tag_error_reference', tagThr);
    b.info = struct( ...
        'baseline_source', "threshold_rule_based", ...
        'model_path', "", ...
        'feature_count', 4, ...
        'n_samples', n);
    b.thresholds = struct( ...
        'wind_threshold_data', windThrData, ...
        'wind_threshold', windThr, ...
        'hover_wind_limit', hoverWindLimit, ...
        'landing_wind_limit', landingWindLimit, ...
        'tag_error_threshold', tagThr, ...
        'roll_threshold_deg', rollThr, ...
        'pitch_threshold_deg', pitchThr, ...
        'mass_kg', windLimitMeta.mass_kg, ...
        'max_total_thrust_n', windLimitMeta.max_total_thrust_n, ...
        'thrust_margin_n', windLimitMeta.thrust_margin_n, ...
        'air_density_kgpm3', windLimitMeta.air_density_kgpm3, ...
        'drag_coefficient', windLimitMeta.drag_coefficient, ...
        'frontal_area_m2', windLimitMeta.frontal_area_m2, ...
        'landing_limit_factor', windLimitMeta.landing_limit_factor);
end


function p = buildOntologyThresholdPolicy(tbl)
    n = height(tbl);
    fallbackPred = buildDecision(tbl, 'pred_decision', 'landing_cmd_time');
    if numel(fallbackPred) ~= n
        fallbackPred = false(n, 1);
    end
    score = buildOntologyDecisionScore(tbl, fallbackPred);
    score = min(1.0, max(0.0, score(:)));
    cut = 0.55;

    % Some runs store score as landing confidence, others as risk score.
    % Auto-detect polarity from GT labels when available.
    pred = score >= cut;
    scoreDirection = "high_is_land";
    cutSource = "fixed_default";
    autoCalibrateCutoff = autosimPaperEnvBool('AUTOSIM_PAPER_AUTO_CALIBRATE_CUTOFF', false);
    gtSafe = buildGtSafe(tbl);
    if numel(gtSafe) == n
        safeMask = gtSafe(:);
        unsafeMask = ~safeMask;
        if any(safeMask) && any(unsafeMask)
            safeMean = mean(score(safeMask), 'omitnan');
            unsafeMean = mean(score(unsafeMask), 'omitnan');
            if isfinite(safeMean) && isfinite(unsafeMean) && (safeMean < unsafeMean)
                pred = score < cut;
                scoreDirection = "high_is_risk";
            end

            if autoCalibrateCutoff
                finiteScore = score(isfinite(score));
                if ~isempty(finiteScore)
                    cand = unique(finiteScore);
                    if numel(cand) > 250
                        q = linspace(0, 1, 250);
                        cand = unique(quantile(finiteScore, q));
                    end

                    bestBal = -inf;
                    bestCut = cut;
                    bestPred = pred;

                    for i = 1:numel(cand)
                        c = cand(i);
                        if scoreDirection == "high_is_risk"
                            predCand = score < c;
                        else
                            predCand = score >= c;
                        end

                        tp = sum(predCand & gtSafe);
                        fp = sum(predCand & ~gtSafe);
                        fn = sum(~predCand & gtSafe);
                        tn = sum(~predCand & ~gtSafe);

                        rec = safeDiv(tp, tp + fn);
                        spe = safeDiv(tn, tn + fp);
                        bal = mean([rec, spe], 'omitnan');

                        if ~isfinite(bal)
                            continue;
                        end

                        if (bal > bestBal) || (abs(bal - bestBal) < 1e-12 && rec > safeDiv(sum(bestPred & gtSafe), sum(bestPred & gtSafe) + sum(~bestPred & gtSafe)))
                            bestBal = bal;
                            bestCut = c;
                            bestPred = predCand;
                        end
                    end

                    if isfinite(bestBal) && bestBal >= 0
                        cut = bestCut;
                        pred = bestPred;
                        cutSource = "auto_balanced_accuracy";
                    end
                end
            end
        end
    end

    p = struct();
    p.predLand = pred;
    p.score = score;
    p.cutoff = cut;
    p.scoreDirection = scoreDirection;
    p.cutSource = cutSource;
end


function v = pickNumeric(tbl, candidates, fallback)
    v = fallback;
    for i = 1:numel(candidates)
        fn = candidates{i};
        if ismember(fn, tbl.Properties.VariableNames)
            vv = tbl.(fn);
            if isnumeric(vv)
                v = double(vv);
                return;
            end
        end
    end
end


function v = pickBestNumericSeries(tbl, candidates, fallback)
    v = fallback;
    bestScore = -inf;
    for i = 1:numel(candidates)
        fn = candidates{i};
        if ~ismember(fn, tbl.Properties.VariableNames)
            continue;
        end
        vv = tbl.(fn);
        if ~(isnumeric(vv) || islogical(vv))
            continue;
        end
        series = double(vv(:));
        finiteMask = isfinite(series);
        finiteCount = sum(finiteMask);
        if finiteCount == 0
            continue;
        end
        spread = std(series(finiteMask));
        if ~isfinite(spread)
            spread = 0;
        end
        score = finiteCount + 0.1 * spread;
        if score > bestScore
            bestScore = score;
            v = series;
        end
    end
end


function keys = autosimPaperNormalizeBaselineList(raw)
raw = string(raw(:));
raw = lower(strtrim(raw));
raw = raw(strlength(raw) > 0);
allowed = ["threshold", "aii_only"];
keys = strings(0,1);
for i = 1:numel(raw)
    if any(raw(i) == allowed)
        keys(end+1,1) = raw(i); %#ok<AGROW>
    end
end
keys = unique(keys, 'stable');
if isempty(keys)
    keys = ["threshold"];
end
end


function dispName = autosimPaperMethodDisplayName(key, compactLabels)
if nargin < 2
    compactLabels = true;
end
switch lower(string(key))
    case "threshold"
        if compactLabels
            dispName = "Threshold";
        else
            dispName = "Physics Threshold Baseline";
        end
    case "aii_only"
        if compactLabels
            dispName = "AI";
        else
            dispName = "AI-Only baseline";
        end
    otherwise
        dispName = string(key);
end
end


function tf = autosimPaperEnvBool(name, defaultVal)
    txt = strtrim(lower(getenv(name)));
    if isempty(txt)
        tf = logical(defaultVal);
        return;
    end
    tf = any(strcmp(txt, {'1', 'true', 'yes', 'y', 'on'}));
end


function [hoverLimit, landingLimit, meta] = estimateWindPhysicsLimit(tbl)
    defaults = readDronePhysicsDefaults();

    massKg = pickScalarNumeric(tbl, {'mass_kg','drone_mass_kg','drone_mass','mass'}, defaults.mass_kg);
    g = pickScalarNumeric(tbl, {'gravity_mps2','gravity'}, 9.81);
    maxThrust = pickScalarNumeric(tbl, {'max_total_thrust_n','t_max','max_thrust_n','total_thrust_n'}, defaults.max_total_thrust_n);
    rho = pickScalarNumeric(tbl, {'air_density_kgpm3','rho_air','rho'}, defaults.air_density_kgpm3);
    cd = pickScalarNumeric(tbl, {'drag_coefficient','c_d','cd'}, defaults.drag_coefficient);
    area = pickScalarNumeric(tbl, {'frontal_area_m2','drag_area_m2','reference_area_m2','area_m2'}, defaults.frontal_area_m2);
    landingFactor = pickScalarNumeric(tbl, {'landing_limit_factor'}, defaults.landing_limit_factor);
    minMargin = pickScalarNumeric(tbl, {'min_thrust_margin_n'}, 0.5);

    margin = max(maxThrust - massKg * g, minMargin);
    denom = rho * cd * area;

    if isfinite(margin) && isfinite(denom) && denom > 0
        hoverLimit = sqrt(max(0.0, 2.0 * margin / denom));
        landingLimit = max(0.0, landingFactor) * hoverLimit;
    else
        hoverLimit = nan;
        landingLimit = nan;
    end

    meta = struct( ...
        'mass_kg', massKg, ...
        'max_total_thrust_n', maxThrust, ...
        'thrust_margin_n', margin, ...
        'air_density_kgpm3', rho, ...
        'drag_coefficient', cd, ...
        'frontal_area_m2', area, ...
        'landing_limit_factor', landingFactor);
end


function d = readDronePhysicsDefaults()
    d = struct( ...
        'mass_kg', 1.4, ...
        'max_total_thrust_n', 24.0, ...
        'air_density_kgpm3', 1.225, ...
        'drag_coefficient', 1.10, ...
        'frontal_area_m2', 0.075, ...
        'landing_limit_factor', 0.5);

    thisDir = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(thisDir);

    yamlPath = fullfile(repoRoot, 'sjtu_drone_bringup', 'config', 'drone.yaml');
    urdfPath = fullfile(repoRoot, 'sjtu_drone_description', 'urdf', 'sjtu_drone.urdf');
    sdfPath = fullfile(repoRoot, 'sjtu_drone_description', 'models', 'sjtu_drone', 'sjtu_drone.sdf');

    if isfile(yamlPath)
        d.max_total_thrust_n = firstFinite([readYamlScalar(yamlPath, 'maxForce'), d.max_total_thrust_n]);
        d.mass_kg = firstFinite([readYamlScalar(yamlPath, 'mass_kg'), readYamlScalar(yamlPath, 'mass'), d.mass_kg]);
        d.frontal_area_m2 = firstFinite([readYamlScalar(yamlPath, 'frontal_area_m2'), readYamlScalar(yamlPath, 'drag_area_m2'), d.frontal_area_m2]);
        d.drag_coefficient = firstFinite([readYamlScalar(yamlPath, 'drag_coefficient'), readYamlScalar(yamlPath, 'cd'), d.drag_coefficient]);
        d.air_density_kgpm3 = firstFinite([readYamlScalar(yamlPath, 'air_density_kgpm3'), d.air_density_kgpm3]);
        d.landing_limit_factor = firstFinite([readYamlScalar(yamlPath, 'landing_limit_factor'), d.landing_limit_factor]);
    end

    if isfile(urdfPath)
        d.mass_kg = firstFinite([readXmlAttributeScalar(urdfPath, '<mass', 'value'), d.mass_kg]);
    end

    if isfile(sdfPath)
        d.mass_kg = firstFinite([readXmlTagScalar(sdfPath, 'mass'), d.mass_kg]);
        d.max_total_thrust_n = firstFinite([readXmlTagScalar(sdfPath, 'maxForce'), d.max_total_thrust_n]);
    end
end


function v = pickScalarNumeric(tbl, candidates, fallback)
    v = fallback;
    for i = 1:numel(candidates)
        fn = candidates{i};
        if ~ismember(fn, tbl.Properties.VariableNames)
            continue;
        end
        x = tbl.(fn);
        if ~isnumeric(x)
            continue;
        end
        x = double(x(:));
        x = x(isfinite(x));
        if ~isempty(x)
            v = median(x);
            return;
        end
    end
end


function val = readYamlScalar(filePath, key)
    val = nan;
    try
        txt = fileread(filePath);
    catch
        return;
    end
    pat = ['(?m)^\s*' regexptranslate('escape', key) '\s*:\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*$'];
    tok = regexp(txt, pat, 'tokens', 'once');
    if ~isempty(tok)
        num = str2double(tok{1});
        if isfinite(num)
            val = num;
        end
    end
end


function val = readXmlTagScalar(filePath, tagName)
    val = nan;
    try
        txt = fileread(filePath);
    catch
        return;
    end
    pat = ['<' regexptranslate('escape', tagName) '>\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*</' regexptranslate('escape', tagName) '>'];
    tok = regexp(txt, pat, 'tokens', 'once');
    if ~isempty(tok)
        num = str2double(tok{1});
        if isfinite(num)
            val = num;
        end
    end
end


function val = readXmlAttributeScalar(filePath, tagHead, attrName)
    val = nan;
    try
        txt = fileread(filePath);
    catch
        return;
    end
    pat = [regexptranslate('escape', tagHead) '[^>]*' regexptranslate('escape', attrName) '\s*=\s*"([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)"'];
    tok = regexp(txt, pat, 'tokens', 'once');
    if ~isempty(tok)
        num = str2double(tok{1});
        if isfinite(num)
            val = num;
        end
    end
end


function v = firstFinite(values)
    v = nan;
    values = double(values(:));
    for i = 1:numel(values)
        if isfinite(values(i))
            v = values(i);
            return;
        end
    end
end


function m = evalDecision(gtSafe, predLand)
    gt = logical(gtSafe(:));
    pr = logical(predLand(:));

    m.tp = sum(pr & gt);
    m.fp = sum(pr & ~gt);
    m.fn = sum(~pr & gt);
    m.tn = sum(~pr & ~gt);
    m.nValid = m.tp + m.fp + m.fn + m.tn;

    m.accuracy = safeDiv(m.tp + m.tn, m.nValid);
    m.precision = safeDiv(m.tp, m.tp + m.fp);
    m.recall = safeDiv(m.tp, m.tp + m.fn);
    m.specificity = safeDiv(m.tn, m.tn + m.fp);
    vals = [m.recall, m.specificity];
    vals = vals(isfinite(vals));
    if isempty(vals)
        m.balancedAccuracy = nan;
    else
        m.balancedAccuracy = mean(vals);
    end
    if isfinite(m.precision) && isfinite(m.recall) && (m.precision + m.recall) > 0
        m.f1 = 2 * m.precision * m.recall / (m.precision + m.recall);
    else
        m.f1 = nan;
    end
    m.unsafeLandingRate = safeDiv(m.fp, m.fp + m.tn);
end


function m = evalTrajectory(tbl, executeMask)
    if nargin < 2 || isempty(executeMask)
        executeMask = true(height(tbl), 1);
    end
    executeMask = logical(executeMask(:));
    n = height(tbl);
    if numel(executeMask) ~= n
        executeMask = true(n, 1);
    end

    [xyErr, zErr, quality, mode] = trajectoryErrorSeries(tbl);
    validMask = (isfinite(xyErr) | isfinite(zErr) | isfinite(quality));
    useMask = executeMask & validMask;

    m = struct();
    m.nValid = sum(validMask);
    m.nExecuted = sum(useMask);
    m.executionRate = safeDiv(m.nExecuted, max(1, m.nValid));
    m.mode = mode;

    m.xyRmse = localRmse(xyErr(useMask));
    m.zRmse = localRmse(zErr(useMask));
    m.xyMae = localMae(xyErr(useMask));
    m.zMae = localMae(zErr(useMask));
    m.qualityMean = localMean(quality(useMask));
    m.qualityStd = localStd(quality(useMask));

    ex = xyErr(useMask);
    ez = zErr(useMask);
    ok = isfinite(ex) | isfinite(ez);
    ex(~isfinite(ex)) = 0.0;
    ez(~isfinite(ez)) = 0.0;
    if any(ok)
        m.xyzRmse = sqrt(mean(ex(ok).^2 + ez(ok).^2));
    else
        m.xyzRmse = nan;
    end

    if any(useMask)
        xyGate = (~isfinite(xyErr(useMask))) | (xyErr(useMask) <= 0.35);
        zGate = (~isfinite(zErr(useMask))) | (zErr(useMask) <= 0.20);
        m.successRate = mean(double(xyGate & zGate));
    else
        m.successRate = nan;
    end

    scoreParts = [ ...
        1.0 - normalizeErrScalar(m.xyRmse, 0.6), ...
        1.0 - normalizeErrScalar(m.zRmse, 0.4), ...
        m.qualityMean, ...
        m.successRate, ...
        m.executionRate ...
    ];
    scoreParts = scoreParts(isfinite(scoreParts));
    if isempty(scoreParts)
        m.followScore = nan;
    else
        m.followScore = min(1.0, max(0.0, mean(scoreParts)));
    end
end


function t = cumulativeTrajectoryTrend(tbl, executeMask)
    n = height(tbl);
    t.followScore = nan(n, 1);
    t.xyzRmse = nan(n, 1);

    for i = 1:n
        m = evalTrajectory(tbl(1:i, :), executeMask(1:i));
        t.followScore(i) = m.followScore;
        t.xyzRmse(i) = m.xyzRmse;
    end
end


function [xyErr, zErr, quality, mode] = trajectoryErrorSeries(tbl)
    n = height(tbl);
    xyErr = nan(n, 1);
    zErr = nan(n, 1);
    quality = nan(n, 1);
    mode = "unavailable";

    hasTrajTarget = ismember('trajectory_target_x', tbl.Properties.VariableNames) && ...
        ismember('trajectory_target_y', tbl.Properties.VariableNames) && ...
        ismember('trajectory_target_z', tbl.Properties.VariableNames);
    hasFinalXY = ismember('final_x', tbl.Properties.VariableNames) && ismember('final_y', tbl.Properties.VariableNames);

    if hasTrajTarget && hasFinalXY
        x = pickNumeric(tbl, {'final_x'}, nan(n,1));
        y = pickNumeric(tbl, {'final_y'}, nan(n,1));
        tx = pickNumeric(tbl, {'trajectory_target_x'}, nan(n,1));
        ty = pickNumeric(tbl, {'trajectory_target_y'}, nan(n,1));
        xyErr = hypot(x - tx, y - ty);
        mode = "trajectory_target_error";
    elseif ismember('mean_tag_error', tbl.Properties.VariableNames)
        xyErr = abs(pickNumeric(tbl, {'mean_tag_error', 'max_tag_error'}, nan(n,1)));
        mode = "proxy_tag_stability";
    end

    if ismember('trajectory_target_z', tbl.Properties.VariableNames) && ismember('final_altitude', tbl.Properties.VariableNames)
        zNow = pickNumeric(tbl, {'final_altitude'}, nan(n,1));
        zTgt = pickNumeric(tbl, {'trajectory_target_z'}, nan(n,1));
        zErr = abs(zNow - zTgt);
        if mode == "unavailable"
            mode = "trajectory_target_error";
        end
    elseif ismember('final_altitude', tbl.Properties.VariableNames) && ismember('hover_height_cmd', tbl.Properties.VariableNames)
        zNow = pickNumeric(tbl, {'final_altitude'}, nan(n,1));
        zCmd = pickNumeric(tbl, {'hover_height_cmd'}, nan(n,1));
        zErr = abs(zNow - zCmd);
        if mode == "unavailable"
            mode = "proxy_hover_altitude";
        end
    elseif ismember('stability_std_z', tbl.Properties.VariableNames)
        zErr = abs(pickNumeric(tbl, {'stability_std_z'}, nan(n,1)));
        if mode == "unavailable"
            mode = "proxy_tag_stability";
        end
    end

    if ismember('trajectory_quality', tbl.Properties.VariableNames)
        quality = pickNumeric(tbl, {'trajectory_quality'}, nan(n,1));
    else
        qx = 1.0 - normalizeErrSeries(xyErr, 0.6);
        qz = 1.0 - normalizeErrSeries(zErr, 0.4);
        quality = nanmean([qx qz], 2);
    end
    quality = min(1.0, max(0.0, quality));
end


function v = normalizeErrScalar(err, scale)
    if ~(isfinite(err) && isfinite(scale) && scale > 0)
        v = nan;
        return;
    end
    v = min(1.0, max(0.0, abs(err) / scale));
end


function out = normalizeErrSeries(err, scale)
    out = nan(size(err));
    if ~(isfinite(scale) && scale > 0)
        return;
    end
    mask = isfinite(err);
    out(mask) = min(1.0, max(0.0, abs(err(mask)) ./ scale));
end


function v = localRmse(x)
    x = x(isfinite(x));
    if isempty(x)
        v = nan;
    else
        v = sqrt(mean(x.^2));
    end
end


function v = localMae(x)
    x = x(isfinite(x));
    if isempty(x)
        v = nan;
    else
        v = mean(abs(x));
    end
end


function v = localMean(x)
    x = x(isfinite(x));
    if isempty(x)
        v = nan;
    else
        v = mean(x);
    end
end


function v = localStd(x)
    x = x(isfinite(x));
    if numel(x) < 2
        v = nan;
    else
        v = std(x);
    end
end


function t = cumulativeTrend(gtSafe, predLand)
    n = numel(gtSafe);
    t.accuracy = nan(n,1);
    t.unsafeLandingRate = nan(n,1);

    gt = logical(gtSafe(:));
    pr = logical(predLand(:));

    for i = 1:n
        m = evalDecision(gt(1:i), pr(1:i));
        t.accuracy(i) = m.accuracy;
        t.unsafeLandingRate(i) = m.unsafeLandingRate;
    end
end


function y = smoothAdaptive(x)
    n = numel(x);
    w = max(5, floor(n / 35));
    if mod(w,2) == 0
        w = w + 1;
    end
    if w > n
        w = max(1, 2 * floor(n/2) + 1);
    end
    if w <= 1
        y = x;
    else
        y = movmean(x, w, 'omitnan');
    end
end


function [xRisk, yRisk] = pickRiskAxes(tbl)
    n = height(tbl);
    xRisk = pickBestNumericSeries(tbl, { ...
        'mean_wind_risk_raw', 'wind_risk_raw', 'mean_wind_body_risk', 'wind_body_risk', ...
        'mean_wind_speed', 'wind_speed_cmd', 'max_wind_speed', 'r_body'}, zeros(n,1));
    yRisk = pickBestNumericSeries(tbl, { ...
        'mean_wind_gust_risk', 'wind_gust_risk', 'max_tag_error', 'mean_tag_error', ...
        'final_tag_error', 'r_gust', 's_align', 's_visual'}, zeros(n,1));

    if all(~isfinite(xRisk))
        xRisk = (1:n)';
    end
    if all(~isfinite(yRisk))
        yRisk = zeros(n,1);
    end

    xRisk(~isfinite(xRisk)) = medianOmitNan(xRisk);
    yRisk(~isfinite(yRisk)) = medianOmitNan(yRisk);
end


function cls = classifyOutcome(gtSafe, predLand)
    n = numel(gtSafe);
    cls = strings(n,1);
    gt = logical(gtSafe(:));
    pr = logical(predLand(:));
    cls(pr & gt) = "TP";
    cls(pr & ~gt) = "FP";
    cls(~pr & gt) = "FN";
    cls(~pr & ~gt) = "TN";
end


function drawClass(ax, x, y, mask, colorVal, label)
    if ~any(mask)
        return;
    end
    scatter(ax, x(mask), y(mask), 30, 'filled', ...
        'MarkerFaceColor', colorVal, 'MarkerEdgeColor', [0.08 0.08 0.08], ...
        'MarkerFaceAlpha', 0.72, 'MarkerEdgeAlpha', 0.45, 'DisplayName', label);
    hold(ax, 'on');
end


function annotateTotalScenario(ax, nTotal, baseFont)
    if ~isgraphics(ax)
        return;
    end
    if ~isfinite(nTotal) || nTotal <= 0
        return;
    end
    fs = max(10, min(16, round(baseFont * 0.55)));
    text(ax, 0.99, 0.98, sprintf('N=%d', round(nTotal)), ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', fs, ...
        'FontWeight', 'bold', ...
        'Color', [0.20 0.20 0.20], ...
        'BackgroundColor', [1 1 1], ...
        'Margin', 2, ...
        'Clipping', 'on');
end


function plotConfusion(ax, m, ttl)
    fs = 36;
    cm = [m.tp m.fn; m.fp m.tn];
    imagesc(ax, cm);
    cmap = parula(256);
    colormap(ax, cmap);
    cb = colorbar(ax);
    cb.FontSize = fs;
    axis(ax, 'equal');
    axis(ax, 'tight');
    xticks(ax, 1:2);
    yticks(ax, 1:2);
    xticklabels(ax, {'Land', 'Hold'});
    yticklabels(ax, {'Land', 'Hold'});
    xlabel(ax, 'Pred', 'FontSize', fs);
    ylabel(ax, 'GT', 'FontSize', fs);
    title(ax, ttl, 'FontSize', fs);
    set(ax, 'FontSize', fs);

    cMin = min(cm(:));
    cMax = max(cm(:));
    cSpan = max(cMax - cMin, eps);

    for r = 1:2
        for c = 1:2
            % Choose text color by rendered cell brightness:
            % bright (yellow) -> black text, dark -> white text.
            idx = 1 + round((size(cmap, 1) - 1) * (cm(r,c) - cMin) / cSpan);
            idx = min(max(idx, 1), size(cmap, 1));
            rgb = cmap(idx, :);
            luminance = 0.2126 * rgb(1) + 0.7152 * rgb(2) + 0.0722 * rgb(3);
            if luminance >= 0.55
                txtColor = [0.10 0.10 0.10];
            else
                txtColor = [1 1 1];
            end
            text(ax, c, r, num2str(cm(r,c)), 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', txtColor, 'FontWeight', 'bold', 'FontSize', fs);
        end
    end
end


function v = safeDiv(a, b)
    if b <= 0
        v = nan;
    else
        v = a / b;
    end
end


function v = safeDivVec(a, b)
    v = nan(size(a));
    mask = isfinite(a) & isfinite(b) & (b > 0);
    if any(mask)
        v(mask) = a(mask) ./ b(mask);
    end
end


function v = safeDivForPlot(a, b, ratioCap)
    if a <= 0 && b <= 0
        v = 0;
        return;
    end

    if b <= 0
        v = ratioCap;
        return;
    end

    v = a / b;
    if ~isfinite(v)
        v = nan;
        return;
    end

    if nargin >= 3 && isfinite(ratioCap) && ratioCap > 0
        if v > ratioCap
            v = ratioCap;
        end
    end
end


function p = ratioToPairPercent(r)
p = nan(size(r));
mask = isfinite(r) & (r >= 0);
if ~any(mask)
    return;
end
p(mask) = 100 .* (r(mask) ./ (1 + r(mask)));
end


function dumpMetric(fid, m)
    if isfield(m, 'followScore')
        fprintf(fid, 'n_valid: %d\n', m.nValid);
        fprintf(fid, 'n_executed: %d\n', m.nExecuted);
        fprintf(fid, 'execution_rate: %.4f\n', m.executionRate);
        fprintf(fid, 'trajectory_metric_mode: %s\n', char(string(m.mode)));
        fprintf(fid, 'trajectory_follow_score: %.4f\n', m.followScore);
        fprintf(fid, 'trajectory_success_rate: %.4f\n', m.successRate);
        fprintf(fid, 'trajectory_xyz_rmse_m: %.4f\n', m.xyzRmse);
        fprintf(fid, 'trajectory_xy_rmse_m: %.4f\n', m.xyRmse);
        fprintf(fid, 'trajectory_z_rmse_m: %.4f\n', m.zRmse);
        fprintf(fid, 'trajectory_xy_mae_m: %.4f\n', m.xyMae);
        fprintf(fid, 'trajectory_z_mae_m: %.4f\n', m.zMae);
        fprintf(fid, 'trajectory_quality_mean: %.4f\n', m.qualityMean);
        fprintf(fid, 'trajectory_quality_std: %.4f\n', m.qualityStd);
        return;
    end

    fprintf(fid, 'n_valid: %d\n', m.nValid);
    fprintf(fid, 'accuracy: %.4f\n', m.accuracy);
    fprintf(fid, 'precision: %.4f\n', m.precision);
    fprintf(fid, 'safe_recall: %.4f\n', m.recall);
    fprintf(fid, 'unsafe_reject: %.4f\n', m.specificity);
    fprintf(fid, 'balanced_accuracy: %.4f\n', m.balancedAccuracy);
    fprintf(fid, 'f1: %.4f\n', m.f1);
    fprintf(fid, 'unsafe_landing_rate: %.4f\n', m.unsafeLandingRate);
    fprintf(fid, 'TP=%d FP=%d FN=%d TN=%d\n', m.tp, m.fp, m.fn, m.tn);
end


function label = normalizeActionLabel(x)
    s = lower(strtrim(string(x)));
    label = repmat("Unknown", size(s));

    attemptMask = (s == "attemptlanding") | (s == "attempt_landing") | (s == "land") | ...
        (s == "landing") | (s == "safe") | (s == "stable") | (s == "safetoland") | ...
        (s == "attempt_landing_recommended") | (s == "clear_to_land") | ...
        (s == "proceed") | (s == "1") | (s == "true");

    holdMask = (s == "holdlanding") | (s == "hold_landing") | (s == "hold") | ...
        (s == "abort") | (s == "abortlanding") | (s == "delaylanding") | ...
        (s == "continuehover") | (s == "reapproach") | (s == "descend") | ...
        (s == "cancellanding") | (s == "goaround") | (s == "unsafe") | ...
        (s == "unstable") | (s == "unsafetoland") | (s == "stop") | ...
        (s == "hold_landing_recommended") | (s == "abort_recommended") | ...
        (s == "monitor_and_reassess") | (s == "0") | (s == "false");

    label(attemptMask) = "AttemptLanding";
    label(holdMask) = "HoldLanding";
end


function m = medianOmitNan(x)
    x = x(isfinite(x));
    if isempty(x)
        m = 0;
    else
        m = median(x);
    end
end


function [riskTotal, windNorm, gustNorm] = buildWindRiskSeries(tbl, thresholds)
    n = height(tbl);

    riskRawNew = pickBestNumericSeries(tbl, {'mean_wind_risk_raw','wind_risk_raw','r_body'}, nan(n,1));
    bodyRiskNew = pickBestNumericSeries(tbl, {'mean_wind_body_risk','wind_body_risk','r_body'}, nan(n,1));
    gustRiskNew = pickBestNumericSeries(tbl, {'mean_wind_gust_risk','wind_gust_risk','r_gust'}, nan(n,1));

    hasNewRisk = any(isfinite(riskRawNew)) || any(isfinite(bodyRiskNew)) || any(isfinite(gustRiskNew));
    if hasNewRisk
        risk01 = fillSeriesNan(riskRawNew);
        body01 = fillSeriesNan(bodyRiskNew);
        gust01 = fillSeriesNan(gustRiskNew);

        if ~any(isfinite(bodyRiskNew))
            body01 = risk01;
        end
        if ~any(isfinite(gustRiskNew))
            gust01 = risk01;
        end

        riskTotal = min(2.0, max(0.0, 2.0 * risk01));
        windNorm = min(2.0, max(0.0, 2.0 * body01));
        gustNorm = min(2.0, max(0.0, 2.0 * gust01));
        return;
    end

    windRaw = pickNumeric(tbl, ...
        {'mean_wind_speed','wind_speed_cmd','max_wind_speed','wind_speed','wind_mps','r_body'}, ...
        nan(n,1));
    gustRaw = pickNumeric(tbl, ...
        {'gust_speed','max_gust_speed','wind_gust_speed','gust_mps','max_wind_speed','r_gust'}, ...
        nan(n,1));

    hasExplicitGust = any(isfinite(gustRaw));

    windRaw = fillSeriesNan(windRaw);
    gustRaw = fillSeriesNan(gustRaw);

    % If explicit gust data is absent, approximate gustiness from wind deviation.
    if ~hasExplicitGust || all(abs(gustRaw - windRaw) < 1e-9)
        gustRaw = max(0, windRaw - movmean(windRaw, max(5, 2 * floor(n / 30) + 1), 'omitnan'));
    end

    windThr = 1.0;
    if isfield(thresholds, 'wind_threshold') && isfinite(thresholds.wind_threshold) && thresholds.wind_threshold > 0
        windThr = thresholds.wind_threshold;
    elseif isfield(thresholds, 'wind_threshold_data') && isfinite(thresholds.wind_threshold_data) && thresholds.wind_threshold_data > 0
        windThr = thresholds.wind_threshold_data;
    end

    gustScale = max(0.5, 0.6 * windThr);
    windNorm = min(2.0, max(0.0, windRaw ./ windThr));
    gustNorm = min(2.0, max(0.0, gustRaw ./ gustScale));
    riskTotal = min(2.0, 0.65 * windNorm + 0.35 * gustNorm);
end


function x = fillSeriesNan(x)
    x = double(x(:));
    if all(~isfinite(x))
        x = zeros(size(x));
        return;
    end
    mid = medianOmitNan(x);
    x(~isfinite(x)) = mid;
end


function s = buildOntologyDecisionScore(tbl, predLand)
    n = height(tbl);
    s = pickNumeric(tbl, ...
        {'pred_score','landing_feasibility','pred_stable_prob','model_stable_prob','stable_prob','pred_prob_stable','decision_score'}, ...
        nan(n,1));

    if any(isfinite(s))
        s = fillSeriesNan(s);
        s = min(1.0, max(0.0, s));
    else
        % Fallback: binary decision only if no confidence field exists.
        s = double(predLand(:));
    end
end


function s = buildThresholdDecisionScore(tbl, thresholds, predLand)
    n = height(tbl);
    wind = fillSeriesNan(pickNumeric(tbl, {'mean_wind_speed','wind_speed_cmd','max_wind_speed'}, nan(n,1)));
    tagErr = fillSeriesNan(pickNumeric(tbl, {'max_tag_error','mean_tag_error','final_tag_error'}, nan(n,1)));
    rollAbs = fillSeriesNan(pickNumeric(tbl, {'mean_abs_roll_deg','final_abs_roll_deg'}, nan(n,1)));
    pitchAbs = fillSeriesNan(pickNumeric(tbl, {'mean_abs_pitch_deg','final_abs_pitch_deg'}, nan(n,1)));

    windThr = pickThreshold(thresholds, {'wind_threshold','wind_threshold_data'}, 1.8);
    tagThr = pickThreshold(thresholds, {'tag_error_threshold'}, 0.20);
    rollThr = pickThreshold(thresholds, {'roll_threshold_deg'}, 8.0);
    pitchThr = pickThreshold(thresholds, {'pitch_threshold_deg'}, 8.0);

    windScore = normalizedSafeScore(wind, windThr);
    tagScore = normalizedSafeScore(tagErr, tagThr);
    rollScore = normalizedSafeScore(rollAbs, rollThr);
    pitchScore = normalizedSafeScore(pitchAbs, pitchThr);

    s = 0.40 * windScore + 0.25 * tagScore + 0.175 * rollScore + 0.175 * pitchScore;
    if ~any(isfinite(s))
        s = double(predLand(:));
    end
    s = min(1.0, max(0.0, s));
end


function thr = pickThreshold(thresholds, names, fallback)
    thr = fallback;
    for i = 1:numel(names)
        nm = names{i};
        if isfield(thresholds, nm)
            v = thresholds.(nm);
            if isfinite(v) && v > 0
                thr = v;
                return;
            end
        end
    end
end


function score = normalizedSafeScore(value, threshold)
    denom = max(1e-6, threshold);
    score = 1.0 - min(1.0, max(0.0, value ./ denom));
end
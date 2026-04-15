% AutoSimValidation.m
% Standalone holdout validation using all FinalDataset records.
% - Loads all FinalDataset CSV files.
% - Uses deterministic 70/30 split.
% - Validates latest compatible model on 30% holdout split.
% - Supports both "aii_only" (AI-only) and "ontology_ai" (Ontology+AI) models.
%
% Optional variables before run:
%   modelPath (string/char): explicit model file path.
%   splitSeed (numeric): deterministic split seed.
%   autoPlot (logical): run AutoSimPaperPlots after validation.
%   validationModelTypes (string array): model types to validate {"aii_only", "ontology_ai"}.

if ~exist('autosim_keep_workspace', 'var') || ~logical(autosim_keep_workspace)
    clear;
end
clc; close all force;

rootDir = fileparts(mfilename('fullpath'));
modDir = fullfile(rootDir, 'modules');
if exist(modDir, 'dir')
    addpath(modDir);
end
coreDir = fullfile(modDir, 'core');
if exist(coreDir, 'dir')
    addpath(genpath(coreDir));
end

cfg = autosimDefaultConfig();
[cfg, ~] = autosimApplyExternalOverride(cfg, rootDir);
[cfg, ~] = autosimApplyRuntimeOverrides(cfg);
autosimEnsureDirectories(cfg);

if ~exist('splitSeed', 'var') || ~isfinite(splitSeed)
    splitSeed = 20260323;
end
if ~exist('autoPlot', 'var')
    autoPlot = false;
end
if ~exist('validationUseFullWindow', 'var')
    validationUseFullWindow = false;
end
if ~exist('modelPath', 'var')
    modelPath = "";
end
if ~exist('validationModelTypes', 'var') || isempty(validationModelTypes)
    validationModelTypes = ["aii_only", "ontology_ai"];
end

[allTbl, sourceFiles, finalRoot] = autosimLoadAllFinalDataset(rootDir); %#ok<ASGLU>
if isempty(allTbl)
    error('AutoSimValidation:NoFinalDataset', 'No FinalDataset CSV found under %s', finalRoot);
end
[allTbl, filterInfo] = autosimValidationFilterDatasetQuality(allTbl);
fprintf('[AutoSimValidation] quality filter: drop_failed_or_interrupted=%d drop_missing_wind=%d kept=%d\n', ...
    round(filterInfo.n_drop_failed_or_interrupted), round(filterInfo.n_drop_missing_wind), round(height(allTbl)));
if isempty(allTbl)
    error('AutoSimValidation:NoUsableDataset', ...
        'No usable rows remain after dataset quality filtering under %s', finalRoot);
end
allTblRawCount = height(allTbl);
[allTbl, recentNUsed] = autosimValidationApplyRecentWindow(allTbl);
allTbl = autosimEnsureOntologyFeatureColumns(allTbl, cfg);
droneMeta = autosimValidationResolveDroneMeta(cfg, allTbl);
allLabelStats = autosimValidationLabelStats(allTbl);

if logical(validationUseFullWindow)
    trainTbl = allTbl([],:);
    valTbl = allTbl;
    splitInfo = struct('train_ratio', 0.0, 'val_ratio', 1.0, 'seed', splitSeed);
else
    [trainTbl, valTbl, splitInfo] = autosimValidationSplit70_30(allTbl, 0.7, splitSeed); %#ok<ASGLU>
    if isempty(valTbl)
        error('AutoSimValidation:EmptyValidationSplit', 'Validation split is empty.');
    end
end
valLabelStats = autosimValidationLabelStats(valTbl);

validationModelTypes = string(validationModelTypes(:));
allValidationResults = struct();

for iModel = 1:numel(validationModelTypes)
    modelType = validationModelTypes(iModel);
    fprintf('\n[AutoSimValidation] ========== Validating Model Type %d/%d: %s ==========\n', ...
        iModel, numel(validationModelTypes), modelType);
    
    % Apply model type configuration
    cfgModel = autosimGetModelTypeConfig(cfg, modelType);
    
    if strlength(modelPath) > 0
        % Use explicit model path
        modelPathFull = modelPath;
    elseif evalin('base', 'exist(''trainedModelPaths'', ''var'')')
        trainedModelPaths = evalin('base', 'trainedModelPaths');
        if isstruct(trainedModelPaths) && isfield(trainedModelPaths, char(modelType))
            candidatePath = string(trainedModelPaths.(char(modelType)));
            if strlength(candidatePath) > 0 && isfile(char(candidatePath))
                modelPathFull = candidatePath;
                fprintf('[AutoSimValidation] Using trained model path from workspace: %s\n', char(modelPathFull));
            else
                modelPathFull = autosimValidationResolveModelPath("", rootDir, cfgModel.paths.model_dir, modelType);
            end
        else
            modelPathFull = autosimValidationResolveModelPath("", rootDir, cfgModel.paths.model_dir, modelType);
        end
    else
        % Search for model with specified type in filename
        modelPathFull = autosimValidationResolveModelPath("", rootDir, cfgModel.paths.model_dir, modelType);
    end
    
    if ~exist(char(modelPathFull), 'file')
        fprintf('[AutoSimValidation] Model (%s) file not found: %s (skipping)\n', modelType, modelPathFull);
        continue;
    end
    
    S = load(char(modelPathFull), 'model');
    if ~isfield(S, 'model')
        error('AutoSimValidation:InvalidModelFile', 'Model file does not contain variable "model": %s', char(modelPathFull));
    end
    model = S.model;

    [cfgModel, decisionThreshold, thresholdSource] = autosimValidationResolveDecisionThreshold(cfgModel, model, modelType);

    featureNames = string(cfgModel.model.feature_names(:));
    if isfield(model, 'feature_names') && ~isempty(model.feature_names)
        featureNames = string(model.feature_names(:));
    end

    X = zeros(height(valTbl), numel(featureNames));
    for i = 1:numel(featureNames)
        fn = char(featureNames(i));
        if ismember(fn, valTbl.Properties.VariableNames)
            col = valTbl.(fn);
            if isnumeric(col) || islogical(col)
                X(:, i) = double(col);
            else
                X(:, i) = str2double(string(col));
            end
        else
            X(:, i) = autosimValidationResolveFeatureFallback(valTbl, fn);
        end
    end
    X(~isfinite(X)) = 0.0;

    [predLabel, predScore] = autosimPredictGaussianNB(model, X, cfgModel);

    valTblModel = valTbl;
    valTblModel.pred_decision = autosimNormalizeActionLabel(predLabel);
    valTblModel.pred_score = double(predScore(:));
    
    if ~ismember('gt_safe_to_land', valTblModel.Properties.VariableNames)
        if ismember('label', valTblModel.Properties.VariableNames)
            valTblModel.gt_safe_to_land = autosimNormalizeActionLabel(valTblModel.label);
        else
            error('AutoSimValidation:MissingGroundTruth', 'Validation table has no gt_safe_to_land or label field.');
        end
    end
    
    metrics = autosimEvaluateDecisionMetrics(valTblModel);
    trajMetrics = autosimValidationEvaluateTrajectoryMetrics(valTblModel);
    
    ts = autosimTimestamp();
    runDir = fullfile(cfgModel.paths.data_root, sprintf('validation_holdout_%s_%s', char(modelType), char(ts)));
    if ~exist(runDir, 'dir')
        mkdir(runDir);
    end
    
    datasetCsv = fullfile(runDir, 'autosim_dataset_latest.csv');
    summaryCsv = fullfile(runDir, 'autosim_validation_summary.csv');
    splitCsv = fullfile(runDir, 'autosim_validation_split.csv');
    
    writetable(valTblModel, datasetCsv);
    
    sumTbl = table();
    sumTbl.created_at = string(datetime('now'));
    sumTbl.model_type = string(modelType);
    sumTbl.model_path = string(modelPathFull);
    sumTbl.n_all = height(allTbl);
    sumTbl.n_all_raw = allTblRawCount;
    if isfinite(recentNUsed) && recentNUsed > 0
        sumTbl.recent_dataset_n = round(recentNUsed);
    else
        sumTbl.recent_dataset_n = nan;
    end
    sumTbl.n_train = height(trainTbl);
    sumTbl.n_val = height(valTblModel);
    sumTbl.n_all_safe = allLabelStats.n_safe;
    sumTbl.n_all_hold = allLabelStats.n_hold;
    sumTbl.n_val_safe = valLabelStats.n_safe;
    sumTbl.n_val_hold = valLabelStats.n_hold;
    sumTbl.seed = splitSeed;
    sumTbl.decision_threshold = decisionThreshold;
    sumTbl.decision_threshold_source = thresholdSource;
    sumTbl.accuracy = metrics.accuracy;
    sumTbl.precision = metrics.precision;
    sumTbl.safe_recall = metrics.recall;
    sumTbl.unsafe_reject = metrics.specificity;
    sumTbl.balanced_accuracy = metrics.balanced_accuracy;
    sumTbl.f1 = metrics.f1;
    sumTbl.unsafe_landing_rate = metrics.unsafe_landing_rate;
    sumTbl.n_excluded_intervention = metrics.n_excluded_intervention;
    sumTbl.n_excluded_hover = metrics.n_excluded_hover;
    sumTbl.metric_primary = "trajectory_follow";
    sumTbl.trajectory_n_valid = trajMetrics.n_valid;
    sumTbl.trajectory_metric_mode = trajMetrics.mode;
    sumTbl.trajectory_follow_score = trajMetrics.follow_score;
    sumTbl.trajectory_xy_rmse_m = trajMetrics.xy_rmse_m;
    sumTbl.trajectory_z_rmse_m = trajMetrics.z_rmse_m;
    sumTbl.trajectory_xyz_rmse_m = trajMetrics.xyz_rmse_m;
    sumTbl.trajectory_xy_mae_m = trajMetrics.xy_mae_m;
    sumTbl.trajectory_z_mae_m = trajMetrics.z_mae_m;
    sumTbl.trajectory_success_rate = trajMetrics.success_rate;
    sumTbl.trajectory_quality_mean = trajMetrics.quality_mean;
    sumTbl.trajectory_quality_std = trajMetrics.quality_std;
    if droneMeta.is_multi
        sumTbl.collection_multi_drone_count = droneMeta.count;
        sumTbl.collection_mode = "multi_drone";
    end
    writetable(sumTbl, summaryCsv);
    
    splitTbl = table();
    splitTbl.created_at = string(datetime('now'));
    splitTbl.model_type = string(modelType);
    splitTbl.n_all = height(allTbl);
    splitTbl.n_all_raw = allTblRawCount;
    if isfinite(recentNUsed) && recentNUsed > 0
        splitTbl.recent_dataset_n = round(recentNUsed);
    else
        splitTbl.recent_dataset_n = nan;
    end
    splitTbl.n_train = height(trainTbl);
    splitTbl.n_val = height(valTblModel);
    splitTbl.train_ratio = splitInfo.train_ratio;
    splitTbl.val_ratio = splitInfo.val_ratio;
    splitTbl.seed = splitInfo.seed;
    if logical(validationUseFullWindow)
        splitTbl.split_mode = "full_recent_window";
    else
        splitTbl.split_mode = "stratified_70_30";
    end
    splitTbl.source_files = strjoin(sourceFiles, ';');
    if droneMeta.is_multi
        splitTbl.collection_multi_drone_count = droneMeta.count;
        splitTbl.collection_mode = "multi_drone";
    end
    writetable(splitTbl, splitCsv);
    
    fprintf('[AutoSimValidation] model (%s): %s\n', modelType, char(modelPathFull));
    if isfinite(recentNUsed) && recentNUsed > 0
        fprintf('[AutoSimValidation] recent window: last %d rows (raw=%d, used=%d)\n', round(recentNUsed), allTblRawCount, height(allTbl));
    end
    fprintf('[AutoSimValidation] all=%d train=%d val=%d (seed=%d, mode=%s)\n', ...
        height(allTbl), height(trainTbl), height(valTblModel), round(splitSeed), char(string(splitTbl.split_mode(1))));
    fprintf('[AutoSimValidation] label balance all(safe=%d,hold=%d) val(safe=%d,hold=%d)\n', ...
        round(allLabelStats.n_safe), round(allLabelStats.n_hold), round(valLabelStats.n_safe), round(valLabelStats.n_hold));
    fprintf('[AutoSimValidation] summary (%s): %s\n', modelType, summaryCsv);
    fprintf('[AutoSimValidation] decision threshold=%.4f (source=%s)\n', decisionThreshold, char(thresholdSource));
    fprintf('[AutoSimValidation] trajectory score=%.4f xyz_rmse=%.4f xy_rmse=%.4f z_rmse=%.4f success=%.4f mode=%s n=%d\n', ...
        trajMetrics.follow_score, trajMetrics.xyz_rmse_m, trajMetrics.xy_rmse_m, trajMetrics.z_rmse_m, ...
        trajMetrics.success_rate, char(trajMetrics.mode), round(trajMetrics.n_valid));
    fprintf('[AutoSimValidation] (legacy landing) accuracy=%.4f precision=%.4f recall=%.4f specificity=%.4f balanced=%.4f unsafe_landing=%.4f\n', ...
        metrics.accuracy, metrics.precision, metrics.recall, metrics.specificity, metrics.balanced_accuracy, metrics.unsafe_landing_rate);
    
    validationResult = struct();
    validationResult.modelType = string(modelType);
    validationResult.runDir = string(runDir);
    validationResult.datasetCsv = string(datasetCsv);
    validationResult.summaryCsv = string(summaryCsv);
    validationResult.splitCsv = string(splitCsv);
    validationResult.modelPath = string(modelPathFull);
    validationResult.decision_threshold = decisionThreshold;
    validationResult.decision_threshold_source = thresholdSource;
    validationResult.metrics = metrics;
    validationResult.trajectory_metrics = trajMetrics;
    
    allValidationResults.(char(modelType)) = validationResult;
end

function v = autosimValidationResolveFeatureFallback(T, featureName)
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

function [cfgOut, threshold, source] = autosimValidationResolveDecisionThreshold(cfgIn, model, modelType)
cfgOut = cfgIn;
source = "config";
threshold = 0.5;

if isfield(cfgOut, 'agent') && isstruct(cfgOut.agent) && isfield(cfgOut.agent, 'prob_land_threshold')
    thCfg = double(cfgOut.agent.prob_land_threshold);
    if isfinite(thCfg)
        threshold = thCfg;
    end
end

if isstruct(model) && isfield(model, 'decision_threshold')
    thModel = double(model.decision_threshold);
    if isfinite(thModel)
        threshold = thModel;
        source = "model";
    end
end

if source == "config"
    mt = lower(strtrim(string(modelType)));
    if mt == "ontology_ai"
        threshold = 0.20;
        source = "validation_tp_priority_default";
    end
end

threshold = max(0.01, min(0.99, threshold));
if ~isfield(cfgOut, 'agent') || ~isstruct(cfgOut.agent)
    cfgOut.agent = struct();
end
cfgOut.agent.prob_land_threshold = threshold;
end

assignin('base', 'allValidationResults', allValidationResults);

if logical(autoPlot)
    for iModel = 1:numel(validationModelTypes)
        modelType = validationModelTypes(iModel);
        if isfield(allValidationResults, char(modelType))
            result = allValidationResults.(char(modelType));
            runDir = char(result.runDir); %#ok<NASGU>
            outputDir = ""; %#ok<NASGU>
            fprintf('\n[AutoSimValidation] Generating plots for model type: %s\n', modelType);
            run(fullfile(rootDir, 'AutoSimPaperPlots.m'));
        end
    end
end


function [trainTbl, valTbl, info] = autosimValidationSplit70_30(T, trainRatio, seed)
if nargin < 2 || ~isfinite(trainRatio)
    trainRatio = 0.7;
end
if nargin < 3 || ~isfinite(seed)
    seed = 20260323;
end

trainRatio = max(0.1, min(0.9, trainRatio));
rng(round(seed), 'twister');

n = height(T);
idxAll = (1:n)';

y = strings(n, 1);
if ismember('gt_safe_to_land', T.Properties.VariableNames)
    y = autosimNormalizeActionLabel(T.gt_safe_to_land);
elseif ismember('label', T.Properties.VariableNames)
    y = autosimNormalizeActionLabel(T.label);
end

validLbl = (y == "AttemptLanding") | (y == "HoldLanding");
idxTrain = [];
idxVal = [];

if any(validLbl)
    cls = unique(y(validLbl));
    for i = 1:numel(cls)
        idc = idxAll(validLbl & y == cls(i));
        idc = idc(randperm(numel(idc)));
        nTr = max(1, floor(trainRatio * numel(idc)));
        nTr = min(nTr, numel(idc));
        idxTrain = [idxTrain; idc(1:nTr)]; %#ok<AGROW>
        if nTr < numel(idc)
            idxVal = [idxVal; idc(nTr+1:end)]; %#ok<AGROW>
        end
    end

    idxOther = idxAll(~validLbl);
    if ~isempty(idxOther)
        idxOther = idxOther(randperm(numel(idxOther)));
        nTrO = floor(trainRatio * numel(idxOther));
        idxTrain = [idxTrain; idxOther(1:nTrO)]; %#ok<AGROW>
        idxVal = [idxVal; idxOther(nTrO+1:end)]; %#ok<AGROW>
    end
else
    idxShuf = idxAll(randperm(n));
    nTr = max(1, floor(trainRatio * n));
    idxTrain = idxShuf(1:nTr);
    idxVal = idxShuf(nTr+1:end);
end

if isempty(idxVal)
    idxShuf = idxAll(randperm(n));
    nTr = max(1, min(n-1, floor(trainRatio * n)));
    idxTrain = idxShuf(1:nTr);
    idxVal = idxShuf(nTr+1:end);
end

idxTrain = idxTrain(randperm(numel(idxTrain)));
idxVal = idxVal(randperm(numel(idxVal)));
trainTbl = T(idxTrain, :);
valTbl = T(idxVal, :);

info = struct();
info.train_ratio = height(trainTbl) / max(1, n);
info.val_ratio = height(valTbl) / max(1, n);
info.seed = seed;
end


function [T, recentN] = autosimValidationApplyRecentWindow(T)
recentN = autosimValidationResolveRecentDatasetN();
if ~(isfinite(recentN) && recentN > 0)
    return;
end
n = height(T);
if n <= 0
    return;
end
k = min(n, round(recentN));
if autosimValidationUseStrictTailWindow()
    T = T(n - k + 1:n, :);
else
    T = autosimValidationSelectRecentWindow(T, k);
end
end


function Tsel = autosimValidationSelectRecentWindow(T, k)
n = height(T);
if k >= n
    Tsel = T;
    return;
end

label = strings(n, 1);
if ismember('gt_safe_to_land', T.Properties.VariableNames)
    label = autosimNormalizeActionLabel(T.gt_safe_to_land);
elseif ismember('label', T.Properties.VariableNames)
    label = autosimNormalizeActionLabel(T.label);
else
    Tsel = T(n - k + 1:n, :);
    return;
end

safeIdx = find(label == "AttemptLanding");
holdIdx = find(label == "HoldLanding");
if isempty(safeIdx) || isempty(holdIdx)
    Tsel = T(n - k + 1:n, :);
    return;
end

safeQuota = floor(k / 2);
holdQuota = k - safeQuota;
safeTake = min(numel(safeIdx), safeQuota);
holdTake = min(numel(holdIdx), holdQuota);

sel = [safeIdx(max(1, end - safeTake + 1):end); holdIdx(max(1, end - holdTake + 1):end)];
sel = unique(sel, 'stable');

if numel(sel) < k
    need = k - numel(sel);
    tailIdx = (n - k + 1:n)';
    tailIdx = setdiff(tailIdx, sel, 'stable');
    if ~isempty(tailIdx)
        addIdx = tailIdx(max(1, end - need + 1):end);
        sel = [sel; addIdx]; %#ok<AGROW>
    end
end

if isempty(sel)
    Tsel = T(n - k + 1:n, :);
    return;
end

sel = sort(sel);
if numel(sel) > k
    sel = sel(end-k+1:end);
end
Tsel = T(sel, :);
end


function recentN = autosimValidationResolveRecentDatasetN()
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


function tf = autosimValidationUseStrictTailWindow()
raw = strtrim(lower(char(string(getenv('AUTOSIM_VALIDATION_RECENT_STRICT_TAIL')))));
tf = any(strcmp(raw, {'1', 'true', 'yes', 'on'}));
end


function s = autosimValidationLabelStats(T)
s = struct('n_safe', 0, 'n_hold', 0);
if isempty(T)
    return;
end

lbl = strings(height(T), 1);
if ismember('gt_safe_to_land', T.Properties.VariableNames)
    lbl = autosimNormalizeActionLabel(T.gt_safe_to_land);
elseif ismember('label', T.Properties.VariableNames)
    lbl = autosimNormalizeActionLabel(T.label);
else
    return;
end

s.n_safe = sum(lbl == "AttemptLanding");
s.n_hold = sum(lbl == "HoldLanding");
end


function [T, info] = autosimValidationFilterDatasetQuality(T)
info = struct();
info.n_input = height(T);
info.n_drop_failed_or_interrupted = 0;
info.n_drop_missing_wind = 0;

if isempty(T)
    return;
end

dropFailedInterrupted = true;
rawDropFailed = strtrim(lower(char(string(getenv('AUTOSIM_VALIDATION_DROP_FAILED_ROWS')))));
if ~isempty(rawDropFailed)
    dropFailedInterrupted = any(strcmp(rawDropFailed, {'1', 'true', 'yes', 'on'}));
end

dropMissingWind = true;
rawDropWind = strtrim(lower(char(string(getenv('AUTOSIM_VALIDATION_DROP_MISSING_WIND')))));
if ~isempty(rawDropWind)
    dropMissingWind = any(strcmp(rawDropWind, {'1', 'true', 'yes', 'on'}));
end

keep = true(height(T), 1);

if dropFailedInterrupted && ismember('source_file', T.Properties.VariableNames)
    src = lower(string(T.source_file));
    badSrc = contains(src, '_failed.csv') | contains(src, '_interrupted.csv');
    info.n_drop_failed_or_interrupted = sum(badSrc);
    keep = keep & ~badSrc;
end

if dropMissingWind
    windCols = {'wind_speed_cmd', 'mean_wind_speed', 'max_wind_speed', 'wind_velocity'};
    hasWind = false(height(T), 1);
    for i = 1:numel(windCols)
        vn = windCols{i};
        if ~ismember(vn, T.Properties.VariableNames)
            continue;
        end
        col = T.(vn);
        if isnumeric(col) || islogical(col)
            v = double(col);
        else
            v = str2double(string(col));
        end
        hasWind = hasWind | isfinite(v);
    end
    badWind = ~hasWind;
    info.n_drop_missing_wind = sum(badWind & keep);
    keep = keep & ~badWind;
end

T = T(keep, :);
info.n_output = height(T);
end


function modelPathOut = autosimValidationResolveModelPath(modelPathIn, rootDir, defaultModelRoot, modelType)
if strlength(string(modelPathIn)) > 0
    modelPathOut = string(modelPathIn);
    if ~isfile(char(modelPathOut))
        error('AutoSimValidation:ModelPathNotFound', 'Specified model path does not exist: %s', char(modelPathOut));
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

files = autosimValidationCollectModelFiles(char(roots(1)), modelType);
for i = 2:numel(roots)
    root = char(roots(i));
    if ~isfolder(root)
        continue;
    end
    d = autosimValidationCollectModelFiles(root, modelType);
    if isempty(d)
        continue;
    end
    if isempty(files)
        files = d;
    else
        files = [files; d]; %#ok<AGROW>
    end
end

% Filter by model type if specified
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
        error('AutoSimValidation:NoModel', 'No model file found for type "%s" under discovered model roots.', modelType);
    else
        error('AutoSimValidation:NoModel', 'No model file found under discovered model roots.');
    end
end

[~, idx] = max([files.datenum]);
modelPathOut = string(fullfile(files(idx).folder, files(idx).name));
end

function files = autosimValidationCollectModelFiles(root, modelType)
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

function meta = autosimValidationResolveDroneMeta(cfg, T)
meta = struct();
meta.count = 1;
meta.is_multi = false;
meta.source = "runtime";

if isfield(cfg, 'runtime') && isstruct(cfg.runtime) && isfield(cfg.runtime, 'multi_drone_count')
    n = double(cfg.runtime.multi_drone_count);
    if isfinite(n) && n >= 1
        meta.count = max(1, round(n));
    end
end

if ~isempty(T)
    if ismember('drone_namespace', T.Properties.VariableNames)
        ns = string(T.drone_namespace);
        ns = strtrim(ns);
        ns = ns(strlength(ns) > 0);
        if ~isempty(ns)
            meta.count = max(meta.count, numel(unique(ns, 'stable')));
            meta.source = "dataset_namespace";
        end
    elseif ismember('drone_id', T.Properties.VariableNames)
        ids = T.drone_id;
        if isnumeric(ids) || islogical(ids)
            ids = double(ids);
            ids = ids(isfinite(ids));
            if ~isempty(ids)
                meta.count = max(meta.count, numel(unique(round(ids))));
                meta.source = "dataset_drone_id";
            end
        else
            ids = string(ids);
            ids = strtrim(ids);
            ids = ids(strlength(ids) > 0);
            if ~isempty(ids)
                meta.count = max(meta.count, numel(unique(ids, 'stable')));
                meta.source = "dataset_drone_id";
            end
        end
    end
end

meta.is_multi = meta.count >= 2;
end


function tm = autosimValidationEvaluateTrajectoryMetrics(T)
tm = struct();
tm.mode = "unavailable";
tm.n_valid = 0;
tm.xy_rmse_m = nan;
tm.z_rmse_m = nan;
tm.xyz_rmse_m = nan;
tm.xy_mae_m = nan;
tm.z_mae_m = nan;
tm.success_rate = nan;
tm.follow_score = nan;
tm.quality_mean = nan;
tm.quality_std = nan;

if isempty(T)
    return;
end

n = height(T);
xyErr = nan(n, 1);
zErr = nan(n, 1);

hasTrajX = ismember('trajectory_target_x', T.Properties.VariableNames) && ...
    ismember('trajectory_target_y', T.Properties.VariableNames) && ...
    ismember('trajectory_target_z', T.Properties.VariableNames);
hasPoseX = ismember('final_x', T.Properties.VariableNames) && ...
    ismember('final_y', T.Properties.VariableNames);

if hasTrajX && hasPoseX
    xNow = autosimValidationColumnAsDouble(T, 'final_x');
    yNow = autosimValidationColumnAsDouble(T, 'final_y');
    xTgt = autosimValidationColumnAsDouble(T, 'trajectory_target_x');
    yTgt = autosimValidationColumnAsDouble(T, 'trajectory_target_y');
    xyErr = hypot(xNow - xTgt, yNow - yTgt);
end

if ismember('trajectory_target_z', T.Properties.VariableNames) && ismember('final_altitude', T.Properties.VariableNames)
    zNow = autosimValidationColumnAsDouble(T, 'final_altitude');
    zTgt = autosimValidationColumnAsDouble(T, 'trajectory_target_z');
    zErr = abs(zNow - zTgt);
elseif ismember('hover_height_cmd', T.Properties.VariableNames) && ismember('final_altitude', T.Properties.VariableNames)
    zNow = autosimValidationColumnAsDouble(T, 'final_altitude');
    zCmd = autosimValidationColumnAsDouble(T, 'hover_height_cmd');
    zErr = abs(zNow - zCmd);
end

if all(~isfinite(xyErr)) && ismember('mean_tag_error', T.Properties.VariableNames)
    xyErr = abs(autosimValidationColumnAsDouble(T, 'mean_tag_error'));
end
if all(~isfinite(zErr)) && ismember('stability_std_z', T.Properties.VariableNames)
    zErr = abs(autosimValidationColumnAsDouble(T, 'stability_std_z'));
end

xyValid = isfinite(xyErr);
zValid = isfinite(zErr);

if any(xyValid)
    tm.xy_rmse_m = sqrt(mean(xyErr(xyValid).^2));
    tm.xy_mae_m = mean(abs(xyErr(xyValid)));
end
if any(zValid)
    tm.z_rmse_m = sqrt(mean(zErr(zValid).^2));
    tm.z_mae_m = mean(abs(zErr(zValid)));
end

xyzValid = xyValid | zValid;
if any(xyzValid)
    ex = xyErr;
    ez = zErr;
    ex(~isfinite(ex)) = 0.0;
    ez(~isfinite(ez)) = 0.0;
    tm.xyz_rmse_m = sqrt(mean((ex(xyzValid).^2 + ez(xyzValid).^2)));
end

quality = nan(n, 1);
if ismember('trajectory_quality', T.Properties.VariableNames)
    quality = autosimValidationColumnAsDouble(T, 'trajectory_quality');
else
    qx = 1.0 - autosimValidationNormalizeErr(xyErr, 0.6);
    qz = 1.0 - autosimValidationNormalizeErr(zErr, 0.4);
    quality = nanmean([qx, qz], 2);
end
quality = min(1.0, max(0.0, quality));
qValid = isfinite(quality);
if any(qValid)
    tm.quality_mean = mean(quality(qValid));
    tm.quality_std = std(quality(qValid));
end

successMask = false(n, 1);
haveAnyErr = isfinite(xyErr) | isfinite(zErr);
if any(haveAnyErr)
    xyGate = (~isfinite(xyErr)) | (xyErr <= 0.35);
    zGate = (~isfinite(zErr)) | (zErr <= 0.20);
    successMask = haveAnyErr & xyGate & zGate;
    tm.success_rate = mean(double(successMask(haveAnyErr)));
end

scoreParts = [ ...
    1.0 - autosimValidationNormalizeErr(tm.xy_rmse_m, 0.6), ...
    1.0 - autosimValidationNormalizeErr(tm.z_rmse_m, 0.4), ...
    tm.quality_mean, ...
    tm.success_rate ...
];
scoreParts = scoreParts(isfinite(scoreParts));
if ~isempty(scoreParts)
    tm.follow_score = max(0.0, min(1.0, mean(scoreParts)));
end

tm.n_valid = sum(double(isfinite(xyErr) | isfinite(zErr) | isfinite(quality)));
if any(hasTrajX)
    tm.mode = "trajectory_target_error";
elseif ismember('mean_tag_error', T.Properties.VariableNames) || ismember('stability_std_z', T.Properties.VariableNames)
    tm.mode = "proxy_tag_stability";
else
    tm.mode = "unavailable";
end
end


function v = autosimValidationColumnAsDouble(T, col)
v = nan(height(T), 1);
if ~ismember(col, T.Properties.VariableNames)
    return;
end
raw = T.(col);
if isnumeric(raw) || islogical(raw)
    v = double(raw);
else
    v = str2double(string(raw));
end
end


function nrm = autosimValidationNormalizeErr(errVal, scale)
if nargin < 2 || ~(isfinite(scale) && scale > 0)
    scale = 1.0;
end
if isscalar(errVal)
    if ~isfinite(errVal)
        nrm = nan;
        return;
    end
else
    errVal = double(errVal);
end
nrm = abs(errVal) ./ scale;
nrm = min(1.0, max(0.0, nrm));
end

function varargout = autosim_learning_engine(action, varargin)
% autosim_learning_engine
% Learning and validation engine extracted from AutoSim main script.

switch lower(string(action))
    case "validation_mode"
        varargout{1} = validation_mode(varargin{1}, varargin{2});
    case "apply_validation_scenario_config"
        varargout{1} = apply_validation_scenario_config(varargin{1}, varargin{2}, varargin{3}, varargin{4});
    case "incremental_train_and_save"
        [varargout{1}, varargout{2}] = incremental_train_and_save(varargin{1}, varargin{2}, varargin{3}, varargin{4});
    case "disabled_learn_info"
        varargout{1} = make_learn_info(varargin{1}, "pipeline_train_disabled", 0, 0, 0);
    otherwise
        error("autosim_learning_engine:unknownAction", "Unknown action: %s", string(action));
end
end

function mode = validation_mode(cfg, scenarioId)
mode = "boundary";
if ~isfield(cfg, "validation") || ~isfield(cfg.validation, "mode_cycle")
    return;
end

cycle = string(cfg.validation.mode_cycle(:));
cycle = cycle(strlength(cycle) > 0);
if isempty(cycle)
    return;
end

idx = mod(max(1, scenarioId) - 1, numel(cycle)) + 1;
mode = cycle(idx);
end

function scenarioCfg = apply_validation_scenario_config(cfg, scenarioCfg, scenarioId, profile)
if ~isfield(cfg, "validation") || ~isfield(cfg.validation, "enable") || ~cfg.validation.enable
    return;
end

mode = validation_mode(cfg, scenarioId);
scenarioCfg.validation_mode = mode;

if isempty(profile) || ~isfield(profile, "speed_sec") || isempty(profile.speed_sec)
    return;
end

speedVals = double(profile.speed_sec(:));
dirVals = double(profile.dir_sec(:));
valid = isfinite(speedVals) & isfinite(dirVals);
if ~any(valid)
    return;
end

sourceIdx = find(valid);
speedValid = speedVals(valid);
dirValid = dirVals(valid);

switch mode
    case "easy"
        q = get_validation_quantile_range(cfg.validation, "easy_speed_quantile", [0.05, 0.35]);
        hoverRatio = clamp_nan(cfg.validation.easy_hover_ratio, 0.80);
        gustScale = clamp_nan(cfg.validation.easy_gust_amp_scale, 0.90);
        dirScale = clamp_nan(cfg.validation.easy_dir_osc_scale, 0.90);
    case "hard"
        q = get_validation_quantile_range(cfg.validation, "hard_speed_quantile", [0.70, 0.95]);
        hoverRatio = clamp_nan(cfg.validation.hard_hover_ratio, 0.20);
        gustScale = clamp_nan(cfg.validation.hard_gust_amp_scale, 1.25);
        dirScale = clamp_nan(cfg.validation.hard_dir_osc_scale, 1.20);
    otherwise
        q = get_validation_quantile_range(cfg.validation, "boundary_speed_quantile", [0.35, 0.70]);
        hoverRatio = clamp_nan(cfg.validation.boundary_hover_ratio, 0.50);
        gustScale = clamp_nan(cfg.validation.boundary_gust_amp_scale, 1.05);
        dirScale = clamp_nan(cfg.validation.boundary_dir_osc_scale, 1.05);
end

q = min(max(sort(q), 0.0), 1.0);
lo = prctile(speedValid, 100 * q(1));
hi = prctile(speedValid, 100 * q(2));
speedMask = (speedValid >= lo) & (speedValid <= hi);

cycle = string(cfg.validation.mode_cycle(:));
cycle = cycle(strlength(cycle) > 0);
if isempty(cycle)
    cycle = ["easy"; "boundary"; "hard"];
end
dirBinCount = max(1, round(clamp_nan(cfg.validation.direction_bin_count, 8)));
dirEdges = linspace(-180.0, 180.0, dirBinCount + 1);
dirBin = mod(floor((max(1, scenarioId) - 1) / numel(cycle)), dirBinCount) + 1;
dirMask = (dirValid >= dirEdges(dirBin)) & (dirValid <= dirEdges(dirBin + 1));

idxPool = sourceIdx(speedMask & dirMask);
if isempty(idxPool)
    idxPool = sourceIdx(speedMask);
end
if isempty(idxPool)
    idxPool = sourceIdx;
end

seedBase = clamp_nan(cfg.validation.seed_base, 20260313);
stream = RandStream("mt19937ar", "Seed", mod(seedBase + 4099 * max(1, scenarioId), 2147483646) + 1);
pick = idxPool(randi(stream, numel(idxPool)));

scenarioCfg.wind_speed = profile.speed_sec(pick);
scenarioCfg.wind_dir = profile.dir_sec(pick);
scenarioCfg.wind_profile_offset_sec = max(0, pick - 1);
scenarioCfg.hover_height_m = interpolate(cfg.scenario.hover_height_min_m, cfg.scenario.hover_height_max_m, hoverRatio);
scenarioCfg.gust_amp_scale = gustScale;
scenarioCfg.dir_osc_scale = dirScale;
end

function [model, info] = incremental_train_and_save(cfg, summaryTbl, modelPrev, scenarioId)
valid = false(height(summaryTbl), 1);
if ismember("gt_safe_to_land", summaryTbl.Properties.VariableNames)
    gt = string(summaryTbl.gt_safe_to_land);
    valid = (gt == "stable") | (gt == "safe") | (gt == "unstable") | (gt == "unsafe") | ...
        (gt == "AttemptLanding") | (gt == "HoldLanding");
elseif ismember("label", summaryTbl.Properties.VariableNames)
    valid = (summaryTbl.label == "stable") | (summaryTbl.label == "unstable");
end

nTrainInitial = sum(valid);
if ~isfield(cfg, "learning") || ~isfield(cfg.learning, "enable") || ~cfg.learning.enable
    model = modelPrev;
    info = make_learn_info(scenarioId, "learning_disabled", nTrainInitial, 0, 0);
    return;
end

if nTrainInitial < cfg.learning.bootstrap_min_samples
    model = modelPrev;
    info = make_learn_info(scenarioId, "insufficient_total_samples", nTrainInitial, 0, 0);
    return;
end

if isfield(cfg.learning, "min_scenarios_before_first_update") && isfinite(cfg.learning.min_scenarios_before_first_update)
    if scenarioId < cfg.learning.min_scenarios_before_first_update
        model = modelPrev;
        info = make_learn_info(scenarioId, "warmup_before_first_update", nTrainInitial, 0, 0);
        return;
    end
end

if isfield(cfg.learning, "save_every_scenario") && ~cfg.learning.save_every_scenario
    updateEvery = 1;
    if isfield(cfg.learning, "update_every_n_scenarios") && isfinite(cfg.learning.update_every_n_scenarios)
        updateEvery = max(1, round(cfg.learning.update_every_n_scenarios));
    end
    if mod(max(1, scenarioId), updateEvery) ~= 0
        model = modelPrev;
        info = make_learn_info(scenarioId, "cadence_skip", nTrainInitial, 0, 0);
        return;
    end
end

trainTbl = summaryTbl(valid, :);
trainTbl = autosimEnsureOntologyFeatureColumns(trainTbl, cfg);
y = build_action_target_labels(trainTbl);

nStable = sum(y == "AttemptLanding");
nUnstable = sum(y == "HoldLanding");
nTrain = numel(y);
minorityRatio = min(nStable, nUnstable) / max(1, nTrain);

minStable = 1;
minUnstable = 1;
minMinorityRatio = 0.0;
forceAfterStale = inf;
if isfield(cfg.learning, "min_stable_samples_for_update") && isfinite(cfg.learning.min_stable_samples_for_update)
    minStable = max(1, round(cfg.learning.min_stable_samples_for_update));
end
if isfield(cfg.learning, "min_unstable_samples_for_update") && isfinite(cfg.learning.min_unstable_samples_for_update)
    minUnstable = max(1, round(cfg.learning.min_unstable_samples_for_update));
end
if isfield(cfg.learning, "minority_ratio_floor_for_update") && isfinite(cfg.learning.minority_ratio_floor_for_update)
    minMinorityRatio = max(0.0, min(0.5, cfg.learning.minority_ratio_floor_for_update));
end
if isfield(cfg.learning, "force_update_after_stale_scenarios") && isfinite(cfg.learning.force_update_after_stale_scenarios)
    forceAfterStale = max(1, round(cfg.learning.force_update_after_stale_scenarios));
end

lastUpdateScenario = nan;
if isstruct(modelPrev) && isfield(modelPrev, "last_update_scenario") && isfinite(modelPrev.last_update_scenario)
    lastUpdateScenario = double(modelPrev.last_update_scenario);
end
staleScenarioCount = inf;
if isfinite(lastUpdateScenario)
    staleScenarioCount = max(0, scenarioId - lastUpdateScenario);
end
allowForcedRefresh = (nUnstable >= 1) && (staleScenarioCount >= forceAfterStale);

if ~allowForcedRefresh && (nStable < minStable || nUnstable < minUnstable || minorityRatio < minMinorityRatio)
    model = modelPrev;
    info = make_learn_info(scenarioId, "class_imbalance_guard", nTrain, nStable, nUnstable);
    return;
end

featNames = cellstr(cfg.model.feature_names);
X = zeros(height(trainTbl), numel(featNames));
for i = 1:numel(featNames)
    col = featNames{i};
    if ismember(col, trainTbl.Properties.VariableNames)
        X(:, i) = to_numeric(trainTbl.(col));
    else
        X(:, i) = to_numeric(resolve_feature_fallback(trainTbl, col));
    end
end

model = train_gnb(X, y, cfg.model.feature_names, cfg.model.prior_uniform_blend);
[bestThreshold, tuneStats] = tune_decision_threshold(model, X, y, cfg);
model.decision_threshold = bestThreshold;
model.decision_threshold_source = "train_tuned";
model.decision_threshold_tuning = tuneStats;
model.schema_version = string(cfg.model.schema_version);
model.n_train = nTrain;
model.n_stable = nStable;
model.n_unstable = nUnstable;
model.n_attempt_landing = nStable;
model.n_hold_landing = nUnstable;
model.stable_ratio = mean(y == "AttemptLanding");
model.attempt_landing_ratio = mean(y == "AttemptLanding");
model.minority_ratio = minorityRatio;
model.last_update_scenario = scenarioId;

ts = timestamp_now();
modelPath = fullfile(cfg.paths.model_dir, sprintf("autosim_model_%s_s%03d.mat", ts, scenarioId));
save(modelPath, "model");

info = make_learn_info(scenarioId, "", nTrain, nStable, nUnstable);
info.model_updated = true;
info.model_path = string(modelPath);
end

function [bestThreshold, stats] = tune_decision_threshold(model, X, y, cfg)
defaultThreshold = 0.50;
if isfield(cfg, "agent") && isfield(cfg.agent, "prob_land_threshold") && isfinite(cfg.agent.prob_land_threshold)
    defaultThreshold = cfg.agent.prob_land_threshold;
end

enableTune = true;
if isfield(cfg, "learning") && isfield(cfg.learning, "threshold_tune_enable")
    enableTune = logical(cfg.learning.threshold_tune_enable);
end

if ~enableTune || isempty(X) || isempty(y)
    bestThreshold = defaultThreshold;
    stats = struct("enabled", enableTune, "selected_threshold", bestThreshold, "objective", nan, "tpr", nan, "tnr", nan, "f1", nan);
    return;
end

scores = gnb_attempt_scores(model, X);
gtAttempt = (string(y(:)) == "AttemptLanding");
gtHold = ~gtAttempt;
P = sum(gtAttempt);
N = sum(gtHold);
if P < 1 || N < 1
    bestThreshold = defaultThreshold;
    stats = struct("enabled", enableTune, "selected_threshold", bestThreshold, "objective", nan, "tpr", nan, "tnr", nan, "f1", nan);
    return;
end

minHoldRecall = 0.55;
if isfield(cfg, "learning") && isfield(cfg.learning, "threshold_tune_min_hold_recall") && isfinite(cfg.learning.threshold_tune_min_hold_recall)
    minHoldRecall = max(0.0, min(1.0, cfg.learning.threshold_tune_min_hold_recall));
end

candidates = unique([0.30:0.01:0.80, defaultThreshold, quantile(scores, [0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90])]); %#ok<NBRAK>
candidates = candidates(isfinite(candidates));
candidates = min(max(candidates, 0.01), 0.99);
candidates = unique(candidates);

bestObj = -inf;
bestThreshold = defaultThreshold;
bestStats = [nan, nan, nan];
hasFeasible = false;
bestRank = [-inf, -inf, -inf];
for i = 1:numel(candidates)
    th = candidates(i);
    predAttempt = scores >= th;

    tp = sum(predAttempt & gtAttempt);
    tn = sum((~predAttempt) & gtHold);
    fp = sum(predAttempt & gtHold);
    fn = sum((~predAttempt) & gtAttempt);

    tpr = tp / max(P, 1);
    tnr = tn / max(N, 1);
    f1 = (2.0 * tp) / max(2.0 * tp + fp + fn, 1);

    isFeasible = (tnr >= minHoldRecall);
    if isFeasible
        hasFeasible = true;
    elseif hasFeasible
        continue;
    end

    % TP-priority: maximize AttemptLanding recall first, then F1, then Hold recall.
    rankNow = [tpr, f1, tnr];
    objective = tpr;
    if lexicographic_better(rankNow, bestRank)
        bestObj = objective;
        bestThreshold = th;
        bestStats = [tpr, tnr, f1];
        bestRank = rankNow;
    end
end

bestThreshold = min(max(bestThreshold, 0.01), 0.99);
stats = struct();
stats.enabled = enableTune;
stats.selected_threshold = bestThreshold;
stats.objective = bestObj;
stats.tpr = bestStats(1);
stats.tnr = bestStats(2);
stats.f1 = bestStats(3);
stats.rank_tpr_f1_tnr = bestRank;
stats.min_hold_recall = minHoldRecall;
stats.n_candidates = numel(candidates);
end

function tf = lexicographic_better(a, b)
tf = false;
if numel(a) ~= numel(b)
    tf = false;
    return;
end
for i = 1:numel(a)
    if a(i) > b(i)
        tf = true;
        return;
    elseif a(i) < b(i)
        tf = false;
        return;
    end
end
end

function scores = gnb_attempt_scores(model, X)
X = to_numeric(X);
if isvector(X)
    X = reshape(X, 1, []);
end
X(~isfinite(X)) = 0.0;

cls = string(model.class_names(:));
attemptIdx = find(cls == "AttemptLanding", 1, 'first');
if isempty(attemptIdx)
    attemptIdx = find(cls == "stable", 1, 'first');
end
if isempty(attemptIdx)
    scores = 0.5 * ones(size(X, 1), 1);
    return;
end

logPost = zeros(size(X, 1), numel(cls));
for i = 1:numel(cls)
    mu = model.mu(i,:);
    sg = model.sigma2(i,:);
    lp = -0.5 * sum(log(2.0*pi*sg) + ((X - mu).^2) ./ sg, 2);
    logPost(:,i) = log(max(model.prior(i), eps)) + lp;
end
ex = exp(logPost - max(logPost, [], 2));
post = ex ./ max(sum(ex, 2), eps);
scores = post(:, attemptIdx);
scores(~isfinite(scores)) = 0.5;
end

function y = build_action_target_labels(trainTbl)
if ismember("gt_safe_to_land", trainTbl.Properties.VariableNames)
    gt = string(trainTbl.gt_safe_to_land);
    y = repmat("HoldLanding", height(trainTbl), 1);
    y((gt == "stable") | (gt == "safe") | (gt == "AttemptLanding")) = "AttemptLanding";
    y((gt == "unstable") | (gt == "unsafe") | (gt == "HoldLanding")) = "HoldLanding";
    return;
end

if ismember("label", trainTbl.Properties.VariableNames)
    y = repmat("HoldLanding", height(trainTbl), 1);
    y(string(trainTbl.label) == "stable") = "AttemptLanding";
    return;
end

y = repmat("HoldLanding", height(trainTbl), 1);
end

function info = make_learn_info(scenarioId, skipReason, nTrain, nStable, nUnstable)
info = struct();
info.scenario_id = scenarioId;
info.model_updated = false;
info.n_train = nTrain;
if nTrain > 0
    info.stable_ratio = nStable / max(1, nTrain);
else
    info.stable_ratio = 0.0;
end
info.n_stable = nStable;
info.n_unstable = nUnstable;
info.skip_reason = string(skipReason);
info.model_path = "";
end

function q = get_validation_quantile_range(vcfg, fieldName, fallback)
q = fallback;
if isfield(vcfg, fieldName)
    tmp = double(vcfg.(fieldName));
    if numel(tmp) >= 2 && all(isfinite(tmp(1:2)))
        q = tmp(1:2);
    end
end
end

function v = interpolate(a, b, t)
t = clamp_nan(t, 0.5);
t = min(max(t, 0.0), 1.0);
v = a + (b - a) * t;
end

function y = clamp_nan(x, fallback)
if isfinite(x)
    y = x;
else
    y = fallback;
end
end

function v = to_numeric(x)
if isnumeric(x)
    v = double(x);
elseif islogical(x)
    v = double(x);
elseif isstring(x)
    v = double(str2double(x));
elseif ischar(x)
    v = double(str2double(string(x)));
elseif iscellstr(x)
    v = double(str2double(string(x)));
else
    try
        v = double(x);
    catch
        v = nan(size(x));
    end
end
v(~isfinite(v)) = 0.0;
end

function v = resolve_feature_fallback(T, featureName)
featureName = string(featureName);
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

key = char(featureName);
if ~isfield(fallbackMap, key)
    v = zeros(height(T), 1);
    return;
end

alts = fallbackMap.(key);
for iAlt = 1:numel(alts)
    fn = string(alts{iAlt});
    if ismember(fn, string(T.Properties.VariableNames))
        col = T.(char(fn));
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

function model = train_gnb(X, y, featureNames, priorUniformBlend)
if exist("autosim_ai_engine", "file") == 2
    try
        model = autosim_ai_engine("train_gnb", X, y, featureNames, priorUniformBlend);
        if isstruct(model)
            model.kind = "gaussian_nb";
            model.created_at = string(datetime("now"));
            model.placeholder = false;
            return;
        end
    catch
    end
end

X(~isfinite(X)) = 0.0;
cls = unique(y);
nClass = numel(cls);
nFeat = size(X, 2);

mu = zeros(nClass, nFeat);
sigma2 = ones(nClass, nFeat);
prior = zeros(nClass, 1);

for i = 1:nClass
    mask = (y == cls(i));
    Xi = X(mask, :);
    prior(i) = max(mean(mask), eps);
    mu(i, :) = mean(Xi, 1);
    sigma2(i, :) = var(Xi, 0, 1);
    sigma2(i, sigma2(i, :) < 1e-6) = 1e-6;
end

priorUniformBlend = min(max(priorUniformBlend, 0.0), 1.0);
prior = (1.0 - priorUniformBlend) * prior + priorUniformBlend * (ones(nClass, 1) / max(nClass, 1));
prior = prior / max(sum(prior), eps);

model = struct();
model.kind = "gaussian_nb";
model.class_names = cls;
model.feature_names = featureNames;
model.mu = mu;
model.sigma2 = sigma2;
model.prior = prior;
model.created_at = string(datetime("now"));
model.placeholder = false;
end

function ts = timestamp_now()
ts = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
ts = regexprep(ts, "[^0-9_]", "");
end

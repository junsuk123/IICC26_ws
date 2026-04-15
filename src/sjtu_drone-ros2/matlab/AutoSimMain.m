function AutoSimMain()
% AutoSimMain
% Main integrated pipeline entrypoint.
% Always runs: data collection -> training -> validation -> plotting.
% Supports both "aii_only" (AI-only) and "ontology_ai" (Ontology+AI) models.
clear; clear function;close all; clc;

% ================= USER SETTINGS (edit here) =================
mainCfg = struct();

% Use up to recent N rows for training.
% If total data is insufficient, training rows are reduced automatically
% after reserving validation_recent_n rows for validation.
mainCfg.dataset_recent_n = inf;
% Validation is fixed to this many recent scenarios.
mainCfg.validation_recent_n = 10000;
% Validation window mode:
%   false -> validate on last validation_recent_n rows
%   true  -> validate on full available window
mainCfg.validation_use_full_window = true;

% Model types to train and validate: "aii_only" (sensor-only AI) or "ontology_ai" (ontology+AI)
mainCfg.model_types_to_train = ["aii_only", "ontology_ai"];
mainCfg.model_types_to_validate = ["aii_only", "ontology_ai"];
% Paper plot baseline comparators: one or more of ["threshold", "aii_only"].
% Default comparison target is threshold-based inference.
mainCfg.paper_baseline_methods = ["threshold"];

% Data collection settings (editable in main).
mainCfg.collection = struct();
mainCfg.collection.scenario_count = 5;
mainCfg.collection.drone_count = 5;
mainCfg.collection.independent_per_drone = true;
mainCfg.collection.merge_last_runs = 5;
mainCfg.collection.launch_use_gui = false;
% RViz mode: 'off' (disabled), 'single' (worker1 RViz), 'multi' (per-worker RViz),
%            'unified' (one monitor RViz with domain bridge for all workers)
mainCfg.collection.rviz_mode = 'unified';
mainCfg.collection.launch_use_teleop = false;
mainCfg.collection.multi_drone_spacing_m = 10.0;
mainCfg.collection.multi_drone_namespace_prefix = 'drone_w';
mainCfg.collection.multi_drone_spawn_tags = true;
mainCfg.collection.multi_drone_use_world_tag_as_first = false;
mainCfg.collection.primary_drone_index = 1;
% Parallel autoscaling controls (applied by run_autosim_parallel.sh).
mainCfg.collection.dynamic_worker_scale = true;
mainCfg.collection.memory_probe_wait_sec = 8;
mainCfg.collection.allow_scale_above_requested = false;
mainCfg.collection.enable_progress_plot = false;
mainCfg.collection.enable_scenario_live_viz = false;

% Pipeline stages (main always executes all stages).
mainCfg.run_collection = true;
mainCfg.run_training = true;
mainCfg.run_validation = true;
mainCfg.run_plots = true;

plotsEnv = strtrim(lower(getenv('AUTOSIM_MAIN_RUN_PLOTS')));
if ~isempty(plotsEnv)
    mainCfg.run_plots = any(strcmp(plotsEnv, {'1', 'true', 'yes', 'y', 'on'}));
end

paperBaselinesEnv = strtrim(string(getenv('AUTOSIM_PAPER_BASELINES')));
if strlength(paperBaselinesEnv) > 0
    toks = split(lower(paperBaselinesEnv), {',', ';', ' '});
    toks = strtrim(toks);
    toks = toks(strlength(toks) > 0);
    allowed = ["threshold", "aii_only"];
    valid = strings(0,1);
    for iTok = 1:numel(toks)
        if any(toks(iTok) == allowed)
            valid(end+1,1) = toks(iTok); %#ok<AGROW>
        end
    end
    if ~isempty(valid)
        mainCfg.paper_baseline_methods = unique(valid, 'stable');
    end
end

% Safety cleanup guards: kill stale sim/ROS viewers before start and on abnormal end.
mainCfg.safe_cleanup_on_start = true;
mainCfg.safe_cleanup_on_error = true;
mainCfg.safe_cleanup_on_exit = true;

% ==============================================================

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

if mainCfg.safe_cleanup_on_start
    autosimMainForceCleanup('startup', thisDir);
end
cleanupGuard = onCleanup(@() autosimMainCleanupOnExit(mainCfg, thisDir)); %#ok<NASGU>

try
    if mainCfg.run_collection
        c = mainCfg.collection;
        fprintf('[AutoSimMain] Stage 1/4: data collection start (scenarios=%d, drones=%d)\n', ...
            round(c.scenario_count), round(c.drone_count));
        prevNestedFlag = getenv('AUTOSIM_IN_MAIN_PIPELINE');
        setenv('AUTOSIM_IN_MAIN_PIPELINE', 'true');
        nestedFlagCleanup = onCleanup(@() setenv('AUTOSIM_IN_MAIN_PIPELINE', prevNestedFlag)); %#ok<NASGU>
        AutoSimCollect(c);
    end

    recentN = double(mainCfg.dataset_recent_n);
    validationRecentN = round(double(mainCfg.validation_recent_n));
    if ~(isfinite(validationRecentN) && validationRecentN > 0)
        error('[AutoSimMain] validation_recent_n must be a positive finite integer.');
    end

    % Share fixed validation size with training so train can shrink first when data is limited.
    setenv('AUTOSIM_VALIDATION_FIXED_N', sprintf('%d', validationRecentN));

    if isfinite(recentN) && recentN > 0
        setenv('AUTOSIM_RECENT_DATASET_N', sprintf('%d', round(recentN)));
        fprintf('[AutoSimMain] Recent dataset window enabled: last %d rows\n', round(recentN));
    else
        setenv('AUTOSIM_RECENT_DATASET_N', '');
        fprintf('[AutoSimMain] Recent dataset window disabled: using full dataset\n');
    end

    if mainCfg.run_training
        fprintf('[AutoSimMain] Stage 2/4: training start (FinalDataset all, split=7:3)\n');
        run(fullfile(thisDir, 'AutoSimTrain.m'));
    end

    if mainCfg.run_validation
        useFullValidationWindow = false;
        if isfield(mainCfg, 'validation_use_full_window')
            useFullValidationWindow = logical(mainCfg.validation_use_full_window);
        end

        % Enforce disjoint train/eval split by default:
        % - training uses all rows except reserved tail (AUTOSIM_VALIDATION_FIXED_N)
        % - validation uses strict recent tail window only.
        setenv('AUTOSIM_VALIDATION_RECENT_STRICT_TAIL', 'true');

        if useFullValidationWindow
            % Evaluate on the full fixed recent window (default: last 1000 rows),
            % not on the entire historical dataset.
            setenv('AUTOSIM_RECENT_DATASET_N', sprintf('%d', validationRecentN));
            fprintf('[AutoSimMain] Validation dataset uses full fixed window: last %d rows\n', validationRecentN);
        else
            setenv('AUTOSIM_RECENT_DATASET_N', sprintf('%d', validationRecentN));
            fprintf('[AutoSimMain] Validation dataset fixed: last %d rows\n', validationRecentN);
        end

        fprintf('[AutoSimMain] Stage 3/4: validation start (fixed recent window, no split)\n');
        autosim_keep_workspace = true; %#ok<NASGU>
        validationUseFullWindow = useFullValidationWindow; %#ok<NASGU>
        run(fullfile(thisDir, 'AutoSimValidation.m'));
    end

    if mainCfg.run_plots
        setenv('AUTOSIM_RECENT_DATASET_N', '');
        setenv('AUTOSIM_PAPER_DECISION_MODE', 'threshold_all');
        setenv('AUTOSIM_PAPER_BASELINES', strjoin(string(mainCfg.paper_baseline_methods(:))', ','));
        fprintf('[AutoSimMain] Stage 4/4: plotting start\n');
        if evalin('base', 'exist(''allValidationResults'',''var'')')
            allResults = evalin('base', 'allValidationResults');
            plotModelTypes = string(mainCfg.model_types_to_validate(:));
            plottedAny = false;
            for iPlot = 1:numel(plotModelTypes)
                mt = plotModelTypes(iPlot);
                if isstruct(allResults) && isfield(allResults, char(mt))
                    vr = allResults.(char(mt));
                    if isstruct(vr) && isfield(vr, 'runDir')
                        runDir = char(string(vr.runDir)); %#ok<NASGU>
                        outputDir = ""; %#ok<NASGU>
                        paperPlotRunDir = runDir; %#ok<NASGU>
                        modelTypesToPlot = string(mt); %#ok<NASGU>
                        baselineComparatorsToPlot = string(mainCfg.paper_baseline_methods(:)); %#ok<NASGU>
                        fprintf('[AutoSimMain] Plotting validation result for model type: %s\n', char(mt));
                        run(fullfile(thisDir, 'AutoSimPaperPlots.m'));
                        plottedAny = true;
                    end
                end
            end
            if ~plottedAny
                runDir = ""; %#ok<NASGU>
                outputDir = ""; %#ok<NASGU>
                paperPlotRunDir = ""; %#ok<NASGU>
                modelTypesToPlot = string(mainCfg.model_types_to_validate(:)); %#ok<NASGU>
                baselineComparatorsToPlot = string(mainCfg.paper_baseline_methods(:)); %#ok<NASGU>
                run(fullfile(thisDir, 'AutoSimPaperPlots.m'));
            end
        else
            runDir = ""; %#ok<NASGU>
            outputDir = ""; %#ok<NASGU>
            paperPlotRunDir = ""; %#ok<NASGU>
            modelTypesToPlot = string(mainCfg.model_types_to_validate(:)); %#ok<NASGU>
            baselineComparatorsToPlot = string(mainCfg.paper_baseline_methods(:)); %#ok<NASGU>
            run(fullfile(thisDir, 'AutoSimPaperPlots.m'));
        end
    end

    fprintf('[AutoSimMain] Pipeline complete.\n');
catch ME
    if isfield(mainCfg, 'safe_cleanup_on_error') && mainCfg.safe_cleanup_on_error
        autosimMainForceCleanup('error', thisDir);
    end
    rethrow(ME);
end
end

function autosimMainCleanupOnExit(mainCfg, thisDir)
if isfield(mainCfg, 'safe_cleanup_on_exit') && mainCfg.safe_cleanup_on_exit
    autosimMainForceCleanup('exit', thisDir);
end
end

function autosimMainForceCleanup(reason, thisDir)
fprintf('[AutoSimMain] Safe cleanup (%s): checking stale Gazebo/RViz/ROS processes...\n', char(string(reason)));
try
    modDir = fullfile(thisDir, 'modules');
    if exist(modDir, 'dir')
        addpath(modDir);
    end
    coreDir = fullfile(modDir, 'core');
    if exist(coreDir, 'dir')
        addpath(genpath(coreDir));
    end

    cfg = autosimDefaultConfig();
    [cfg, ~] = autosimApplyRuntimeOverrides(cfg);
    autosimCleanupProcesses(cfg);
catch ME
    warning('[AutoSimMain] Structured cleanup failed (%s). Fallback kill will run.', ME.message);
    system(['bash -i -c "set +m; ' ...
        'pkill -9 gzserver >/dev/null 2>&1 || true; ' ...
        'pkill -9 gzclient >/dev/null 2>&1 || true; ' ...
        'pkill -9 -x rviz2 >/dev/null 2>&1 || true; ' ...
        'pkill -9 -f \"[r]os2 launch sjtu_drone_bringup\" >/dev/null 2>&1 || true; ' ...
        'pkill -9 -f \"[s]jtu_drone_bringup.launch.py\" >/dev/null 2>&1 || true"']);
end
end

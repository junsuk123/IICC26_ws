function monitor_autosim_parallel(sessionRoot, pollSec)
    if nargin < 1 || strlength(string(sessionRoot)) == 0
        error('Usage: monitor_autosim_parallel(''/path/to/matlab/parallel_runs/<timestamp>'', pollSec)');
    end
    if nargin < 2 || ~isfinite(pollSec)
        pollSec = 2.0;
    end

    sessionRoot = char(sessionRoot);
    fig = figure('Name', 'AutoSim Parallel Monitor', 'NumberTitle', 'off');
    tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    ax1 = nexttile(tl, 1);
    title(ax1, 'Per-worker Scenario Progress And Unsafe Rate');
    ylabel(ax1, 'scenario count');
    grid(ax1, 'on');

    ax2 = nexttile(tl, 2);
    hold(ax2, 'on');
    title(ax2, 'Aggregate Unsafe Landing Rate');
    xlabel(ax2, 'time [s]');
    ylabel(ax2, 'rate');
    ylim(ax2, [0 1]);
    grid(ax2, 'on');
    aggLine = animatedline(ax2, 'Color', [0.82 0.22 0.18], 'LineWidth', 1.8);

    ax3 = nexttile(tl, 3);
    title(ax3, 'Per-worker Policy Mix (recent)');
    ylabel(ax3, 'ratio');
    ylim(ax3, [0 1]);
    grid(ax3, 'on');

    ax4 = nexttile(tl, 4);
    title(ax4, 'Per-worker Learning Progress');
    ylabel(ax4, 'sample count');
    grid(ax4, 'on');

    t0 = tic;
    pidTablePath = fullfile(sessionRoot, 'workers.tsv');
    workerMeta = autosimMonitorReadWorkerMeta(pidTablePath);
    allWorkersExitedLogged = false;
    while isgraphics(fig)
        if isempty(workerMeta)
            workerMeta = autosimMonitorReadWorkerMeta(pidTablePath);
        end

        workerDirs = dir(fullfile(sessionRoot, 'output', 'data', 'worker_*'));
        workerNames = strings(0, 1);
        counts = [];
        unsafeRates = [];
        totalUnsafe = 0;
        totalValid = 0;

        for i = 1:numel(workerDirs)
            wdir = fullfile(workerDirs(i).folder, workerDirs(i).name);
            runDirs = dir(fullfile(wdir, '*'));
            runDirs = runDirs([runDirs.isdir]);
            runDirs = runDirs(~ismember({runDirs.name}, {'.', '..'}));
            if isempty(runDirs)
                continue;
            end

            [~, idxLatest] = max([runDirs.datenum]);
            latestRun = fullfile(runDirs(idxLatest).folder, runDirs(idxLatest).name);
            csvPath = fullfile(latestRun, 'autosim_dataset_latest.csv');
            if ~isfile(csvPath)
                continue;
            end

            try
                T = readtable(csvPath);
            catch
                continue;
            end

            nRows = height(T);
            nUnsafe = 0;
            nValid = 0;
            if ismember('gt_safe_to_land', T.Properties.VariableNames)
                gt = string(T.gt_safe_to_land);
                validMask = (gt == "stable") | (gt == "unsafe") | (gt == "unstable");
                unsafeMask = (gt == "unsafe") | (gt == "unstable");
                nValid = sum(validMask);
                nUnsafe = sum(unsafeMask & validMask);
            elseif ismember('label', T.Properties.VariableNames)
                gt = string(T.label);
                validMask = (gt == "stable") | (gt == "unstable");
                unsafeMask = (gt == "unstable");
                nValid = sum(validMask);
                nUnsafe = sum(unsafeMask & validMask);
            end

            wName = string(workerDirs(i).name);
            workerNames(end+1, 1) = wName; %#ok<AGROW>
            counts(end+1, 1) = nRows; %#ok<AGROW>
            if nValid > 0
                unsafeRates(end+1, 1) = nUnsafe / nValid; %#ok<AGROW>
            else
                unsafeRates(end+1, 1) = nan; %#ok<AGROW>
            end

            totalUnsafe = totalUnsafe + nUnsafe;
            totalValid = totalValid + nValid;
        end

        simStats = autosimMonitorReadWorkerStatsFromLogs(workerMeta);

        cla(ax1);
        if ~isempty(simStats.workerIds)
            yyaxis(ax1, 'left');
            b1 = bar(ax1, simStats.scenarioNow, 0.55, 'FaceColor', [0.14 0.44 0.72]); %#ok<NASGU>
            ylabel(ax1, 'scenario count');

            yyaxis(ax1, 'right');
            if numel(unsafeRates) == numel(simStats.workerIds)
                unsafeForPlot = unsafeRates;
            else
                unsafeForPlot = simStats.exceptionRate;
            end
            b2 = bar(ax1, unsafeForPlot, 0.30, 'FaceColor', [0.83 0.33 0.20]); %#ok<NASGU>
            ylabel(ax1, 'unsafe rate');
            ylim(ax1, [0 1]);

            workerNames = arrayfun(@(x) sprintf('worker_%02d', x), simStats.workerIds, 'UniformOutput', false);
            xticks(ax1, 1:numel(workerNames));
            xticklabels(ax1, workerNames);
            legend(ax1, {'scenario count', 'unsafe rate'}, 'Location', 'best');
        end
        grid(ax1, 'on');

        if totalValid > 0
            addpoints(aggLine, toc(t0), totalUnsafe / totalValid);
        end

        cla(ax3);
        if ~isempty(simStats.workerIds)
            mixData = [simStats.policyExploit, simStats.policyBoundary, simStats.policyHardNeg];
            bar(ax3, mixData, 'stacked');
            ylim(ax3, [0 1]);
            xticks(ax3, 1:numel(simStats.workerIds));
            xticklabels(ax3, arrayfun(@(x) sprintf('w%02d', x), simStats.workerIds, 'UniformOutput', false));
            legend(ax3, {'exploit', 'boundary', 'hard_negative'}, 'Location', 'best');
        end
        grid(ax3, 'on');

        cla(ax4);
        if ~isempty(simStats.workerIds)
            yyaxis(ax4, 'left');
            bar(ax4, simStats.learnN, 0.55, 'FaceColor', [0.20 0.60 0.20]);
            ylabel(ax4, 'n samples');

            yyaxis(ax4, 'right');
            plot(ax4, 1:numel(simStats.workerIds), simStats.learnStableRatio, 'o-', 'Color', [0.49 0.18 0.56], 'LineWidth', 1.4);
            ylabel(ax4, 'stable ratio');
            ylim(ax4, [0 1]);

            xticks(ax4, 1:numel(simStats.workerIds));
            xticklabels(ax4, arrayfun(@(x) sprintf('w%02d', x), simStats.workerIds, 'UniformOutput', false));
            legend(ax4, {'learning n', 'stable ratio'}, 'Location', 'best');
        end
        grid(ax4, 'on');

        drawnow limitrate nocallbacks;

        if isfile(pidTablePath)
            [allExited, ~, totalWorkers] = autosimMonitorCheckWorkerExitStatus(pidTablePath);
            if allExited && totalWorkers > 0
                if ~allWorkersExitedLogged
                    fprintf('[AUTOSIM MONITOR] All workers finished. Closing monitor.\n');
                    allWorkersExitedLogged = true;
                end
                break;
            end
        end

        pause(max(0.2, pollSec));
    end

    if isgraphics(fig)
        close(fig);
    end
end

function workerMeta = autosimMonitorReadWorkerMeta(pidTablePath)
    workerMeta = table();
    if ~isfile(pidTablePath)
        return;
    end
    try
        T = readtable(pidTablePath, 'FileType', 'text', 'Delimiter', '\t');
    catch
        return;
    end
    if ~ismember('worker_id', T.Properties.VariableNames) || ~ismember('log_file', T.Properties.VariableNames)
        return;
    end
    workerMeta = T(:, intersect({'worker_id', 'log_file'}, T.Properties.VariableNames, 'stable'));
end

function stats = autosimMonitorReadWorkerStatsFromLogs(workerMeta)
    stats = struct();
    stats.workerIds = [];
    stats.scenarioNow = [];
    stats.scenarioTotal = [];
    stats.exceptionCount = [];
    stats.exceptionRate = [];
    stats.policyExploit = [];
    stats.policyBoundary = [];
    stats.policyHardNeg = [];
    stats.learnN = [];
    stats.learnStable = [];
    stats.learnUnstable = [];
    stats.learnStableRatio = [];

    if isempty(workerMeta)
        return;
    end

    for i = 1:height(workerMeta)
        wid = str2double(string(workerMeta.worker_id(i)));
        if ~isfinite(wid)
            continue;
        end
        logPath = string(workerMeta.log_file(i));
        txt = autosimMonitorReadLogTail(logPath, 250000);

        [scenarioNow, scenarioTotal] = autosimMonitorParseScenarioProgress(txt);
        exceptionCount = autosimMonitorRegexCount(txt, '\\[AUTOSIM\\]\\s+Scenario\\s+\\d+\\s+exception:');
        if scenarioNow > 0
            exceptionRate = min(1.0, exceptionCount / scenarioNow);
        else
            exceptionRate = nan;
        end

        [pExploit, pBoundary, pHard] = autosimMonitorParsePolicyMix(txt, 25);
        [learnN, learnStable, learnUnstable] = autosimMonitorParseLearningProgress(txt);
        denom = learnStable + learnUnstable;
        if denom > 0
            learnStableRatio = learnStable / denom;
        else
            learnStableRatio = nan;
        end

        stats.workerIds(end+1, 1) = round(wid); %#ok<AGROW>
        stats.scenarioNow(end+1, 1) = scenarioNow; %#ok<AGROW>
        stats.scenarioTotal(end+1, 1) = scenarioTotal; %#ok<AGROW>
        stats.exceptionCount(end+1, 1) = exceptionCount; %#ok<AGROW>
        stats.exceptionRate(end+1, 1) = exceptionRate; %#ok<AGROW>
        stats.policyExploit(end+1, 1) = pExploit; %#ok<AGROW>
        stats.policyBoundary(end+1, 1) = pBoundary; %#ok<AGROW>
        stats.policyHardNeg(end+1, 1) = pHard; %#ok<AGROW>
        stats.learnN(end+1, 1) = learnN; %#ok<AGROW>
        stats.learnStable(end+1, 1) = learnStable; %#ok<AGROW>
        stats.learnUnstable(end+1, 1) = learnUnstable; %#ok<AGROW>
        stats.learnStableRatio(end+1, 1) = learnStableRatio; %#ok<AGROW>
    end

    if ~isempty(stats.workerIds)
        [~, ord] = sort(stats.workerIds);
        fields = fieldnames(stats);
        for k = 1:numel(fields)
            v = stats.(fields{k});
            if isnumeric(v) && numel(v) == numel(ord)
                stats.(fields{k}) = v(ord);
            end
        end
    end
end

function txt = autosimMonitorReadLogTail(logPath, maxChars)
    txt = "";
    p = char(logPath);
    if ~isfile(p)
        return;
    end
    try
        raw = fileread(p);
        if nargin >= 2 && strlength(string(raw)) > maxChars
            txt = extractAfter(string(raw), strlength(string(raw)) - maxChars);
        else
            txt = string(raw);
        end
    catch
        txt = "";
    end
end

function [nowN, totalN] = autosimMonitorParseScenarioProgress(txt)
    nowN = 0;
    totalN = 0;
    if strlength(txt) == 0
        return;
    end
    tok = regexp(char(txt), '\\[AUTOSIM\\]\\s+Scenario\\s+(\\d+)\\/(\\d+)', 'tokens');
    if isempty(tok)
        return;
    end
    lastTok = tok{end};
    nowN = str2double(lastTok{1});
    totalN = str2double(lastTok{2});
    if ~isfinite(nowN), nowN = 0; end
    if ~isfinite(totalN), totalN = 0; end
end

function c = autosimMonitorRegexCount(txt, pattern)
    if strlength(txt) == 0
        c = 0;
        return;
    end
    m = regexp(char(txt), pattern, 'match');
    c = numel(m);
end

function [pExploit, pBoundary, pHard] = autosimMonitorParsePolicyMix(txt, recentN)
    pExploit = 0;
    pBoundary = 0;
    pHard = 0;
    if strlength(txt) == 0
        return;
    end
    tok = regexp(char(txt), '\\[AUTOSIM\\]\\s+Adaptive policy=([a-zA-Z_]+)', 'tokens');
    if isempty(tok)
        return;
    end
    vals = strings(numel(tok), 1);
    for i = 1:numel(tok)
        vals(i) = string(tok{i}{1});
    end
    vals = vals(max(1, end - recentN + 1):end);
    n = numel(vals);
    if n == 0
        return;
    end
    pExploit = sum(vals == "exploit") / n;
    pBoundary = sum(vals == "boundary_validation") / n;
    pHard = sum(vals == "hard_negative") / n;
end

function [n, stable, unstable] = autosimMonitorParseLearningProgress(txt)
    n = 0;
    stable = 0;
    unstable = 0;
    if strlength(txt) == 0
        return;
    end
    tok = regexp(char(txt), 'n=(\\d+),\\s*stable=(\\d+),\\s*unstable=(\\d+)', 'tokens');
    if isempty(tok)
        return;
    end
    lastTok = tok{end};
    n = str2double(lastTok{1});
    stable = str2double(lastTok{2});
    unstable = str2double(lastTok{3});
    if ~isfinite(n), n = 0; end
    if ~isfinite(stable), stable = 0; end
    if ~isfinite(unstable), unstable = 0; end
end

function [allExited, nAlive, totalWorkers] = autosimMonitorCheckWorkerExitStatus(pidTablePath)
    allExited = false;
    nAlive = 0;
    totalWorkers = 0;

    try
        T = readtable(pidTablePath, 'FileType', 'text', 'Delimiter', '\t');
    catch
        return;
    end

    if ~ismember('pid', T.Properties.VariableNames)
        return;
    end

    pids = double(T.pid);
    pids = pids(isfinite(pids) & pids > 0);
    totalWorkers = numel(pids);
    if totalWorkers == 0
        allExited = true;
        return;
    end

    for i = 1:totalWorkers
        pid = round(pids(i));
        [st, ~] = system(sprintf('kill -0 %d >/dev/null 2>&1', pid));
        if st == 0
            nAlive = nAlive + 1;
        end
    end

    allExited = (nAlive == 0);
end

function autosimSaveCheckpoint(cfg, results, traceStore, learningHistory, model, runStatus, reason)
    try
        % Ensure directories exist before saving
        autosimEnsureDirectories(cfg);
        
        % Convert cell array to struct array if needed
        if iscell(results)
            resultsStruct = autosimCellToStructArray(results);
        else
            resultsStruct = results;
        end
        
        summaryTbl = autosimSummaryTable(resultsStruct);
        checkpoint = struct();
        checkpoint.reason = string(reason);
        checkpoint.timestamp = string(datetime('now'));
        checkpoint.run_status = string(runStatus);
        checkpoint.n_rows = height(summaryTbl);

        save(cfg.persistence.checkpoint_mat, 'resultsStruct', 'summaryTbl', 'traceStore', 'learningHistory', 'model', 'checkpoint');
        writetable(summaryTbl, cfg.persistence.checkpoint_csv);
        if ~isempty(traceStore)
            writetable(traceStore, cfg.persistence.trace_csv);
        end
    catch ME
        warning('[AUTOSIM] Checkpoint save failed: %s', ME.message);
    end
end



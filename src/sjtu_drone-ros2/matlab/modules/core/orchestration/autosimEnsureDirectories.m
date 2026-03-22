function autosimEnsureDirectories(cfg)
    dirs = {cfg.paths.data_root, cfg.paths.log_root, cfg.paths.plot_root, cfg.paths.data_dir, cfg.paths.model_dir, cfg.paths.plot_dir, cfg.paths.log_dir};
    if isfield(cfg, 'persistence') && isstruct(cfg.persistence)
        if isfield(cfg.persistence, 'checkpoint_mat')
            dirs{end+1} = fileparts(cfg.persistence.checkpoint_mat); %#ok<AGROW>
        end
        if isfield(cfg.persistence, 'checkpoint_csv')
            dirs{end+1} = fileparts(cfg.persistence.checkpoint_csv); %#ok<AGROW>
        end
        if isfield(cfg.persistence, 'trace_csv')
            dirs{end+1} = fileparts(cfg.persistence.trace_csv); %#ok<AGROW>
        end
    end
    for i = 1:numel(dirs)
        d = dirs{i};
        if ~isempty(d) && ~exist(d, 'dir')
            try
                mkdir(d);
            catch ME
                % Ignore "directory already exists" errors (race condition in parallel)
                if ~contains(ME.message, 'already exists')
                    rethrow(ME);
                end
            end
        end
    end
end



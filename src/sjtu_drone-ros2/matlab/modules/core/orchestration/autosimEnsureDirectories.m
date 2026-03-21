function autosimEnsureDirectories(cfg)
    dirs = {cfg.paths.data_root, cfg.paths.log_root, cfg.paths.plot_root, cfg.paths.data_dir, cfg.paths.model_dir, cfg.paths.plot_dir, cfg.paths.log_dir};
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



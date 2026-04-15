function [predLabel, predScore] = autosimPredictGaussianNB(model, X, cfg)
    if nargin < 3
        cfg = [];
    end

    if autosimIsModuleEnabled(cfg, 'ai_engine')
        try
            [predLabel, predScore] = autosim_ai_engine('predict_gnb', model, X);
            predLabel = apply_decision_threshold(predScore, model, cfg);
            return;
        catch
        end
    end

    X = autosimSanitize(X);
    if isrow(X)
        X = reshape(X, 1, []);
    end
    [X, modelGpu, useGpu] = autosimMaybeToGpuForPredict(X, model, cfg);

    n = size(X, 1);
    c = numel(model.class_names);
    logp = zeros(n, c);

    for i = 1:c
        mu = modelGpu.mu(i,:);
        s2 = modelGpu.sigma2(i,:);
        lp = -0.5 * sum(log(2*pi*s2) + ((X - mu).^2) ./ s2, 2);
        lp = lp + log(max(modelGpu.prior(i), eps));
        logp(:,i) = lp;
    end

    [mx, idx] = max(logp, [], 2);
    predLabel = strings(n,1);
    for k = 1:n
        predLabel(k) = string(model.class_names(idx(k)));
    end

    lse = zeros(n,1);
    for k = 1:n
        a = logp(k,:) - mx(k);
        lse(k) = mx(k) + log(sum(exp(a)));
    end
    ex = exp(logp - max(logp, [], 2));
    post = ex ./ max(sum(ex, 2), eps);
    cls = string(model.class_names(:));
    attemptIdx = find(cls == "AttemptLanding", 1, 'first');
    if isempty(attemptIdx)
        attemptIdx = find(cls == "stable", 1, 'first');
    end
    if isempty(attemptIdx)
        predScore = exp(mx - lse);
    else
        predScore = post(:, attemptIdx);
    end

    if useGpu
        predScore = gather(predScore);
    end
    predLabel = apply_decision_threshold(predScore, model, cfg);
end

function predLabel = apply_decision_threshold(predScore, model, cfg)
threshold = 0.50;
if isstruct(cfg) && isfield(cfg, 'agent') && isfield(cfg.agent, 'prob_land_threshold') && isfinite(cfg.agent.prob_land_threshold)
    threshold = cfg.agent.prob_land_threshold;
end
if isstruct(model) && isfield(model, 'decision_threshold') && isfinite(model.decision_threshold)
    threshold = model.decision_threshold;
end
threshold = max(0.01, min(0.99, threshold));

score = double(predScore(:));
score(~isfinite(score)) = 0.0;
predLabel = repmat("HoldLanding", numel(score), 1);
predLabel(score >= threshold) = "AttemptLanding";
end

function [Xout, modelOut, useGpu] = autosimMaybeToGpuForPredict(Xin, modelIn, cfg)
    Xout = Xin;
    modelOut = modelIn;
    useGpu = false;
    try
        if ~(isstruct(cfg) && isfield(cfg, 'runtime') && isfield(cfg.runtime, 'use_gpu') && cfg.runtime.use_gpu)
            return;
        end
        if isfield(cfg.runtime, 'gpu_device') && isfinite(cfg.runtime.gpu_device)
            gpuDevice(max(1, round(cfg.runtime.gpu_device)));
        else
            gpuDevice();
        end
        Xout = gpuArray(Xin);
        modelOut.mu = gpuArray(modelIn.mu);
        modelOut.sigma2 = gpuArray(modelIn.sigma2);
        modelOut.prior = gpuArray(modelIn.prior);
        useGpu = true;
    catch
        Xout = Xin;
        modelOut = modelIn;
        useGpu = false;
    end
end



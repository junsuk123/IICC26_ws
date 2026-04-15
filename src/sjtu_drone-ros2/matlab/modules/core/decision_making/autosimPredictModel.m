function [predLabel, predScore] = autosimPredictModel(model, featStruct, featureNames, cfg)
    if nargin < 4
        cfg = [];
    end

    if autosimIsModuleEnabled(cfg, 'ai_engine')
        try
            [predLabel, predScore] = autosim_ai_engine('predict_model', model, featStruct, featureNames);
            predLabel = apply_decision_threshold(predScore, model, cfg);
            return;
        catch
        end
    end

    X = zeros(1, numel(featureNames));
    for i = 1:numel(featureNames)
        fn = char(featureNames(i));
        if isfield(featStruct, fn)
            X(i) = double(featStruct.(fn));
        end
    end

    [lbl, score] = autosimPredictGaussianNB(model, X, cfg);
    predLabel = lbl(1);
    predScore = score(1);
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

if isfinite(predScore) && (double(predScore) >= threshold)
    predLabel = "AttemptLanding";
else
    predLabel = "HoldLanding";
end
end



function cfg = autosimGetModelTypeConfig(baseConfig, modelType)
% autosimGetModelTypeConfig
% Returns model configuration based on model type: "aii_only" or "ontology_ai"
%
% Usage:
%   cfg = autosimGetModelTypeConfig(baseConfig, 'aii_only')
%   cfg = autosimGetModelTypeConfig(baseConfig, 'ontology_ai')

if nargin < 2 || isempty(modelType)
    modelType = 'ontology_ai';
end

cfg = baseConfig;
modelType = lower(string(modelType));

% Sensor-only AI model: uses only core sensor and control features
sensor_only_features = [ ...
    "mean_wind_speed", "max_wind_speed", "wind_velocity", "wind_acceleration", ...
    "mean_abs_roll_deg", "mean_abs_pitch_deg", "mean_abs_vz", "max_abs_vz", ...
    "mean_tag_error", "max_tag_error", "stability_std_z", "stability_std_vz", ...
    "mean_imu_ang_vel", "max_imu_ang_vel", "mean_imu_lin_acc", "max_imu_lin_acc" ...
];

% Extended features for wind body forces and arm imbalance
extended_sensor_features = [ ...
    sensor_only_features, ...
    "wind_velocity_x", "wind_velocity_y", "wind_acceleration_x", "wind_acceleration_y", ...
    "max_contact_force", "arm_force_imbalance", ...
    "final_altitude", "final_abs_speed" ...
];

% Ontology-driven semantic vector used by GaussianNB.
ontology_semantic_features = [ ...
    "r_body", "r_gust", "s_tilt", "s_descent", ...
    "s_lateral", "s_visual", "s_align", "s_context" ...
];

% Core sensor features to combine with ontology features (instantaneous raw values)
core_sensor_features = [ ...
    "wind_velocity_x", "wind_velocity_y", "wind_acceleration_x", "wind_acceleration_y", ...
    "final_roll_deg", "final_pitch_deg", "final_vz", "final_tag_error" ...
];

% Ontology+AI hybrid: combines ontology semantic features with core sensor features
ontology_ai_hybrid_features = [ ...
    ontology_semantic_features, ...
    core_sensor_features ...
];

cfg.model_type_selected = modelType;

switch modelType
    case "aii_only"
        % AI-only model: sensor and basic control features without ontology
        cfg.model.feature_names = sensor_only_features;
        cfg.model.schema_version = "decision_sensor_single_ai_v1";
        cfg.model.include_ontology_features = false;
        cfg.model.description = "AI-only model using core sensor and control features";
        
    case "ontology_ai"
        % Ontology+AI model: combines 8D ontology-derived semantic vector with core sensor features
        cfg.model.feature_names = ontology_ai_hybrid_features;
        cfg.model.schema_version = "decision_ontology_ai_hybrid_v1";
        cfg.model.include_ontology_features = true;
        cfg.model.description = "Ontology+AI model: 8D semantic + core sensor features (16D total)";
        
    otherwise
        error('autosimGetModelTypeConfig:InvalidModelType', ...
            'Invalid model type: %s. Use "aii_only" or "ontology_ai".', modelType);
end

% Store feature lists for reference and validation
cfg.model.sensor_only_features = sensor_only_features;
cfg.model.extended_sensor_features = extended_sensor_features;
cfg.model.ontology_semantic_features = ontology_semantic_features;
cfg.model.core_sensor_features = core_sensor_features;
cfg.model.ontology_ai_hybrid_features = ontology_ai_hybrid_features;

fprintf('[autosimGetModelTypeConfig] Selected model type: %s (%s)\n', ...
    modelType, cfg.model.description);
fprintf('[autosimGetModelTypeConfig] Feature count: %d\n', numel(cfg.model.feature_names));
end

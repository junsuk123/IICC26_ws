function scenarioCfg = autosimBuildScenarioConfig(cfg, scenarioId)
    scenarioCfg = struct();
    scenarioCfg.id = scenarioId;
    scenarioCfg.policy_mode = "exploit";
    scenarioCfg.policy_reason = "base";
    scenarioCfg.policy_weight_exploit = nan;
    scenarioCfg.policy_weight_boundary = nan;
    scenarioCfg.policy_weight_hard_negative = nan;
    scenarioCfg.boundary_hint = false;
    scenarioCfg.hard_negative_hint = false;
    scenarioCfg.safe_probe_ratio_boost = 0.0;
    scenarioCfg.probe_landing_selected = false;
    scenarioCfg.probe_landing_probability = 0.0;
    scenarioCfg.probe_landing_reason = "none";
    scenarioCfg.target_case = "none";
    scenarioCfg.force_hover_abort_timeout = false;
    scenarioCfg.force_land_at_timeout = false;
    scenarioCfg.hover_timeout_sec = nan;
    scenarioCfg.pre_landing_timeout_sec = autosimClampNaN(cfg.scenario.pre_landing_timeout_sec, nan);
    scenarioCfg.hover_height_m = autosimRandRange(cfg.scenario.hover_height_min_m, cfg.scenario.hover_height_max_m);
    scenarioCfg.ekf_uncertainty_bias = autosimRandRange(cfg.scenario.ekf_uncertainty_bias_min, cfg.scenario.ekf_uncertainty_bias_max);
    scenarioCfg.gps_dropout_enable = rand() < autosimClampNaN(cfg.scenario.gps_dropout_probability, 0.0);
    scenarioCfg.gps_dropout_start_sec = autosimRandRange(cfg.scenario.gps_dropout_start_min_sec, cfg.scenario.gps_dropout_start_max_sec);
    scenarioCfg.gps_dropout_duration_sec = autosimRandRange(cfg.scenario.gps_dropout_duration_min_sec, cfg.scenario.gps_dropout_duration_max_sec);
    scenarioCfg.moving_pad_enable = rand() < autosimClampNaN(cfg.scenario.moving_pad_probability, 0.0);
    scenarioCfg.moving_pad_amp_u = autosimRandRange(cfg.scenario.moving_pad_amp_u_min, cfg.scenario.moving_pad_amp_u_max);
    scenarioCfg.moving_pad_amp_v = autosimRandRange(cfg.scenario.moving_pad_amp_v_min, cfg.scenario.moving_pad_amp_v_max);
    scenarioCfg.moving_pad_freq_hz = autosimRandRange(cfg.scenario.moving_pad_freq_min_hz, cfg.scenario.moving_pad_freq_max_hz);
    scenarioCfg.moving_pad_profile = string(autosimFieldOr(cfg.scenario, 'moving_pad_profile', "triangular_velocity_reciprocating"));
    scenarioCfg.wind_profile_offset_sec = 0;
    if cfg.wind.enable
        [scenarioCfg.wind_speed, scenarioCfg.wind_dir] = autosimPickScenarioWind(cfg, scenarioId);
        scenarioCfg.wind_profile_offset_sec = autosimPickScenarioWindOffsetSec(cfg, scenarioId);
    else
        scenarioCfg.wind_speed = 0.0;
        scenarioCfg.wind_dir = 0.0;
    end
    scenarioCfg = autosimApplyValidationScenarioConfig(cfg, scenarioCfg, scenarioId);
end

function v = autosimFieldOr(s, name, fallback)
if isstruct(s) && isfield(s, name)
    v = s.(name);
    return;
end
v = fallback;
end



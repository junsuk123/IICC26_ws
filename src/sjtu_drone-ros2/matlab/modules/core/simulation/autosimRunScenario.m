function [res, traceTbl] = autosimRunScenario(cfg, scenarioCfg, scenarioId, model, rosCtx)
    subState = rosCtx.subState;
    subPose = rosCtx.subPose;
    subVel = rosCtx.subVel;
    subTag = rosCtx.subTag;
    subWind = rosCtx.subWind;
    subImu = rosCtx.subImu;
    subBumpers = rosCtx.subBumpers;
    bumperMsgType = "";
    bumperMsgUnsupported = false;
    if isfield(rosCtx, 'bumper_msg_type')
        bumperMsgType = string(rosCtx.bumper_msg_type);
    end
    if isfield(rosCtx, 'bumper_msg_unsupported')
        bumperMsgUnsupported = logical(rosCtx.bumper_msg_unsupported);
    end

    skipRetryIfUnsupported = true;
    if isfield(cfg, 'ros') && isfield(cfg.ros, 'bumper_skip_retry_if_msg_unsupported')
        skipRetryIfUnsupported = logical(cfg.ros.bumper_skip_retry_if_msg_unsupported);
    end

    if isempty(subBumpers) && isfield(cfg, 'ros') && isfield(cfg.ros, 'enable_bumper_subscription') && cfg.ros.enable_bumper_subscription && ...
            ~(skipRetryIfUnsupported && bumperMsgUnsupported)
        [subBumpers, bumperMsgType, bumperDiag] = autosimCreateBumperSubscriber(rosCtx.node, cfg, true);
        if isstruct(bumperDiag) && isfield(bumperDiag, 'msg_unsupported')
            bumperMsgUnsupported = logical(bumperDiag.msg_unsupported);
        end
        if ~isempty(subBumpers)
            fprintf('[AUTOSIM] Bumper subscriber connected: %s (%s)\n', cfg.topics.bumpers, bumperMsgType);
        else
            warning('[AUTOSIM] Bumper subscriber unavailable on %s. Contact-metric requirement will be relaxed for this scenario.', cfg.topics.bumpers);
        end
    end

    cfgEval = cfg;
    if isempty(subBumpers)
        if isfield(cfgEval, 'thresholds')
            cfgEval.thresholds.require_contact_metrics = false;
        end
    end

    pubWind = rosCtx.pubWind;
    pubTakeoff = rosCtx.pubTakeoff;
    pubLand = rosCtx.pubLand;
    pubCmd = rosCtx.pubCmd;
    pubTrajectoryGuidance = [];
    if isfield(rosCtx, 'pubTrajectoryGuidance')
        pubTrajectoryGuidance = rosCtx.pubTrajectoryGuidance;
    end
    pubTrajectoryGuidanceMarker = [];
    if isfield(rosCtx, 'pubTrajectoryGuidanceMarker')
        pubTrajectoryGuidanceMarker = rosCtx.pubTrajectoryGuidanceMarker;
    end
    pubPosCtrl = [];
    if isfield(rosCtx, 'pubPosCtrl')
        pubPosCtrl = rosCtx.pubPosCtrl;
    end
    pubPosCtrlFollowers = {};
    if isfield(rosCtx, 'pubPosCtrlFollowers')
        pubPosCtrlFollowers = rosCtx.pubPosCtrlFollowers;
    end
    followerCount = 0;
    if isfield(rosCtx, 'pubCmdFollowers')
        followerCount = numel(rosCtx.pubCmdFollowers);
    end

    tagCallbackEnabled = isfield(rosCtx, 'tag_callback_enabled') && rosCtx.tag_callback_enabled;
    tagCacheKey = "";
    if isfield(rosCtx, 'tag_cache_key')
        tagCacheKey = string(rosCtx.tag_cache_key);
    end

    msgWind = rosCtx.msgWind;
    msgTakeoff = rosCtx.msgTakeoff;
    msgLand = rosCtx.msgLand;
    msgCmd = rosCtx.msgCmd;
    msgTrajectoryGuidance = [];
    if isfield(rosCtx, 'msgTrajectoryGuidance')
        msgTrajectoryGuidance = rosCtx.msgTrajectoryGuidance;
    end
    msgTrajectoryGuidanceMarker = [];
    if isfield(rosCtx, 'msgTrajectoryGuidanceMarker')
        msgTrajectoryGuidanceMarker = rosCtx.msgTrajectoryGuidanceMarker;
    end
    msgPosCtrl = [];
    if isfield(rosCtx, 'msgPosCtrl')
        msgPosCtrl = rosCtx.msgPosCtrl;
    end

    sampleN = 200;

    t = zeros(sampleN,1);
    xPos = nan(sampleN,1);
    yPos = nan(sampleN,1);
    z = nan(sampleN,1);
    vz = nan(sampleN,1);
    speedAbs = nan(sampleN,1);
    rollDeg = nan(sampleN,1);
    pitchDeg = nan(sampleN,1);
    tagErr = nan(sampleN,1);
    windSpeed = nan(sampleN,1);
    windDir = nan(sampleN,1);
    windCmdSpeed = nan(sampleN,1);
    windCmdDir = nan(sampleN,1);
    stateVal = nan(sampleN,1);
    contact = zeros(sampleN,1);
    imuAngVel = nan(sampleN,1);
    imuLinAcc = nan(sampleN,1);
    contactForce = nan(sampleN,1);
    armForceFL = nan(sampleN,1);
    armForceFR = nan(sampleN,1);
    armForceRL = nan(sampleN,1);
    armForceRR = nan(sampleN,1);
    predStableProb = nan(sampleN,1);
    decisionTxt = strings(sampleN,1);
    phaseTxt = strings(sampleN,1);
    semanticWindRisk = strings(sampleN,1);
    semanticEnvironment = strings(sampleN,1);
    semanticDroneState = strings(sampleN,1);
    semanticAlign = strings(sampleN,1);
    semanticVisual = strings(sampleN,1);
    semanticSafe = false(sampleN,1);
    landingFeasibility = nan(sampleN,1);
    windBodyForceX = nan(sampleN,1);
    windBodyForceY = nan(sampleN,1);
    windBodyForce = nan(sampleN,1);
    windBodyRisk = nan(sampleN,1);
    windGustRisk = nan(sampleN,1);
    windDirChangeRisk = nan(sampleN,1);
    windRiskRaw = nan(sampleN,1);
    thrustMargin = nan(sampleN,1);
    semFeat = nan(sampleN, numel(cfg.ontology.semantic_feature_names));
    cmdXLog = nan(sampleN,1);
    cmdYLog = nan(sampleN,1);
    cmdZLog = nan(sampleN,1);
    ekfUncertaintyLog = nan(sampleN,1);
    gpsDropoutActiveLog = zeros(sampleN,1);
    movingPadOffsetULog = nan(sampleN,1);
    movingPadOffsetVLog = nan(sampleN,1);
    movingPadVelULog = nan(sampleN,1);
    movingPadVelVLog = nan(sampleN,1);
    trajectoryIntentTxt = strings(sampleN,1);
    trajectoryTargetULog = nan(sampleN,1);
    trajectoryTargetVLog = nan(sampleN,1);
    trajectoryTargetXLog = nan(sampleN,1);
    trajectoryTargetYLog = nan(sampleN,1);
    trajectoryTargetZLog = nan(sampleN,1);
    trajectoryQualityLog = nan(sampleN,1);
    navInstabilityLog = nan(sampleN,1);
    windHazardousLog = zeros(sampleN,1);
    followerExpectedLog = zeros(sampleN,1);
    followerPoseReadyLog = zeros(sampleN,1);
    followerStateReadyLog = zeros(sampleN,1);
    followerTagDetectLog = zeros(sampleN,1);
    followerFlyingLog = zeros(sampleN,1);
    followerCmdRmsLog = nan(sampleN,1);

    tagHist = nan(cfg.control.tag_history_len, 2);
    tagHistCount = 0;
    lastTagDetectT = -inf;
    lastTagU = nan;
    lastTagV = nan;
    haveLastTag = false;

    histN = max(20, round(8.0 / cfg.scenario.sample_period_sec));
    windSpeedHist = nan(histN, 1);
    windSpeedHistCount = 0;
    windDirHist = nan(histN, 1);
    windDirHistCount = 0;
    windVelXHist = nan(histN, 1);
    windVelXHistCount = 0;
    windVelYHist = nan(histN, 1);
    windVelYHistCount = 0;
    tagDetHist = nan(histN, 1);
    tagDetHistCount = 0;

    lastTakeoffT = -inf;
    takeoffCmdCount = 0;
    takeoffBroadcastUntil = nan;
    lastPosCtrlT = -inf;
    lastWindT = -inf;
    lastDecisionT = -inf;
    lastCtrlT = 0.0;

    controlPhase = "pre_takeoff_stabilize";
    phaseEnterT = 0.0;
    hoverStartT = nan;
    decisionEvalStartT = nan;
    hoverCenterHoldStartT = nan;
    preTakeoffCenterHoldStartT = nan;
    windArmed = false;
    analysisActive = false;
    analysisStartIdx = nan;
    analysisStartT = nan;
    analysisDataSeen = false;

    tagLockHoldStartT = nan;
    tagLockAcquired = false;
    randomLandingPlanned = false;
    randomLandingStartT = nan;
    randomLandingEndT = nan;
    randomBiasX = 0.0;
    randomBiasY = 0.0;
    tagLostSearchStartT = nan;

    tagLostFollowers = nan(max(1, followerCount), 1);
    lastTagUFollowers = nan(max(1, followerCount), 1);
    lastTagVFollowers = nan(max(1, followerCount), 1);
    lastTagDetectFollowers = -inf(max(1, followerCount), 1);
    haveLastTagFollowers = false(max(1, followerCount), 1);
    tagRxCountFollowers = zeros(max(1, followerCount), 1);
    stateFollowers = nan(max(1, followerCount), 1);

    landingSent = false;
    landingSentT = nan;
    landingStartZ = nan;
    landingTargetZ = nan;
    landingPadLockX = nan;
    landingPadLockY = nan;
    landingPadLockValid = false;
    landingPadStableFrames = 0;
    padGlobalMeanX = nan;
    padGlobalMeanY = nan;
    padGlobalObsCount = 0;
    padGlobalValid = false;
    padGlobalAnnounced = false;
    landingDecisionMode = "HoldLanding";
    executedAction = "HoldLanding";
    actionSource = "policy_hold";
    targetCase = "none";
    if isfield(scenarioCfg, 'target_case')
        targetCase = string(scenarioCfg.target_case);
    end
    hoverTimeoutDecisionDone = false;
    probeLandingTriggered = false;
    probeLandingReason = "none";
    probePolicySelected = isfield(scenarioCfg, 'probe_landing_selected') && logical(scenarioCfg.probe_landing_selected);
    ekfUncertaintyBias = autosimClampNaN(autosimFieldOrDefault(scenarioCfg, 'ekf_uncertainty_bias', 0.05), 0.0);
    gpsDropoutEnable = logical(autosimFieldOrDefault(scenarioCfg, 'gps_dropout_enable', false));
    gpsDropoutStartSec = autosimClampNaN(autosimFieldOrDefault(scenarioCfg, 'gps_dropout_start_sec', inf), inf);
    gpsDropoutDurationSec = max(0.0, autosimClampNaN(autosimFieldOrDefault(scenarioCfg, 'gps_dropout_duration_sec', 0.0), 0.0));
    gpsDropoutEndSec = gpsDropoutStartSec + gpsDropoutDurationSec;
    movingPadEnable = logical(autosimFieldOrDefault(scenarioCfg, 'moving_pad_enable', false));
    movingPadAmpU = abs(autosimClampNaN(autosimFieldOrDefault(scenarioCfg, 'moving_pad_amp_u', 0.0), 0.0));
    movingPadAmpV = abs(autosimClampNaN(autosimFieldOrDefault(scenarioCfg, 'moving_pad_amp_v', 0.0), 0.0));
    movingPadFreqHz = abs(autosimClampNaN(autosimFieldOrDefault(scenarioCfg, 'moving_pad_freq_hz', 0.0), 0.0));
    requireLandingOutcomeEvaluation = false;
    scenarioTimeoutHit = false;
    collectionTimeoutHit = false;
    collectionTimeoutSec = autosimClampNaN(cfg.scenario.max_collection_timeout_sec, 120.0);
    if isfield(scenarioCfg, 'max_collection_timeout_sec') && isfinite(scenarioCfg.max_collection_timeout_sec)
        collectionTimeoutSec = max(0.0, scenarioCfg.max_collection_timeout_sec);
    end
    scenarioTimeoutSec = autosimClampNaN(cfg.scenario.pre_landing_timeout_sec, nan);
    if isfield(scenarioCfg, 'pre_landing_timeout_sec') && isfinite(scenarioCfg.pre_landing_timeout_sec)
        scenarioTimeoutSec = max(0.0, scenarioCfg.pre_landing_timeout_sec);
    end
    if (~isfinite(scenarioTimeoutSec) || scenarioTimeoutSec <= 0) && isfield(cfg.scenario, 'duration_sec') && isfinite(cfg.scenario.duration_sec)
        scenarioTimeoutSec = max(0.0, cfg.scenario.duration_sec);
    end
    if isfinite(collectionTimeoutSec) && (collectionTimeoutSec > 0) && isfinite(scenarioTimeoutSec) && (scenarioTimeoutSec > 0)
        scenarioTimeoutSec = min(scenarioTimeoutSec, collectionTimeoutSec);
    end
    landedHoldStartT = nan;
    kLast = 0;

    liveViz = struct();
    liveVizInitAttempted = false;
    enableScenarioLiveView = isfield(cfg, 'visualization') && isfield(cfg.visualization, 'enable_scenario_live_view') && cfg.visualization.enable_scenario_live_view;
    hasTrainedModel = autosimIsModelReliable(model, cfg);
    stopRequested = false;
    stopReason = "";

    t0 = tic;
    recvTimeoutSec = 0.01;
    if isfield(cfg, 'ros') && isfield(cfg.ros, 'receive_timeout_sec') && isfinite(cfg.ros.receive_timeout_sec)
        recvTimeoutSec = max(0.0, cfg.ros.receive_timeout_sec);
    end
    healthLogEnable = isfield(cfg, 'ros') && isfield(cfg.ros, 'health_log_enable') && cfg.ros.health_log_enable;
    healthLogPeriodSec = 1.0;
    if isfield(cfg, 'ros') && isfield(cfg.ros, 'health_log_period_sec') && isfinite(cfg.ros.health_log_period_sec)
        healthLogPeriodSec = max(0.2, cfg.ros.health_log_period_sec);
    end
    lastHealthLogT = -inf;
    lastPoseRxT = nan;
    lastVelRxT = nan;
    lastStateRxT = nan;
    lastTagRxT = nan;
    lastWindRxT = nan;
    tagRxCount = 0;
    windRxCount = 0;
    windPollEnabled = true;
    windPollDisableOnStartupStale = isfield(cfg, 'ros') && isfield(cfg.ros, 'wind_poll_disable_on_startup_stale') && logical(cfg.ros.wind_poll_disable_on_startup_stale);
    windPollDisableAfterSec = 2.5;
    if isfield(cfg, 'ros') && isfield(cfg.ros, 'wind_poll_disable_after_sec') && isfinite(cfg.ros.wind_poll_disable_after_sec)
        windPollDisableAfterSec = max(0.0, cfg.ros.wind_poll_disable_after_sec);
    end

    multiCountForHome = 1;
    if isfield(cfg, 'runtime') && isfield(cfg.runtime, 'multi_drone_count')
        multiCountForHome = max(1, round(double(cfg.runtime.multi_drone_count)));
    end
    spacingForHome = 3.0;
    if isfield(cfg, 'runtime') && isfield(cfg.runtime, 'multi_drone_spacing_m')
        spacingForHome = max(0.5, double(cfg.runtime.multi_drone_spacing_m));
    end
    primaryIndexForHome = 1;
    if isfield(cfg, 'runtime') && isfield(cfg.runtime, 'primary_drone_index')
        primaryIndexForHome = max(1, round(double(cfg.runtime.primary_drone_index)));
    end
    [primaryHomeX, primaryHomeY, ~] = autosimComputeSpawnPose(primaryIndexForHome, multiCountForHome, spacingForHome);

    k = 0;
    while true
        iterStartT = toc(t0);
        if autosimIsStopRequested()
            stopRequested = true;
            stopReason = autosimGetStopReason();
            fprintf('[AUTOSIM] Scenario %03d stop requested: %s\n', scenarioId, stopReason);
            break;
        end

        k = k + 1;
        if k > sampleN
            growN = 200;
            t = [t; zeros(growN,1)]; %#ok<AGROW>
            xPos = [xPos; nan(growN,1)]; %#ok<AGROW>
            yPos = [yPos; nan(growN,1)]; %#ok<AGROW>
            z = [z; nan(growN,1)]; %#ok<AGROW>
            vz = [vz; nan(growN,1)]; %#ok<AGROW>
            speedAbs = [speedAbs; nan(growN,1)]; %#ok<AGROW>
            rollDeg = [rollDeg; nan(growN,1)]; %#ok<AGROW>
            pitchDeg = [pitchDeg; nan(growN,1)]; %#ok<AGROW>
            tagErr = [tagErr; nan(growN,1)]; %#ok<AGROW>
            windSpeed = [windSpeed; nan(growN,1)]; %#ok<AGROW>
            windDir = [windDir; nan(growN,1)]; %#ok<AGROW>
            windCmdSpeed = [windCmdSpeed; nan(growN,1)]; %#ok<AGROW>
            windCmdDir = [windCmdDir; nan(growN,1)]; %#ok<AGROW>
            stateVal = [stateVal; nan(growN,1)]; %#ok<AGROW>
            contact = [contact; zeros(growN,1)]; %#ok<AGROW>
            imuAngVel = [imuAngVel; nan(growN,1)]; %#ok<AGROW>
            imuLinAcc = [imuLinAcc; nan(growN,1)]; %#ok<AGROW>
            contactForce = [contactForce; nan(growN,1)]; %#ok<AGROW>
            armForceFL = [armForceFL; nan(growN,1)]; %#ok<AGROW>
            armForceFR = [armForceFR; nan(growN,1)]; %#ok<AGROW>
            armForceRL = [armForceRL; nan(growN,1)]; %#ok<AGROW>
            armForceRR = [armForceRR; nan(growN,1)]; %#ok<AGROW>
            predStableProb = [predStableProb; nan(growN,1)]; %#ok<AGROW>
            decisionTxt = [decisionTxt; strings(growN,1)]; %#ok<AGROW>
            phaseTxt = [phaseTxt; strings(growN,1)]; %#ok<AGROW>
            semanticWindRisk = [semanticWindRisk; strings(growN,1)]; %#ok<AGROW>
            semanticEnvironment = [semanticEnvironment; strings(growN,1)]; %#ok<AGROW>
            semanticDroneState = [semanticDroneState; strings(growN,1)]; %#ok<AGROW>
            semanticAlign = [semanticAlign; strings(growN,1)]; %#ok<AGROW>
            semanticVisual = [semanticVisual; strings(growN,1)]; %#ok<AGROW>
            semanticSafe = [semanticSafe; false(growN,1)]; %#ok<AGROW>
            landingFeasibility = [landingFeasibility; nan(growN,1)]; %#ok<AGROW>
            windBodyForceX = [windBodyForceX; nan(growN,1)]; %#ok<AGROW>
            windBodyForceY = [windBodyForceY; nan(growN,1)]; %#ok<AGROW>
            windBodyForce = [windBodyForce; nan(growN,1)]; %#ok<AGROW>
            windBodyRisk = [windBodyRisk; nan(growN,1)]; %#ok<AGROW>
            windGustRisk = [windGustRisk; nan(growN,1)]; %#ok<AGROW>
            windDirChangeRisk = [windDirChangeRisk; nan(growN,1)]; %#ok<AGROW>
            windRiskRaw = [windRiskRaw; nan(growN,1)]; %#ok<AGROW>
            thrustMargin = [thrustMargin; nan(growN,1)]; %#ok<AGROW>
            semFeat = [semFeat; nan(growN, numel(cfg.ontology.semantic_feature_names))]; %#ok<AGROW>
            cmdXLog = [cmdXLog; nan(growN,1)]; %#ok<AGROW>
            cmdYLog = [cmdYLog; nan(growN,1)]; %#ok<AGROW>
            cmdZLog = [cmdZLog; nan(growN,1)]; %#ok<AGROW>
            ekfUncertaintyLog = [ekfUncertaintyLog; nan(growN,1)]; %#ok<AGROW>
            gpsDropoutActiveLog = [gpsDropoutActiveLog; zeros(growN,1)]; %#ok<AGROW>
            movingPadOffsetULog = [movingPadOffsetULog; nan(growN,1)]; %#ok<AGROW>
            movingPadOffsetVLog = [movingPadOffsetVLog; nan(growN,1)]; %#ok<AGROW>
            movingPadVelULog = [movingPadVelULog; nan(growN,1)]; %#ok<AGROW>
            movingPadVelVLog = [movingPadVelVLog; nan(growN,1)]; %#ok<AGROW>
            trajectoryIntentTxt = [trajectoryIntentTxt; strings(growN,1)]; %#ok<AGROW>
            trajectoryTargetULog = [trajectoryTargetULog; nan(growN,1)]; %#ok<AGROW>
            trajectoryTargetVLog = [trajectoryTargetVLog; nan(growN,1)]; %#ok<AGROW>
            trajectoryTargetXLog = [trajectoryTargetXLog; nan(growN,1)]; %#ok<AGROW>
            trajectoryTargetYLog = [trajectoryTargetYLog; nan(growN,1)]; %#ok<AGROW>
            trajectoryTargetZLog = [trajectoryTargetZLog; nan(growN,1)]; %#ok<AGROW>
            trajectoryQualityLog = [trajectoryQualityLog; nan(growN,1)]; %#ok<AGROW>
            navInstabilityLog = [navInstabilityLog; nan(growN,1)]; %#ok<AGROW>
            windHazardousLog = [windHazardousLog; zeros(growN,1)]; %#ok<AGROW>
            followerExpectedLog = [followerExpectedLog; zeros(growN,1)]; %#ok<AGROW>
            followerPoseReadyLog = [followerPoseReadyLog; zeros(growN,1)]; %#ok<AGROW>
            followerStateReadyLog = [followerStateReadyLog; zeros(growN,1)]; %#ok<AGROW>
            followerTagDetectLog = [followerTagDetectLog; zeros(growN,1)]; %#ok<AGROW>
            followerFlyingLog = [followerFlyingLog; zeros(growN,1)]; %#ok<AGROW>
            followerCmdRmsLog = [followerCmdRmsLog; nan(growN,1)]; %#ok<AGROW>
            sampleN = sampleN + growN;
        end

        tk = toc(t0);
        kLast = k;
        t(k) = tk;

        if ~landingSent && isfinite(collectionTimeoutSec) && (collectionTimeoutSec > 0) && (tk >= collectionTimeoutSec)
            collectionTimeoutHit = true;
            scenarioTimeoutHit = true;
            landingDecisionMode = "HoldLanding";
            executedAction = "HoldLanding";
            actionSource = "collection_timeout";
            decisionTxt(k) = "abort_by_collection_timeout";
            lastDecisionT = tk;
            fprintf('[AUTOSIM] s%03d collection timeout hit at t=%.1fs (limit=%.1fs).\n', scenarioId, tk, collectionTimeoutSec);
            break;
        end

        startupTelemetryReady = isfinite(lastPoseRxT) || isfinite(lastStateRxT);
        if ~landingSent && startupTelemetryReady && isfinite(scenarioTimeoutSec) && (scenarioTimeoutSec > 0) && (tk >= scenarioTimeoutSec)
            scenarioTimeoutHit = true;
            landingDecisionMode = "HoldLanding";
            executedAction = "HoldLanding";
            actionSource = "scenario_timeout";
            decisionTxt(k) = "abort_by_scenario_timeout";
            lastDecisionT = tk;
            fprintf('[AUTOSIM] s%03d pre-landing scenario timeout hit at t=%.1fs (limit=%.1fs).\n', scenarioId, tk, scenarioTimeoutSec);
            break;
        end

        if cfg.wind.enable && (tk - lastWindT) >= cfg.wind.update_period_sec
            [wsCmd, wdCmd] = autosimComputeWindCommand(cfg, scenarioCfg, tk, windArmed);
            windCmdSpeed(k) = wsCmd;
            windCmdDir(k) = wdCmd;
            msgWind.data = single([wsCmd, wdCmd]);
            send(pubWind, msgWind);
            lastWindT = tk;
        end

        poseMsg = autosimTryReceive(subPose, recvTimeoutSec);
        if ~isempty(poseMsg)
            lastPoseRxT = tk;
            xPos(k) = double(poseMsg.position.x);
            yPos(k) = double(poseMsg.position.y);
            z(k) = double(poseMsg.position.z);
            q = poseMsg.orientation;
            [r, p, ~] = autosimQuat2Eul([q.w, q.x, q.y, q.z]);
            rollDeg(k) = abs(rad2deg(r));
            pitchDeg(k) = abs(rad2deg(p));
        end

        velMsg = autosimTryReceive(subVel, recvTimeoutSec);
        if ~isempty(velMsg)
            lastVelRxT = tk;
            vx = double(velMsg.linear.x);
            vy = double(velMsg.linear.y);
            vz(k) = double(velMsg.linear.z);
            speedAbs(k) = sqrt(vx*vx + vy*vy + vz(k)*vz(k));
        end

        stateMsg = autosimTryReceive(subState, recvTimeoutSec);
        if ~isempty(stateMsg)
            lastStateRxT = tk;
            stateVal(k) = double(stateMsg.data);
        end

        [hasFreshTag, tagDetected, uTag, vTag, te, tagRxCountNow] = autosimReadTagInput(subTag, recvTimeoutSec, tagCallbackEnabled, tagCacheKey, tagRxCount);
        tagVisibleNow = hasFreshTag && tagDetected && isfinite(uTag) && isfinite(vTag);
        if hasFreshTag
            lastTagRxT = tk;
            tagRxCount = tagRxCountNow;
            tagErr(k) = te;
        else
            tagDetected = false;
            uTag = nan;
            vTag = nan;
        end

        if tagDetected && isfinite(uTag) && isfinite(vTag)
            [tagHist, tagHistCount] = autosimPushTag(tagHist, tagHistCount, uTag, vTag);
            lastTagU = uTag;
            lastTagV = vTag;
            lastTagDetectT = tk;
            haveLastTag = true;
        elseif haveLastTag && ((tk - lastTagDetectT) <= cfg.control.tag_hold_timeout_sec)
            tagDetected = true;
            uTag = lastTagU;
            vTag = lastTagV;
            tagErr(k) = sqrt(uTag*uTag + vTag*vTag);
        end

        [predOk, uPred, vPred] = autosimPredictTagCenter(tagHist, tagHistCount, uTag, vTag, tk, lastTagDetectT, ...
            cfg.control.tag_predict_horizon_sec, cfg.control.tag_predict_timeout_sec, cfg.scenario.sample_period_sec, cfg.control.tag_min_predict_samples);

        gpsDropoutActiveNow = gpsDropoutEnable && isfinite(gpsDropoutStartSec) && isfinite(gpsDropoutEndSec) && ...
            (tk >= gpsDropoutStartSec) && (tk <= gpsDropoutEndSec);
        gpsDropoutActiveLog(k) = double(gpsDropoutActiveNow);

        padOffsetU = 0.0;
        padOffsetV = 0.0;
        padVelU = 0.0;
        padVelV = 0.0;
        padMovingNow = false;
        if movingPadEnable
            [padOffsetU, padOffsetV, padVelU, padVelV, padMovingNow] = autosimComputeMovingPadMotion(tk, scenarioCfg);
            if tagDetected && isfinite(uTag) && isfinite(vTag)
                uTag = uTag + padOffsetU;
                vTag = vTag + padOffsetV;
                tagErr(k) = sqrt(uTag*uTag + vTag*vTag);
            end
            if predOk && isfinite(uPred) && isfinite(vPred)
                uPred = uPred + padOffsetU;
                vPred = vPred + padOffsetV;
            end
        end
        movingPadOffsetULog(k) = padOffsetU;
        movingPadOffsetVLog(k) = padOffsetV;
        movingPadVelULog(k) = padVelU;
        movingPadVelVLog(k) = padVelV;

        poseAgeNow = tk - lastPoseRxT;
        velAgeNow = tk - lastVelRxT;
        tagAgeNow = tk - lastTagRxT;
        estUncertaintyNow = 0.10 + ekfUncertaintyBias + ...
            0.30 * double(~isfinite(lastPoseRxT) || poseAgeNow > 0.5) + ...
            0.20 * double(~isfinite(lastVelRxT) || velAgeNow > 0.5) + ...
            0.15 * double(~isfinite(lastTagRxT) || tagAgeNow > 0.6) + ...
            0.25 * double(gpsDropoutActiveNow);
        ekfUncertaintyLog(k) = autosimClamp(estUncertaintyNow, 0.0, 1.0);

        if windPollEnabled && windPollDisableOnStartupStale && ~isfinite(lastWindRxT) && (tk >= windPollDisableAfterSec)
            windPollEnabled = false;
            fprintf('[AUTOSIM] s%03d wind polling disabled after %.1fs startup stale window (no /wind_condition rx). Using command/profile fallback.\n', ...
                scenarioId, windPollDisableAfterSec);
        end

        windMsg = [];
        if windPollEnabled
            windMsg = autosimTryReceive(subWind, recvTimeoutSec);
        end
        windSpObs = nan;
        windDirObs = nan;
        if ~isempty(windMsg)
            lastWindRxT = tk;
            windRxCount = windRxCount + 1;
            [windSpObs, windDirObs] = autosimParseWindConditionMsg(windMsg);
            if isfinite(windSpObs)
                windSpeed(k) = windSpObs;
            end
        end

        if ~isempty(subImu)
            imuMsg = autosimTryReceive(subImu, recvTimeoutSec);
            if ~isempty(imuMsg)
                [imuAngVel(k), imuLinAcc(k)] = autosimParseImuMetrics(imuMsg);
            end
        end

        if ~isempty(subBumpers)
            bumpMsg = autosimTryReceive(subBumpers, recvTimeoutSec);
            if ~isempty(bumpMsg)
                [contact(k), contactForce(k), armForceFL(k), armForceFR(k), armForceRL(k), armForceRR(k)] = autosimParseContactForces(bumpMsg, bumperMsgType);
            end
        end

        windSpNow = windSpeed(k);
        if ~isfinite(windSpNow)
            windSpNow = windCmdSpeed(k);
        end
        if ~isfinite(windSpNow)
            windSpNow = scenarioCfg.wind_speed;
        end
        if ~isfinite(windSpNow)
            windSpNow = 0.0;
        end

        windDirNow = windDirObs;
        if ~isfinite(windDirNow)
            windDirNow = windCmdDir(k);
        end
        if ~isfinite(windDirNow)
            windDirNow = scenarioCfg.wind_dir;
        end
        if ~isfinite(windDirNow)
            windDirNow = 0.0;
        end
        windDir(k) = windDirNow;

        if healthLogEnable && ((tk - lastHealthLogT) >= healthLogPeriodSec)
            tagAge = tk - lastTagRxT;
            windAge = tk - lastWindRxT;
            poseAge = tk - lastPoseRxT;
            fprintf('[AUTOSIM] s%03d sensor_rx | loop=%.1fHz target=%.1fHz | pad=%s age=%.2fs err=%.3f det=%d rx=%d | wind=%s age=%.2fs sp=%.2f dir=%.1f rx=%d | pose_age=%.2fs\n', ...
                scenarioId, autosimSafeDivide(1.0, max(tk - iterStartT, cfg.scenario.sample_period_sec)), autosimSafeDivide(1.0, cfg.scenario.sample_period_sec), ...
                autosimStatusText(isfinite(lastTagRxT)), autosimClampNaN(tagAge, inf), autosimClampNaN(tagErr(k), nan), double(tagDetected), tagRxCount, ...
                autosimStatusText(isfinite(lastWindRxT)), autosimClampNaN(windAge, inf), autosimClampNaN(windSpNow, nan), autosimClampNaN(windDirNow, nan), windRxCount, ...
                autosimClampNaN(poseAge, inf));
            lastHealthLogT = tk;
        end

        rollNowRad = deg2rad(autosimNanLast(rollDeg(1:k)));
        pitchNowRad = deg2rad(autosimNanLast(pitchDeg(1:k)));
        xNow = autosimNanLast(xPos(1:k));
        yNow = autosimNanLast(yPos(1:k));
        vzNow = autosimNanLast(vz(1:k));
        zNow = autosimNanLast(z(1:k));

        padGlobalEnable = isfield(cfg.control, 'pad_global_tracking_enable') && cfg.control.pad_global_tracking_enable;
        padGlobalUseInXYHold = padGlobalEnable && isfield(cfg.control, 'pad_global_tracking_use_in_xy_hold') && cfg.control.pad_global_tracking_use_in_xy_hold;
        padGlobalUseInLandingTrack = padGlobalEnable && isfield(cfg.control, 'pad_global_tracking_use_in_landing_track') && cfg.control.pad_global_tracking_use_in_landing_track;
        padGlobalScaleX = autosimClampNaN(cfg.control.pose_hold_cmd_limit, 0.35);
        padGlobalScaleY = padGlobalScaleX;
        if isfield(cfg.control, 'pad_global_tracking_scale_x_m_per_norm') && isfinite(cfg.control.pad_global_tracking_scale_x_m_per_norm)
            padGlobalScaleX = abs(cfg.control.pad_global_tracking_scale_x_m_per_norm);
        end
        if isfield(cfg.control, 'pad_global_tracking_scale_y_m_per_norm') && isfinite(cfg.control.pad_global_tracking_scale_y_m_per_norm)
            padGlobalScaleY = abs(cfg.control.pad_global_tracking_scale_y_m_per_norm);
        end
        padGlobalErrMax = autosimClampNaN(cfg.agent.max_tag_error_before_land, 0.90);
        if isfield(cfg.control, 'pad_global_tracking_obs_max_tag_error') && isfinite(cfg.control.pad_global_tracking_obs_max_tag_error)
            padGlobalErrMax = max(0.0, cfg.control.pad_global_tracking_obs_max_tag_error);
        end
        padGlobalMinSamples = 5;
        if isfield(cfg.control, 'pad_global_tracking_min_samples') && isfinite(cfg.control.pad_global_tracking_min_samples)
            padGlobalMinSamples = max(1, round(cfg.control.pad_global_tracking_min_samples));
        end

        if padGlobalEnable && isfinite(xNow) && isfinite(yNow) && tagVisibleNow
            errUObs = cfg.control.target_u - uTag;
            errVObs = cfg.control.target_v - vTag;
            padObsX = xNow + cfg.control.xy_map_sign_x_from_v * padGlobalScaleX * errVObs;
            padObsY = yNow + cfg.control.xy_map_sign_y_from_u * padGlobalScaleY * errUObs;
            tagErrObs = sqrt((uTag - cfg.control.target_u)^2 + (vTag - cfg.control.target_v)^2);
            useObs = (padGlobalObsCount == 0) || (tagErrObs <= padGlobalErrMax);
            if useObs && isfinite(padObsX) && isfinite(padObsY)
                padGlobalObsCount = padGlobalObsCount + 1;
                if padGlobalObsCount == 1 || ~isfinite(padGlobalMeanX) || ~isfinite(padGlobalMeanY)
                    padGlobalMeanX = padObsX;
                    padGlobalMeanY = padObsY;
                else
                    padGlobalMeanX = padGlobalMeanX + (padObsX - padGlobalMeanX) / padGlobalObsCount;
                    padGlobalMeanY = padGlobalMeanY + (padObsY - padGlobalMeanY) / padGlobalObsCount;
                end
            end
            if ~padGlobalValid && padGlobalObsCount >= padGlobalMinSamples && isfinite(padGlobalMeanX) && isfinite(padGlobalMeanY)
                padGlobalValid = true;
                if ~padGlobalAnnounced
                    fprintf('[AUTOSIM] s%03d global pad estimate ready (n=%d, x=%.2f, y=%.2f)\n', ...
                        scenarioId, padGlobalObsCount, padGlobalMeanX, padGlobalMeanY);
                    padGlobalAnnounced = true;
                end
            end
        end

        flyingStates = [1, 2];
        if isfield(cfg.control, 'takeoff_state_values') && ~isempty(cfg.control.takeoff_state_values)
            flyingStates = unique(double(cfg.control.takeoff_state_values(:)'));
            flyingStates = flyingStates(isfinite(flyingStates));
            if isempty(flyingStates)
                flyingStates = [1, 2];
            end
        end

        rearmAltMax = 0.8;
        if isfield(cfg.control, 'takeoff_rearm_altitude_max_m') && isfinite(cfg.control.takeoff_rearm_altitude_max_m)
            rearmAltMax = max(0.1, double(cfg.control.takeoff_rearm_altitude_max_m));
        end

        takeoffBroadcastWindowSec = 6.0;
        if isfield(cfg.control, 'takeoff_broadcast_window_sec') && isfinite(cfg.control.takeoff_broadcast_window_sec)
            takeoffBroadcastWindowSec = max(0.0, double(cfg.control.takeoff_broadcast_window_sec));
        end

        posCtrlReassertSec = 1.0;
        if isfield(cfg.control, 'posctrl_reassert_sec') && isfinite(cfg.control.posctrl_reassert_sec)
            posCtrlReassertSec = max(0.2, double(cfg.control.posctrl_reassert_sec));
        end

        if ~isempty(pubPosCtrl) && ~isempty(msgPosCtrl) && ((tk - lastPosCtrlT) >= posCtrlReassertSec)
            try
                send(pubPosCtrl, msgPosCtrl);
                for di = 1:numel(pubPosCtrlFollowers)
                    send(pubPosCtrlFollowers{di}, msgPosCtrl);
                end
                lastPosCtrlT = tk;
            catch
                % Keep control loop running even if posctrl assertion temporarily fails.
            end
        end

        % Keep takeoff retries active until broadcast window expires so late spawns can arm.
        if isfinite(takeoffBroadcastUntil)
            if (tk <= takeoffBroadcastUntil) && ((tk - lastTakeoffT) >= cfg.control.takeoff_retry_sec)
                autosimSendToFleet(rosCtx, 'takeoff', msgTakeoff);
                lastTakeoffT = tk;
            elseif tk > takeoffBroadcastUntil
                takeoffBroadcastUntil = nan;
            end
        end

        isFlying = false;
        if isfinite(stateVal(k))
            isFlying = any(abs(stateVal(k) - flyingStates) < 1e-9);
            % Guard against state-code mismatch by allowing altitude-based flying fallback.
            if ~isFlying && isfinite(z(k))
                isFlying = z(k) >= cfg.control.flying_altitude_threshold;
            end
        elseif isfinite(z(k))
            isFlying = z(k) >= cfg.control.flying_altitude_threshold;
        end
        isNearGround = isfinite(z(k)) && (z(k) <= rearmAltMax);

        dtCtrl = max(1e-3, tk - lastCtrlT);
        lastCtrlT = tk;

        tagLockReadyNow = false;
        if predOk && isfinite(uPred) && isfinite(vPred)
            e = sqrt((uPred - cfg.control.target_u)^2 + (vPred - cfg.control.target_v)^2);
            tagLockReadyNow = e <= cfg.learning.tag_lock_error_max;
        elseif tagDetected && isfinite(uTag) && isfinite(vTag)
            e = sqrt((uTag - cfg.control.target_u)^2 + (vTag - cfg.control.target_v)^2);
            tagLockReadyNow = e <= cfg.learning.tag_lock_error_max;
        end

        lockErrMax = cfg.learning.tag_lock_error_max;
        if isfield(cfg.control, 'landing_lock_max_tag_error') && isfinite(cfg.control.landing_lock_max_tag_error)
            lockErrMax = max(0.0, cfg.control.landing_lock_max_tag_error);
        end
        lockMinFrames = 8;
        if isfield(cfg.control, 'landing_lock_min_stable_frames') && isfinite(cfg.control.landing_lock_min_stable_frames)
            lockMinFrames = max(1, round(cfg.control.landing_lock_min_stable_frames));
        end
        lockAlpha = 0.20;
        if isfield(cfg.control, 'landing_lock_xy_blend_alpha') && isfinite(cfg.control.landing_lock_xy_blend_alpha)
            lockAlpha = autosimClamp(cfg.control.landing_lock_xy_blend_alpha, 0.0, 1.0);
        end
        lockEnable = isfield(cfg.control, 'landing_lock_enable') && cfg.control.landing_lock_enable;

        lockReadyNow = false;
        if predOk && isfinite(uPred) && isfinite(vPred)
            lockReadyNow = sqrt((uPred - cfg.control.target_u)^2 + (vPred - cfg.control.target_v)^2) <= lockErrMax;
        elseif tagDetected && isfinite(uTag) && isfinite(vTag)
            lockReadyNow = sqrt((uTag - cfg.control.target_u)^2 + (vTag - cfg.control.target_v)^2) <= lockErrMax;
        end

        if lockEnable && isFlying && (controlPhase == "xy_hold")
            if lockReadyNow && isfinite(xNow) && isfinite(yNow)
                landingPadStableFrames = landingPadStableFrames + 1;
                if ~landingPadLockValid
                    landingPadLockX = xNow;
                    landingPadLockY = yNow;
                else
                    landingPadLockX = (1.0 - lockAlpha) * landingPadLockX + lockAlpha * xNow;
                    landingPadLockY = (1.0 - lockAlpha) * landingPadLockY + lockAlpha * yNow;
                end
                if landingPadStableFrames >= lockMinFrames
                    if ~landingPadLockValid
                        fprintf('[AUTOSIM] s%03d landing lock acquired at (x=%.2f, y=%.2f), stable_frames=%d\n', ...
                            scenarioId, landingPadLockX, landingPadLockY, landingPadStableFrames);
                    end
                    landingPadLockValid = true;
                end
            else
                landingPadStableFrames = 0;
            end
        end

        cmdX = autosimClampNaN(xNow, primaryHomeX);
        cmdY = autosimClampNaN(yNow, primaryHomeY);
        cmdZ = autosimClampNaN(zNow, autosimClampNaN(cfg.control.land_cmd_alt_m, 0.2));
        trajGuidanceSourceCode = 0.0;
        trajPublishTargetX = cmdX;
        trajPublishTargetY = cmdY;
        trajPublishTargetZ = cmdZ;

        if landingSent && controlPhase ~= "landing_track"
            controlPhase = "landing_track";
        end

        switch char(controlPhase)
                case 'pre_takeoff_stabilize'
                    if cfg.control.pre_takeoff_require_tag_centered
                        centerReadyNow = predOk && isfinite(uPred) && isfinite(vPred) && ...
                            (sqrt((uPred - cfg.control.target_u)^2 + (vPred - cfg.control.target_v)^2) <= cfg.control.pre_takeoff_tag_center_tolerance);
                        if centerReadyNow
                            if ~isfinite(preTakeoffCenterHoldStartT)
                                preTakeoffCenterHoldStartT = tk;
                            end
                        else
                            preTakeoffCenterHoldStartT = nan;
                        end

                        centerHoldReady = isfinite(preTakeoffCenterHoldStartT) && ...
                            ((tk - preTakeoffCenterHoldStartT) >= cfg.control.pre_takeoff_tag_center_hold_sec);
                    else
                        centerHoldReady = true;
                    end

                    if centerHoldReady
                        controlPhase = "takeoff";
                        phaseEnterT = tk;
                    end

                case 'takeoff'
                    if ~isFlying && ((tk - lastTakeoffT) >= cfg.control.takeoff_retry_sec) && (takeoffCmdCount == 0 || isNearGround)
                        autosimSendToFleet(rosCtx, 'takeoff', msgTakeoff);
                        lastTakeoffT = tk;
                        takeoffCmdCount = takeoffCmdCount + 1;
                    end
                    if isFlying
                        takeoffBroadcastUntil = tk + takeoffBroadcastWindowSec;
                        controlPhase = "hover_settle";
                        phaseEnterT = tk;
                        hoverStartT = nan;
                        decisionEvalStartT = nan;
                        hoverCenterHoldStartT = nan;
                    end

                case 'hover_settle'
                    if ~isFlying && isNearGround
                        takeoffBroadcastUntil = nan;
                        controlPhase = "takeoff";
                        phaseEnterT = tk;
                        decisionEvalStartT = nan;
                    elseif (tk - phaseEnterT) >= cfg.control.hover_settle_sec
                        controlPhase = "xy_hold";
                        phaseEnterT = tk;
                        hoverStartT = tk;
                        decisionEvalStartT = tk;
                        hoverCenterHoldStartT = nan;
                        analysisActive = true;
                        analysisStartIdx = k + 1;
                        analysisStartT = tk;
                        tagHist = nan(cfg.control.tag_history_len, 2);
                        tagHistCount = 0;
                        windSpeedHist = nan(histN, 1);
                        windSpeedHistCount = 0;
                        windDirHist = nan(histN, 1);
                        windDirHistCount = 0;
                        tagDetHist = nan(histN, 1);
                        tagDetHistCount = 0;
                        tagLockHoldStartT = nan;
                        tagLockAcquired = false;
                        randomLandingPlanned = false;
                        randomLandingStartT = nan;
                        randomLandingEndT = nan;
                        randomBiasX = 0.0;
                        randomBiasY = 0.0;
                        lastDecisionT = -inf;
                        pause(max(0.0, cfg.scenario.sample_period_sec - (toc(t0) - iterStartT)));
                        continue;
                    end

                case 'xy_hold'
                    if ~isFlying && isNearGround
                        controlPhase = "takeoff";
                        phaseEnterT = tk;
                        hoverStartT = nan;
                        decisionEvalStartT = nan;
                        hoverCenterHoldStartT = nan;
                        tagLostSearchStartT = nan;
                    else
                        hasVisualObs = (predOk && isfinite(uPred) && isfinite(vPred)) || (tagDetected && isfinite(uTag) && isfinite(vTag));
                        if padGlobalUseInXYHold && padGlobalValid && ~hasVisualObs
                            tagLostSearchStartT = nan;
                            [cmdX, cmdY] = autosimComputePoseTrackingCommand(cfg, xNow, yNow, padGlobalMeanX, padGlobalMeanY);
                        else
                            [cmdX, cmdY, tagLostSearchStartT] = autosimComputeTagTrackingCommand( ...
                                cfg, tk, xNow, yNow, predOk, uPred, vPred, tagDetected, uTag, vTag, tagLostSearchStartT, primaryHomeX, primaryHomeY);
                        end

                        % In posctrl mode, cmd_vel.linear.z carries absolute altitude target.
                        if isfield(cfg.control, 'hover_z_hold_enable') && cfg.control.hover_z_hold_enable && ...
                                isfield(scenarioCfg, 'hover_height_m') && isfinite(scenarioCfg.hover_height_m) && ...
                                isfinite(z(k))
                            zTarget = double(scenarioCfg.hover_height_m);
                            zErr = zTarget - z(k);
                            zDeadband = 0.08;
                            if isfield(cfg.control, 'hover_z_hold_deadband_m') && isfinite(cfg.control.hover_z_hold_deadband_m)
                                zDeadband = max(0.0, double(cfg.control.hover_z_hold_deadband_m));
                            end
                            if abs(zErr) <= zDeadband
                                cmdZ = z(k);
                            else
                                cmdZ = zTarget;
                            end
                        elseif isfinite(zNow)
                            cmdZ = zNow;
                        end
                    end

                case 'landing_track'
                    if ~isFlying
                        cmdX = autosimClampNaN(xNow, primaryHomeX);
                        cmdY = autosimClampNaN(yNow, primaryHomeY);
                        cmdZ = autosimClampNaN(zNow, 0.0);
                    else
                        useLandingLockXY = isfield(cfg.control, 'landing_lock_enable') && cfg.control.landing_lock_enable && ...
                            isfield(cfg.control, 'landing_lock_xy_follow_enable') && cfg.control.landing_lock_xy_follow_enable && ...
                            landingPadLockValid;

                        usePadGlobalXY = padGlobalUseInLandingTrack && padGlobalValid;

                        if useLandingLockXY
                            tagLostSearchStartT = nan;
                            [cmdX, cmdY] = autosimComputePoseTrackingCommand(cfg, xNow, yNow, landingPadLockX, landingPadLockY);
                        elseif usePadGlobalXY
                            tagLostSearchStartT = nan;
                            [cmdX, cmdY] = autosimComputePoseTrackingCommand(cfg, xNow, yNow, padGlobalMeanX, padGlobalMeanY);
                        else
                            [cmdX, cmdY, tagLostSearchStartT] = autosimComputeTagTrackingCommand( ...
                                cfg, tk, xNow, yNow, predOk, uPred, vPred, tagDetected, uTag, vTag, tagLostSearchStartT, primaryHomeX, primaryHomeY);
                        end

                        if isfield(cfg.control, 'landing_use_z_tracking') && cfg.control.landing_use_z_tracking
                            if isfinite(zNow)
                                zRef = landingStartZ - cfg.control.landing_descent_rate_mps * max(0.0, tk - landingSentT);
                                zRef = max(cfg.control.landing_min_target_alt_m, zRef);
                                landingTargetZ = zRef;
                                cmdZ = landingTargetZ;
                            end
                        else
                            if ~isfinite(landingTargetZ)
                                landingTargetZ = autosimClampNaN(zNow, autosimClampNaN(cfg.control.land_cmd_alt_m, 0.2));
                            end
                            if isfinite(zNow) && (zNow <= cfg.control.landing_near_ground_alt_m)
                                descentRate = abs(cfg.control.landing_descent_rate_near_ground_mps);
                            else
                                descentRate = abs(cfg.control.landing_descent_rate_mps);
                            end
                            landingTargetZ = max(cfg.control.landing_min_target_alt_m, landingTargetZ - descentRate * dtCtrl);
                            cmdZ = landingTargetZ;
                        end
                    end
        end

        if analysisActive
            activeIdx = max(1, analysisStartIdx):k;
            activeSampleN = numel(activeIdx);
            rollEvalNowRad = deg2rad(autosimNanLast(rollDeg(activeIdx)));
            pitchEvalNowRad = deg2rad(autosimNanLast(pitchDeg(activeIdx)));
            xEvalNow = autosimNanLast(xPos(activeIdx));
            yEvalNow = autosimNanLast(yPos(activeIdx));
            vzEvalNow = autosimNanLast(vz(activeIdx));
            zEvalNow = autosimNanLast(z(activeIdx));

            tagJitterPx = autosimComputeTagJitterPx(tagHist, tagHistCount, cfg.ontology.tag_min_samples);
            tagStabilityScore = autosimComputeTagStabilityScore(tagJitterPx, cfg.ontology.tag_jitter_warn_px, cfg.ontology.tag_jitter_unsafe_px);
            tagCentered = tagDetected && isfinite(uTag) && isfinite(vTag) && ...
                (sqrt((uTag - cfg.control.target_u)^2 + (vTag - cfg.control.target_v)^2) <= cfg.agent.max_tag_error_before_land);

            [windSpeedHist, windSpeedHistCount] = autosimPushScalarHist(windSpeedHist, windSpeedHistCount, windSpNow);
            [windDirHist, windDirHistCount] = autosimPushScalarHist(windDirHist, windDirHistCount, windDirNow);
            [windVelNowX, windVelNowY] = autosimWindVectorFromSpeedDir(windSpNow, windDirNow);
            [windVelXHist, windVelXHistCount] = autosimPushScalarHist(windVelXHist, windVelXHistCount, windVelNowX);
            [windVelYHist, windVelYHistCount] = autosimPushScalarHist(windVelYHist, windVelYHistCount, windVelNowY);
            windAccNowX = autosimComputeWindAcceleration(windVelXHist(1:windVelXHistCount), cfg.scenario.sample_period_sec);
            windAccNowY = autosimComputeWindAcceleration(windVelYHist(1:windVelYHistCount), cfg.scenario.sample_period_sec);
            [tagDetHist, tagDetHistCount] = autosimPushScalarHist(tagDetHist, tagDetHistCount, double(tagDetected));

            detWin = max(5, round(2.0 / cfg.scenario.sample_period_sec));
            detCont = autosimNanMean(autosimTail(tagDetHist(1:tagDetHistCount), detWin));

            temporalHistN = max(12, round(max([cfg.ontology.gust_base_window_sec, cfg.ontology.temporal_long_window_sec]) / cfg.scenario.sample_period_sec));
            windObs = struct( ...
                'wind_speed', windSpNow, ...
                'wind_velocity', [windVelNowX; windVelNowY], ...
                'wind_velocity_mag', hypot(windVelNowX, windVelNowY), ...
                'wind_direction', windDirNow, ...
                'wind_speed_hist', windSpeedHist(1:windSpeedHistCount), ...
                'wind_dir_hist', windDirHist(1:windDirHistCount), ...
                'wind_vel_x_hist', windVelXHist(1:windVelXHistCount), ...
                'wind_vel_y_hist', windVelYHist(1:windVelYHistCount), ...
                'wind_acceleration', [windAccNowX; windAccNowY], ...
                'wind_acceleration_mag', hypot(windAccNowX, windAccNowY), ...
                'dt', cfg.scenario.sample_period_sec);
            droneObs = struct( ...
                'position', [xEvalNow; yEvalNow; zEvalNow], ...
                'roll', rollEvalNowRad, ...
                'pitch', pitchEvalNowRad, ...
                'roll_hist', deg2rad(autosimTail(rollDeg(activeIdx), temporalHistN)), ...
                'pitch_hist', deg2rad(autosimTail(pitchDeg(activeIdx), temporalHistN)), ...
                'vz_hist', autosimTail(vz(activeIdx), temporalHistN), ...
                'velocity', [0.0; 0.0; vzEvalNow], ...
                'estimation_uncertainty', autosimClampNaN(autosimNanLast(ekfUncertaintyLog(1:k)), 0.0), ...
                'gps_dropout_active', autosimClampNaN(autosimNanLast(gpsDropoutActiveLog(1:k)), 0.0));
            tagObs = struct( ...
                'detected', tagDetected, ...
                'u_norm', uTag, ...
                'v_norm', vTag, ...
                'u_pred', uPred, ...
                'v_pred', vPred, ...
                'jitter_px', tagJitterPx, ...
                'stability_score', tagStabilityScore, ...
                'detection_continuity', detCont, ...
                'err_hist', autosimTail(tagErr(activeIdx), temporalHistN), ...
                'detected_hist', autosimTail(tagDetHist(1:tagDetHistCount), temporalHistN), ...
                'centered', tagCentered);

            padObs = struct( ...
                'is_moving', double(padMovingNow), ...
                'offset_u', padOffsetU, ...
                'offset_v', padOffsetV, ...
                'velocity_u', padVelU, ...
                'velocity_v', padVelV);
            navObs = struct( ...
                'gnss_healthy', double(~gpsDropoutActiveNow), ...
                'ins_healthy', 1.0, ...
                'gps_dropout_active', double(gpsDropoutActiveNow), ...
                'covariance_trace', autosimClampNaN(ekfUncertaintyLog(k), 0.0));

            ontoState = autosimBuildOntologyState(windObs, droneObs, tagObs, cfg, padObs, navObs);
            semantic = autosimOntologyReasoning(ontoState, cfg);
            semVec = autosimBuildSemanticFeatures(windObs, droneObs, tagObs, semantic, cfg);

            semanticWindRisk(k) = string(semantic.wind_risk);
            semanticEnvironment(k) = string(semantic.environment_state);
            semanticDroneState(k) = string(semantic.drone_state);
            semanticAlign(k) = string(semantic.alignment_state);
            semanticVisual(k) = string(semantic.visual_state);
            semanticSafe(k) = logical(semantic.isSafeForLanding);
            landingFeasibility(k) = semantic.landing_feasibility;
            if isfield(semantic, 'wind_body_force_x')
                windBodyForceX(k) = double(semantic.wind_body_force_x);
            end
            if isfield(semantic, 'wind_body_force_y')
                windBodyForceY(k) = double(semantic.wind_body_force_y);
            end
            if isfield(semantic, 'wind_body_force')
                windBodyForce(k) = double(semantic.wind_body_force);
            end
            if isfield(semantic, 'wind_body_risk')
                windBodyRisk(k) = double(semantic.wind_body_risk);
            end
            if isfield(semantic, 'wind_gust_risk')
                windGustRisk(k) = double(semantic.wind_gust_risk);
            end
            if isfield(semantic, 'wind_dir_change_risk')
                windDirChangeRisk(k) = double(semantic.wind_dir_change_risk);
            end
            if isfield(semantic, 'wind_risk_raw')
                windRiskRaw(k) = double(semantic.wind_risk_raw);
            end
            if isfield(semantic, 'thrust_margin')
                thrustMargin(k) = double(semantic.thrust_margin);
            end
            trajectoryIntentTxt(k) = string(autosimVizField(semantic, 'trajectory_intent', "hold_and_align"));
            trajectoryTargetULog(k) = autosimClampNaN(autosimVizField(semantic, 'trajectory_target_u', 0.0), 0.0);
            trajectoryTargetVLog(k) = autosimClampNaN(autosimVizField(semantic, 'trajectory_target_v', 0.0), 0.0);
            trajectoryTargetZLog(k) = autosimClampNaN(autosimVizField(semantic, 'trajectory_target_altitude', zEvalNow), zEvalNow);
            trajectoryQualityLog(k) = autosimClampNaN(autosimVizField(semantic, 'trajectory_quality', 0.0), 0.0);
            navInstabilityLog(k) = autosimClampNaN(autosimVizField(semantic, 'navigation_instability', 0.0), 0.0);
            windHazardousLog(k) = double(logical(autosimVizField(semantic, 'wind_is_hazardous', false)));

            trajTargetXNow = xEvalNow + cfg.control.xy_map_sign_x_from_v * padGlobalScaleX * trajectoryTargetVLog(k);
            trajTargetYNow = yEvalNow + cfg.control.xy_map_sign_y_from_u * padGlobalScaleY * trajectoryTargetULog(k);
            trajectoryTargetXLog(k) = trajTargetXNow;
            trajectoryTargetYLog(k) = trajTargetYNow;
            trajPublishTargetX = trajTargetXNow;
            trajPublishTargetY = trajTargetYNow;
            trajPublishTargetZ = trajectoryTargetZLog(k);

            trajEnable = isfield(cfg, 'trajectory') && isfield(cfg.trajectory, 'enable') && cfg.trajectory.enable;
            requireModelForAiTrajectory = true;
            if isfield(cfg.trajectory, 'ai_follow_requires_model')
                requireModelForAiTrajectory = logical(cfg.trajectory.ai_follow_requires_model);
            end
            useAiTrajectory = trajEnable && ((~requireModelForAiTrajectory) || hasTrainedModel);
            usePngFallback = trajEnable && (~useAiTrajectory) && isfield(cfg.trajectory, 'png_fallback_enable') && cfg.trajectory.png_fallback_enable;

            if useAiTrajectory && isfinite(trajTargetXNow) && isfinite(trajTargetYNow) && ...
                    ((controlPhase == "xy_hold") || (controlPhase == "landing_track"))
                [trajCmdX, trajCmdY] = autosimComputePoseTrackingCommand(cfg, xNow, yNow, trajTargetXNow, trajTargetYNow);
                blendAlpha = 0.45;
                if isfield(cfg.trajectory, 'pad_motion_comp_gain') && isfinite(cfg.trajectory.pad_motion_comp_gain)
                    blendAlpha = autosimClamp(cfg.trajectory.pad_motion_comp_gain, 0.0, 1.0);
                end
                cmdX = (1.0 - blendAlpha) * cmdX + blendAlpha * trajCmdX;
                cmdY = (1.0 - blendAlpha) * cmdY + blendAlpha * trajCmdY;
                if isfinite(trajectoryTargetZLog(k)) && isfinite(zNow)
                    cmdZ = (1.0 - blendAlpha) * cmdZ + blendAlpha * trajectoryTargetZLog(k);
                end
                trajGuidanceSourceCode = 1.0;
            elseif usePngFallback && ((controlPhase == "xy_hold") || (controlPhase == "landing_track"))
                refX = trajTargetXNow;
                refY = trajTargetYNow;
                if landingPadLockValid && isfinite(landingPadLockX) && isfinite(landingPadLockY)
                    refX = landingPadLockX;
                    refY = landingPadLockY;
                elseif padGlobalValid && isfinite(padGlobalMeanX) && isfinite(padGlobalMeanY)
                    refX = padGlobalMeanX;
                    refY = padGlobalMeanY;
                end
                [pngCmdX, pngCmdY] = autosimComputePoseTrackingCommand(cfg, xNow, yNow, refX, refY, "png");
                cmdX = pngCmdX;
                cmdY = pngCmdY;
                if isfinite(trajectoryTargetZLog(k))
                    cmdZ = trajectoryTargetZLog(k);
                end
                trajectoryIntentTxt(k) = "png_guidance_fallback";
                trajGuidanceSourceCode = 2.0;
            end
            semFeat(k, :) = semVec;
            analysisDataSeen = true;

            if autosimPipelineTrainEnabled(cfg) && cfg.learning.enable && isFlying && (controlPhase == "xy_hold")
                if tagLockReadyNow
                    if ~isfinite(tagLockHoldStartT)
                        tagLockHoldStartT = tk;
                    end
                else
                    tagLockHoldStartT = nan;
                end

                if ~tagLockAcquired && isfinite(tagLockHoldStartT) && ((tk - tagLockHoldStartT) >= cfg.learning.tag_lock_hold_sec)
                    tagLockAcquired = true;
                    if probePolicySelected
                        randomLandingPlanned = true;
                        randomLandingStartT = tk + autosimRandRange(cfg.learning.random_landing_wait_min_sec, cfg.learning.random_landing_wait_max_sec);
                        randomLandingEndT = randomLandingStartT + autosimRandRange(cfg.learning.random_cmd_duration_min_sec, cfg.learning.random_cmd_duration_max_sec);
                        randomBiasX = autosimRandRange(-cfg.learning.random_xy_cmd_max, cfg.learning.random_xy_cmd_max);
                        randomBiasY = autosimRandRange(-cfg.learning.random_xy_cmd_max, cfg.learning.random_xy_cmd_max);
                    end
                end

                if randomLandingPlanned && ~landingSent
                    if tk >= randomLandingStartT && tk < randomLandingEndT
                        cmdX = autosimClamp(cmdX + randomBiasX, -abs(cfg.control.xy_cmd_limit), abs(cfg.control.xy_cmd_limit));
                        cmdY = autosimClamp(cmdY + randomBiasY, -abs(cfg.control.xy_cmd_limit), abs(cfg.control.xy_cmd_limit));
                    elseif tk >= randomLandingEndT
                    end
                end
            end

            hoverDelayOk = isfinite(hoverStartT) && ((tk - hoverStartT) >= cfg.wind.start_delay_after_hover_sec);
            if cfg.wind.start_require_tag_centered
                centerForWind = (controlPhase == "xy_hold") && isFlying && tagLockReadyNow;
                if centerForWind
                    if ~isfinite(hoverCenterHoldStartT)
                        hoverCenterHoldStartT = tk;
                    end
                else
                    hoverCenterHoldStartT = nan;
                end
                hoverCenterReady = isfinite(hoverCenterHoldStartT) && ((tk - hoverCenterHoldStartT) >= cfg.wind.start_tag_center_hold_sec);
            else
                hoverCenterReady = true;
            end

            forceWindByTimeout = isfinite(hoverStartT) && ((tk - hoverStartT) >= cfg.wind.start_force_after_hover_sec);

            if ~windArmed && cfg.wind.enable && hoverDelayOk && (hoverCenterReady || forceWindByTimeout)
                windArmed = true;
                if forceWindByTimeout && ~hoverCenterReady
                    fprintf('[AUTOSIM] s%03d wind armed by timeout at t=%.1fs (center-hold unmet)\n', scenarioId, tk);
                end
            end

            featIdx = activeIdx;
            onlineFeatWindowSec = 0.0;
            if isfield(cfg, 'agent') && isfield(cfg.agent, 'online_feature_window_sec') && isfinite(cfg.agent.online_feature_window_sec)
                onlineFeatWindowSec = max(0.0, double(cfg.agent.online_feature_window_sec));
            end
            if onlineFeatWindowSec > 0 && ~isempty(featIdx)
                tNowForFeat = t(k);
                if ~isfinite(tNowForFeat)
                    tNowForFeat = tk;
                end
                tMinForFeat = tNowForFeat - onlineFeatWindowSec;
                recentMask = t(featIdx) >= tMinForFeat;
                if any(recentMask)
                    featIdx = featIdx(recentMask);
                end
            end

            feat = autosimBuildOnlineFeatureVector(z(featIdx), vz(featIdx), speedAbs(featIdx), rollDeg(featIdx), pitchDeg(featIdx), ...
                tagErr(featIdx), windSpeed(featIdx), contact(featIdx), imuAngVel(featIdx), imuLinAcc(featIdx), ...
                contactForce(featIdx), armForceFL(featIdx), armForceFR(featIdx), armForceRL(featIdx), armForceRR(featIdx), semVec, cfg, ...
                windObs.wind_velocity, windObs.wind_acceleration);
            baselineMode = string(autosimFieldOrDefault(cfg.agent, 'baseline_mode', "sensor_ai_single"));
            sensorSingleAiBaseline = baselineMode == "sensor_ai_single";
            featureSchema = cfg.model.feature_names;
            if isfield(model, 'feature_names') && ~isempty(model.feature_names)
                featureSchema = model.feature_names;
            end
            requestedSemanticOnlyMode = isfield(cfg.agent, 'semantic_only_mode') && cfg.agent.semantic_only_mode;
            modelGateEnabled = cfg.agent.enable_model_decision && hasTrainedModel;
            semanticOnlyMode = requestedSemanticOnlyMode && ~modelGateEnabled && ~sensorSingleAiBaseline;
            semanticStableProb = autosimClampNaN(semantic.landing_feasibility, 0.0);
            decisionStableProb = semanticStableProb;
            if modelGateEnabled
                [predLabel, predScore] = autosimPredictModel(model, feat, featureSchema, cfg);
                if autosimIsAttemptLandingLabel(predLabel)
                    predStableProb(k) = predScore;
                else
                    predStableProb(k) = 1.0 - predScore;
                end

                if sensorSingleAiBaseline
                    decisionStableProb = autosimClamp(predStableProb(k), 0.0, 1.0);
                else
                    fusionWeight = autosimClampNaN(cfg.agent.model_semantic_fusion_weight, 0.65);
                    if isfield(cfg.agent, 'adaptive_fusion_by_ontology') && cfg.agent.adaptive_fusion_by_ontology
                        semBoost = 0.0;
                        if (~logical(semantic.isSafeForLanding))
                            semBoost = max(semBoost, autosimClampNaN(cfg.agent.fusion_semantic_boost_on_conflict, 0.20));
                        elseif autosimClampNaN(semantic.wind_risk_enc, 0.0) >= 0.65
                            semBoost = max(semBoost, autosimClampNaN(cfg.agent.fusion_semantic_boost_on_caution, 0.10));
                        end
                        fusionWeight = fusionWeight - semBoost;
                    end
                    fusionWeight = autosimClamp(fusionWeight, 0.0, 1.0);
                    decisionStableProb = fusionWeight * predStableProb(k) + (1.0 - fusionWeight) * semanticStableProb;

                    semanticAssistEnable = isfield(cfg.agent, 'semantic_assist_enable') && cfg.agent.semantic_assist_enable;
                    semanticAssistLandMin = autosimClampNaN(cfg.agent.semantic_assist_land_min, 0.78);
                    semanticAssistAbortMax = autosimClampNaN(cfg.agent.semantic_assist_abort_max, 0.28);
                    if semanticAssistEnable
                        if logical(semantic.isSafeForLanding) && (semanticStableProb >= semanticAssistLandMin)
                            decisionStableProb = max(decisionStableProb, semanticStableProb);
                        elseif (~logical(semantic.isSafeForLanding)) && (semanticStableProb <= semanticAssistAbortMax)
                            decisionStableProb = min(decisionStableProb, semanticStableProb);
                        end
                    end
                end
                decisionStableProb = autosimClamp(decisionStableProb, 0.0, 1.0);
            else
                if sensorSingleAiBaseline
                    predStableProb(k) = nan;
                    predLabel = "HoldLanding";
                    predScore = 0.0;
                    decisionStableProb = 0.0;
                else
                    predStableProb(k) = autosimClampNaN(semantic.landing_feasibility, 0.0);
                    if predStableProb(k) >= autosimClampNaN(cfg.agent.semantic_land_threshold, 0.70)
                        predLabel = "AttemptLanding";
                    else
                        predLabel = "HoldLanding";
                    end
                    predScore = predStableProb(k);
                    decisionStableProb = predStableProb(k);
                end
            end

            probeBoost = 0.0;
            if isfield(scenarioCfg, 'safe_probe_ratio_boost') && isfinite(scenarioCfg.safe_probe_ratio_boost)
                probeBoost = autosimClamp(scenarioCfg.safe_probe_ratio_boost, 0.0, 0.20);
            end
            adaptiveProbLandThreshold = autosimClamp(cfg.agent.prob_land_threshold - probeBoost, 0.05, 0.99);
            adaptiveSemanticLandThreshold = autosimClamp(cfg.agent.semantic_land_threshold - probeBoost, 0.05, 0.99);

            modelUncertainMargin = 0.0;
            if isfield(cfg.agent, 'model_uncertain_margin') && isfinite(cfg.agent.model_uncertain_margin)
                modelUncertainMargin = max(0.0, cfg.agent.model_uncertain_margin);
            end
            adaptiveProbAbortThreshold = autosimClamp(adaptiveProbLandThreshold - modelUncertainMargin, 0.01, 0.95);

            modelSaysStable = hasTrainedModel && modelGateEnabled && isfinite(decisionStableProb) && ...
                (decisionStableProb >= adaptiveProbLandThreshold);
            modelSaysUnstable = hasTrainedModel && modelGateEnabled && isfinite(decisionStableProb) && ...
                (decisionStableProb <= adaptiveProbAbortThreshold);
            modelIsUncertain = hasTrainedModel && modelGateEnabled && isfinite(decisionStableProb) && ...
                (~modelSaysStable) && (~modelSaysUnstable);

            ontologyGuardForModel = true;
            if (~sensorSingleAiBaseline) && isfield(cfg.agent, 'ontology_guard_enable') && cfg.agent.ontology_guard_enable
                visualEncNow = autosimClampNaN(semantic.visual_enc, 0.0);
                windRiskEncNow = autosimClampNaN(semantic.wind_risk_enc, 1.0);
                contextScoreNow = autosimClampNaN(semantic.landing_feasibility, 0.0);
                contextMinNow = autosimClampNaN(cfg.agent.ontology_guard_context_min, 0.45);

                ontologyGuardForModel = ...
                    (visualEncNow >= autosimClampNaN(cfg.agent.ontology_guard_visual_min, 0.35)) && ...
                    (windRiskEncNow <= autosimClampNaN(cfg.agent.ontology_guard_max_wind_risk, 0.80)) && ...
                    (contextScoreNow >= contextMinNow);

                % Allow high-confidence model decisions to pass guard when ontology signals are not adverse.
                if (~ontologyGuardForModel) && modelSaysStable
                    allowOverride = (~isfield(cfg.agent, 'ontology_guard_allow_model_override')) || cfg.agent.ontology_guard_allow_model_override;
                    overrideMargin = autosimClampNaN(cfg.agent.ontology_guard_model_override_margin, 0.10);
                    overrideVisualMin = autosimClampNaN(cfg.agent.ontology_guard_model_override_visual_min, 0.30);
                    overrideMaxWindRisk = autosimClampNaN(cfg.agent.ontology_guard_model_override_max_wind_risk, 0.75);
                    highConfModel = isfinite(decisionStableProb) && ...
                        (decisionStableProb >= (adaptiveProbLandThreshold + max(0.0, overrideMargin)));
                    if allowOverride && highConfModel && ...
                            (visualEncNow >= overrideVisualMin) && (windRiskEncNow <= overrideMaxWindRisk)
                        ontologyGuardForModel = true;
                    end
                end
            end
            modelStableBlockedByOntology = modelSaysStable && ~ontologyGuardForModel;

            if ~landingSent && cfg.agent.block_landing_if_unstable && modelSaysUnstable
                if cfg.agent.freeze_xy_if_unstable
                    cmdX = 0.0;
                    cmdY = 0.0;
                end
                if ~probePolicySelected
                    randomLandingPlanned = false;
                end
                if decisionTxt(k) == ""
                    decisionTxt(k) = "wait_hover_unstable";
                end
            elseif ~landingSent && modelStableBlockedByOntology && decisionTxt(k) == ""
                decisionTxt(k) = "hold_by_ontology_guard";
            elseif ~landingSent && modelIsUncertain && decisionTxt(k) == ""
                decisionTxt(k) = "wait_hover_uncertain";
            end

            hoverEvalReady = isFlying && (controlPhase == "xy_hold") && isfinite(decisionEvalStartT) && ...
                ((tk - decisionEvalStartT) >= cfg.agent.min_hover_eval_sec);

            canLandByModel = hoverEvalReady && hasTrainedModel && modelGateEnabled && ...
                (activeSampleN >= cfg.agent.min_samples_before_decision) && ...
                modelSaysStable && ...
                ontologyGuardForModel && ...
                isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.max_tag_error_before_land) && ...
                isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            canLandBySemantic = hoverEvalReady && semanticOnlyMode && ...
                isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.max_tag_error_before_land) && ...
                isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land) && ...
                isfinite(semantic.landing_feasibility) && (semantic.landing_feasibility >= adaptiveSemanticLandThreshold) && ...
                logical(semanticSafe(k)) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            evalWinN = max(5, round(cfg.agent.no_model_eval_window_sec / cfg.scenario.sample_period_sec));
            zWin = autosimTail(z(activeIdx), evalWinN);
            xWin = autosimTail(xPos(activeIdx), evalWinN);
            yWin = autosimTail(yPos(activeIdx), evalWinN);
            [zOscStd, zFlipRateHz] = autosimCalcZOscillationMetrics(zWin, cfg.scenario.sample_period_sec);
            [xyStd, xySpeedRms] = autosimCalcXYMotionMetrics(xWin, yWin, cfg.scenario.sample_period_sec);
            xyRadiusNow = sqrt(xEvalNow*xEvalNow + yEvalNow*yEvalNow);

            useRelationalBaseline = baselineMode == "ontology_relational";

            relationalBaselineScore = autosimClamp( ...
                0.45 * autosimClampNaN(semantic.landing_feasibility, 0.0) + ...
                0.25 * (1.0 - autosimClampNaN(autosimVizField(semantic, 'relation_wind_control', 0.0), 0.0)) + ...
                0.20 * autosimClampNaN(autosimVizField(semantic, 'relation_visual_alignment', 0.0), 0.0) + ...
                0.10 * (1.0 - autosimClampNaN(autosimVizField(semantic, 'relation_estimation_conflict', 0.0), 0.0)), 0.0, 1.0);

            canLandByRelationalBaseline = hoverEvalReady && (~modelGateEnabled) && (~semanticOnlyMode) && cfg.agent.no_model_fallback_enable && useRelationalBaseline && ...
                (~sensorSingleAiBaseline) && ...
                (activeSampleN >= cfg.agent.no_model_min_samples_before_land) && ...
                isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.no_model_max_tag_error) && ...
                isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land) && ...
                (relationalBaselineScore >= adaptiveSemanticLandThreshold) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            canLandByNoModelThreshold = hoverEvalReady && (~modelGateEnabled) && (~semanticOnlyMode) && cfg.agent.no_model_fallback_enable && ...
                (~sensorSingleAiBaseline) && ...
                (~useRelationalBaseline) && ...
                (activeSampleN >= cfg.agent.no_model_min_samples_before_land) && ...
                isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.no_model_max_tag_error) && ...
                isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land) && ...
                isfinite(vzEvalNow) && (abs(vzEvalNow) <= cfg.agent.no_model_max_abs_vz) && ...
                isfinite(zOscStd) && (zOscStd <= cfg.agent.no_model_max_z_osc_std) && ...
                isfinite(zFlipRateHz) && (zFlipRateHz <= cfg.agent.no_model_max_z_flip_rate_hz) && ...
                isfinite(xyStd) && (xyStd <= cfg.agent.no_model_max_xy_std) && ...
                isfinite(xySpeedRms) && (xySpeedRms <= cfg.agent.no_model_max_xy_speed_rms) && ...
                isfinite(xyRadiusNow) && (xyRadiusNow <= cfg.agent.no_model_max_xy_radius) && ...
                isfinite(autosimNanLast(rollDeg(activeIdx))) && (abs(autosimNanLast(rollDeg(activeIdx))) <= cfg.agent.no_model_max_abs_roll_pitch_deg) && ...
                isfinite(autosimNanLast(pitchDeg(activeIdx))) && (abs(autosimNanLast(pitchDeg(activeIdx))) <= cfg.agent.no_model_max_abs_roll_pitch_deg) && ...
                isfinite(windSpNow) && (windSpNow <= cfg.agent.no_model_max_wind_speed) && ...
                (~cfg.agent.no_model_require_semantic_safe || semanticSafe(k)) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            canLandByUncertainModelFallback = hoverEvalReady && hasTrainedModel && modelGateEnabled && modelIsUncertain && ...
                (~sensorSingleAiBaseline) && ...
                isfield(cfg.agent, 'model_uncertain_fallback_enable') && cfg.agent.model_uncertain_fallback_enable && ...
                ontologyGuardForModel && ...
                (activeSampleN >= cfg.agent.no_model_min_samples_before_land) && ...
                isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.no_model_max_tag_error) && ...
                isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land) && ...
                isfinite(vzEvalNow) && (abs(vzEvalNow) <= cfg.agent.no_model_max_abs_vz) && ...
                isfinite(zOscStd) && (zOscStd <= cfg.agent.no_model_max_z_osc_std) && ...
                isfinite(zFlipRateHz) && (zFlipRateHz <= cfg.agent.no_model_max_z_flip_rate_hz) && ...
                isfinite(xyStd) && (xyStd <= cfg.agent.no_model_max_xy_std) && ...
                isfinite(xySpeedRms) && (xySpeedRms <= cfg.agent.no_model_max_xy_speed_rms) && ...
                isfinite(xyRadiusNow) && (xyRadiusNow <= cfg.agent.no_model_max_xy_radius) && ...
                isfinite(autosimNanLast(rollDeg(activeIdx))) && (abs(autosimNanLast(rollDeg(activeIdx))) <= cfg.agent.no_model_max_abs_roll_pitch_deg) && ...
                isfinite(autosimNanLast(pitchDeg(activeIdx))) && (abs(autosimNanLast(pitchDeg(activeIdx))) <= cfg.agent.no_model_max_abs_roll_pitch_deg) && ...
                isfinite(windSpNow) && (windSpNow <= cfg.agent.no_model_max_wind_speed) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            probeUnsafeSignal = scenarioCfg.hard_negative_hint || scenarioCfg.boundary_hint || modelSaysUnstable || ...
                (isfield(cfg.probe, 'allow_uncertain_signal') && cfg.probe.allow_uncertain_signal && modelIsUncertain) || ...
                (~logical(semanticSafe(k)));
            probePolicyHold = (~canLandBySemantic) && (~canLandByModel) && (~canLandByRelationalBaseline) && (~canLandByNoModelThreshold) && (~canLandByUncertainModelFallback);
            canLandByProbe = hoverEvalReady && probePolicySelected && randomLandingPlanned && ~landingSent && ...
                isfinite(randomLandingStartT) && (tk >= randomLandingStartT) && ...
                isfinite(tagErr(k)) && (tagErr(k) <= cfg.probe.max_tag_error) && ...
                isfinite(zEvalNow) && (zEvalNow >= cfg.probe.min_altitude_before_land) && ...
                (~cfg.probe.require_tag_detected || tagDetected) && ...
                (~cfg.probe.only_when_policy_holds || probePolicyHold) && ...
                (~cfg.probe.require_unsafe_signal || probeUnsafeSignal) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            canLandByForcedTimeout = isFlying && (controlPhase == "xy_hold") && ~landingSent && isfinite(decisionEvalStartT) && ...
                isfield(cfg.control, 'land_forced_timeout_sec') && isfinite(cfg.control.land_forced_timeout_sec) && ...
                (cfg.control.land_forced_timeout_sec > 0) && ...
                ((tk - decisionEvalStartT) >= cfg.control.land_forced_timeout_sec) && ...
                ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);

            if isfield(scenarioCfg, 'force_land_at_timeout') && logical(scenarioCfg.force_land_at_timeout)
                timeoutSec = autosimClampNaN(scenarioCfg.hover_timeout_sec, cfg.control.land_forced_timeout_sec);
                canLandByForcedTimeout = isFlying && (controlPhase == "xy_hold") && ~landingSent && isfinite(decisionEvalStartT) && ...
                    isfinite(timeoutSec) && (timeoutSec > 0) && ...
                    ((tk - decisionEvalStartT) >= timeoutSec) && ...
                    ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);
            end

            caseBlockPolicyLanding = (targetCase == "safe_hover_timeout") || (targetCase == "unsafe_hover_timeout") || (targetCase == "unsafe_forced_land");
            if caseBlockPolicyLanding
                canLandBySemantic = false;
                canLandByModel = false;
                canLandByRelationalBaseline = false;
                canLandByNoModelThreshold = false;
                canLandByUncertainModelFallback = false;
                canLandByProbe = false;
            end

            hoverTimeoutSec = autosimClampNaN(cfg.control.hover_hold_abort_timeout_sec, 60.0);
            if isfield(scenarioCfg, 'hover_abort_timeout_sec') && isfinite(scenarioCfg.hover_abort_timeout_sec)
                hoverTimeoutSec = max(0.0, scenarioCfg.hover_abort_timeout_sec);
            elseif isfield(scenarioCfg, 'force_hover_abort_timeout') && logical(scenarioCfg.force_hover_abort_timeout)
                hoverTimeoutSec = autosimClampNaN(scenarioCfg.hover_timeout_sec, hoverTimeoutSec);
            end
            if isfinite(hoverTimeoutSec) && (hoverTimeoutSec > 0)
                hoverTimeoutHit = isFlying && (controlPhase == "xy_hold") && ~landingSent && isfinite(decisionEvalStartT) && ...
                    isfinite(hoverTimeoutSec) && (hoverTimeoutSec > 0) && ...
                    ((tk - decisionEvalStartT) >= hoverTimeoutSec) && ...
                    ((tk - lastDecisionT) >= cfg.agent.decision_cooldown_sec);
                if hoverTimeoutHit && ~hoverTimeoutDecisionDone
                    timeoutSafeModel = hasTrainedModel && modelGateEnabled && modelSaysStable && ontologyGuardForModel && ...
                        isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.max_tag_error_before_land) && ...
                        isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land);
                    timeoutSafeSemantic = isfinite(semantic.landing_feasibility) && ...
                        (semantic.landing_feasibility >= adaptiveSemanticLandThreshold) && logical(semanticSafe(k)) && ...
                        isfinite(tagErr(k)) && (tagErr(k) <= cfg.agent.max_tag_error_before_land) && ...
                        isfinite(zEvalNow) && (zEvalNow >= cfg.agent.min_altitude_before_land);
                    timeoutSafeFallback = canLandByRelationalBaseline || canLandByNoModelThreshold || canLandByUncertainModelFallback;

                    if timeoutSafeModel || timeoutSafeSemantic || timeoutSafeFallback
                        landingSent = true;
                        landingSentT = tk;
                        landingStartZ = zEvalNow;
                        if ~isfinite(landingStartZ)
                            landingStartZ = zNow;
                        end
                        if ~isfinite(landingStartZ)
                            landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                        end
                        landingTargetZ = landingStartZ;
                        landingDecisionMode = "AttemptLanding";
                        executedAction = "AttemptLanding";
                        if timeoutSafeModel
                            actionSource = "timeout_safe_land_model";
                            decisionTxt(k) = "start_landing_track_by_timeout_model";
                        elseif timeoutSafeSemantic
                            actionSource = "timeout_safe_land_semantic";
                            decisionTxt(k) = "start_landing_track_by_timeout_semantic";
                        else
                            actionSource = "timeout_safe_land_fallback";
                            decisionTxt(k) = "start_landing_track_by_timeout_fallback";
                        end
                        controlPhase = "landing_track";
                    else
                        landingDecisionMode = "HoldLanding";
                        executedAction = "HoldLanding";
                        actionSource = "timeout_hover_hold";
                        decisionTxt(k) = "abort_by_hover_timeout";
                    end
                    lastDecisionT = tk;
                    hoverTimeoutDecisionDone = true;
                    break;
                end
            end

            if ~(isfield(scenarioCfg, 'force_land_at_timeout') && logical(scenarioCfg.force_land_at_timeout))
                canLandByForcedTimeout = canLandByForcedTimeout && (targetCase ~= "safe_hover_timeout") && (targetCase ~= "unsafe_hover_timeout");
            end

            guardLandingAllowed = ~cfg.agent.block_landing_if_unstable || ~modelSaysUnstable;

            landingTriggeredNow = ~landingSent && (canLandBySemantic || canLandByModel || canLandByRelationalBaseline || canLandByNoModelThreshold || ...
                canLandByUncertainModelFallback || canLandByProbe || canLandByForcedTimeout);
            if landingTriggeredNow && ~landingPadLockValid && isfinite(xEvalNow) && isfinite(yEvalNow)
                if padGlobalValid && padGlobalUseInLandingTrack
                    landingPadLockX = padGlobalMeanX;
                    landingPadLockY = padGlobalMeanY;
                else
                    landingPadLockX = xEvalNow;
                    landingPadLockY = yEvalNow;
                end
                landingPadLockValid = true;
                fprintf('[AUTOSIM] s%03d landing lock fallback captured at (x=%.2f, y=%.2f)\n', scenarioId, landingPadLockX, landingPadLockY);
            end

            if ~landingSent && guardLandingAllowed && canLandBySemantic
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "AttemptLanding";
                executedAction = "AttemptLanding";
                actionSource = "policy_semantic";
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_ontology_ai";
                controlPhase = "landing_track";
            elseif ~landingSent && guardLandingAllowed && canLandByModel
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "AttemptLanding";
                executedAction = "AttemptLanding";
                actionSource = "policy_model";
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_model";
                controlPhase = "landing_track";
            elseif ~landingSent && guardLandingAllowed && canLandByRelationalBaseline
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "AttemptLanding";
                executedAction = "AttemptLanding";
                actionSource = "policy_ontology_relational_baseline";
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_relational_baseline";
                controlPhase = "landing_track";
            elseif ~landingSent && guardLandingAllowed && canLandByNoModelThreshold
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "AttemptLanding";
                executedAction = "AttemptLanding";
                actionSource = "policy_threshold";
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_threshold_no_model";
                controlPhase = "landing_track";
            elseif ~landingSent && guardLandingAllowed && canLandByUncertainModelFallback
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "AttemptLanding";
                executedAction = "AttemptLanding";
                actionSource = "policy_model_uncertain_fallback";
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_model_uncertain_fallback";
                controlPhase = "landing_track";
            elseif ~landingSent && canLandByProbe
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "HoldLanding";
                executedAction = "AttemptLanding";
                actionSource = "probe_policy_override";
                probeLandingTriggered = true;
                requireLandingOutcomeEvaluation = true;
                probeLandingReason = string(scenarioCfg.probe_landing_reason);
                randomLandingPlanned = false;
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_probe_policy_override";
                controlPhase = "landing_track";
            elseif ~landingSent && canLandByForcedTimeout
                landingSent = true;
                landingSentT = tk;
                landingStartZ = zEvalNow;
                if ~isfinite(landingStartZ)
                    landingStartZ = zNow;
                end
                if ~isfinite(landingStartZ)
                    landingStartZ = max(cfg.control.land_cmd_alt_m, cfg.control.landing_near_ground_alt_m + 0.2);
                end
                landingTargetZ = landingStartZ;
                landingDecisionMode = "HoldLanding";
                executedAction = "AttemptLanding";
                actionSource = "forced_timeout";
                requireLandingOutcomeEvaluation = true;
                lastDecisionT = tk;
                decisionTxt(k) = "start_landing_track_by_forced_timeout";
                controlPhase = "landing_track";
            elseif decisionTxt(k) == "" && hasTrainedModel && cfg.agent.enable_model_decision && modelSaysUnstable
                decisionTxt(k) = "hold_by_model_unstable";
            elseif decisionTxt(k) == "" && hasTrainedModel && cfg.agent.enable_model_decision && modelIsUncertain
                decisionTxt(k) = "hold_by_model_uncertain";
            elseif decisionTxt(k) == ""
                decisionTxt(k) = "track";
            end

            phaseTxt(k) = controlPhase;

            if landingSent || canLandBySemantic || canLandByModel || canLandByRelationalBaseline || canLandByNoModelThreshold || canLandByUncertainModelFallback || canLandByForcedTimeout
                inferTxt = "ATTEMPT_LANDING";
            else
                inferTxt = "HOLD_LANDING";
            end

            if analysisDataSeen && enableScenarioLiveView
                vizState = struct();
                vizState.tSec = tk - analysisStartT;
                vizState.phase = string(controlPhase);
                vizState.inferTxt = string(inferTxt);
                vizState.predStableProb = decisionStableProb;
                vizState.predLabel = string(predLabel);
                vizState.decisionTxt = string(decisionTxt(k));
                vizState.landingFeasibility = semantic.landing_feasibility;
                vizState.modelSaysStable = logical(modelSaysStable);
                vizState.modelSaysUnstable = logical(modelSaysUnstable);
                vizState.modelIsUncertain = logical(modelIsUncertain);
                vizState.semantic = semantic;
                vizState.semVec = semVec;
                vizState.sensors = struct( ...
                    'windSpeed', windSpNow, ...
                    'windDirDeg', windDirNow, ...
                    'rollDeg', autosimNanLast(rollDeg(activeIdx)), ...
                    'pitchDeg', autosimNanLast(pitchDeg(activeIdx)), ...
                    'altitude', zEvalNow, ...
                    'vz', vzEvalNow, ...
                    'tagErr', autosimNanLast(tagErr(activeIdx)), ...
                    'tagU', uTag, ...
                    'tagV', vTag, ...
                    'tagDetected', logical(tagDetected), ...
                    'tagJitterPx', tagJitterPx, ...
                    'tagStabilityScore', tagStabilityScore, ...
                    'detectionContinuity', detCont, ...
                    'estimationUncertainty', autosimClampNaN(ekfUncertaintyLog(k), 0.0), ...
                    'gpsDropoutActive', gpsDropoutActiveLog(k), ...
                    'movingPadOffsetU', movingPadOffsetULog(k), ...
                    'movingPadOffsetV', movingPadOffsetVLog(k), ...
                    'movingPadVelU', movingPadVelULog(k), ...
                    'movingPadVelV', movingPadVelVLog(k), ...
                    'trajectoryIntent', trajectoryIntentTxt(k), ...
                    'trajectoryTargetU', trajectoryTargetULog(k), ...
                    'trajectoryTargetV', trajectoryTargetVLog(k), ...
                    'trajectoryTargetX', trajectoryTargetXLog(k), ...
                    'trajectoryTargetY', trajectoryTargetYLog(k), ...
                    'trajectoryTargetZ', trajectoryTargetZLog(k), ...
                    'trajectoryQuality', trajectoryQualityLog(k), ...
                    'navigationInstability', navInstabilityLog(k), ...
                    'cmdX', cmdX, ...
                    'cmdY', cmdY, ...
                    'cmdZ', cmdZ, ...
                    'followerExpected', followerExpectedLog(k), ...
                    'followerPoseReady', followerPoseReadyLog(k), ...
                    'followerStateReady', followerStateReadyLog(k), ...
                    'followerTagDetected', followerTagDetectLog(k), ...
                    'followerFlying', followerFlyingLog(k), ...
                    'followerCmdRms', followerCmdRmsLog(k));
                if ~liveVizInitAttempted
                    try
                        liveViz = autosimInitScenarioRealtimePlot(cfg, scenarioId, scenarioCfg);
                    catch ME
                        liveViz = struct();
                        warning('[AUTOSIM] Realtime ontology plot disabled: %s', ME.message);
                    end
                    liveVizInitAttempted = true;
                end
                autosimUpdateScenarioRealtimePlot(liveViz, vizState);
            end
        end

        % Keep publishing cmd_vel so the topic is always alive for debugging/monitoring.
        if isFlying || cfg.control.publish_cmd_always
            msgCmd.linear.x = cmdX;
            msgCmd.linear.y = cmdY;
            msgCmd.linear.z = cmdZ;
            msgCmd.angular.x = 0.0;
            msgCmd.angular.y = 0.0;
            msgCmd.angular.z = 0.0;
            send(pubCmd, msgCmd);
        end

        if ~isempty(pubTrajectoryGuidance) && ~isempty(msgTrajectoryGuidance)
            msgTrajectoryGuidance.data = single([ ...
                tk, ...
                autosimClampNaN(xNow, 0.0), autosimClampNaN(yNow, 0.0), autosimClampNaN(zNow, 0.0), ...
                autosimClampNaN(trajPublishTargetX, autosimClampNaN(xNow, 0.0)), ...
                autosimClampNaN(trajPublishTargetY, autosimClampNaN(yNow, 0.0)), ...
                autosimClampNaN(trajPublishTargetZ, autosimClampNaN(zNow, 0.0)), ...
                autosimClampNaN(cmdX, 0.0), autosimClampNaN(cmdY, 0.0), autosimClampNaN(cmdZ, 0.0), ...
                autosimClampNaN(trajGuidanceSourceCode, 0.0), ...
                autosimClampNaN(trajectoryQualityLog(k), 0.0), ...
                double(logical(padMovingNow)) ...
            ]);
            send(pubTrajectoryGuidance, msgTrajectoryGuidance);
        end

        if ~isempty(pubTrajectoryGuidanceMarker) && ~isempty(msgTrajectoryGuidanceMarker)
            px = autosimClampNaN(xNow, 0.0);
            py = autosimClampNaN(yNow, 0.0);
            pz = autosimClampNaN(zNow, 0.0);
            tx = autosimClampNaN(trajPublishTargetX, px);
            ty = autosimClampNaN(trajPublishTargetY, py);
            tz = autosimClampNaN(trajPublishTargetZ, pz);

            msgTrajectoryGuidanceMarker.header.frame_id = 'world';
            msgTrajectoryGuidanceMarker.ns = 'autosim_guidance';
            msgTrajectoryGuidanceMarker.id = int32(1);
            msgTrajectoryGuidanceMarker.type = int32(4); % LINE_STRIP
            msgTrajectoryGuidanceMarker.action = int32(0); % ADD/MODIFY
            msgTrajectoryGuidanceMarker.pose.orientation.w = 1.0;
            msgTrajectoryGuidanceMarker.scale.x = 0.05;
            msgTrajectoryGuidanceMarker.color.r = 0.10;
            msgTrajectoryGuidanceMarker.color.g = 0.90;
            msgTrajectoryGuidanceMarker.color.b = 0.35;
            msgTrajectoryGuidanceMarker.color.a = 1.0;

            ptNow = ros2message('geometry_msgs/Point');
            ptNow.x = px;
            ptNow.y = py;
            ptNow.z = pz;
            ptTarget = ros2message('geometry_msgs/Point');
            ptTarget.x = tx;
            ptTarget.y = ty;
            ptTarget.z = tz;
            msgTrajectoryGuidanceMarker.points = [ptNow, ptTarget];
            send(pubTrajectoryGuidanceMarker, msgTrajectoryGuidanceMarker);
        end

        cmdXLog(k) = cmdX;
        cmdYLog(k) = cmdY;
        cmdZLog(k) = cmdZ;
        followerExpectedLog(k) = followerCount;

        if followerCount > 0
            [tagLostFollowers, lastTagUFollowers, lastTagVFollowers, lastTagDetectFollowers, haveLastTagFollowers, tagRxCountFollowers, stateFollowers, followerDiag] = ...
                autosimUpdateFollowerCommands(cfg, rosCtx, tk, dtCtrl, recvTimeoutSec, cmdX, cmdY, ...
                tagLostFollowers, lastTagUFollowers, lastTagVFollowers, ...
                lastTagDetectFollowers, haveLastTagFollowers, tagRxCountFollowers, stateFollowers);

            followerExpectedLog(k) = followerDiag.expected_count;
            followerPoseReadyLog(k) = followerDiag.pose_ready_count;
            followerStateReadyLog(k) = followerDiag.state_ready_count;
            followerTagDetectLog(k) = followerDiag.tag_detect_count;
            followerFlyingLog(k) = followerDiag.flying_count;
            followerCmdRmsLog(k) = followerDiag.cmd_xy_rms;
        end

        if landingSent && isfield(cfg, 'scenario') && isfield(cfg.scenario, 'analysis_stop_at_landing') && cfg.scenario.analysis_stop_at_landing && ...
                ~requireLandingOutcomeEvaluation && isfinite(landedHoldStartT) && ((tk - landedHoldStartT) >= cfg.scenario.early_stop_after_landing_sec)
            break;
        end

        if (~landingSent) && isFlying && (controlPhase == "xy_hold")
            fastLoopUsePadGlobal = padGlobalEnable && isfield(cfg.control, 'pad_global_tracking_use_in_fast_loop') && cfg.control.pad_global_tracking_use_in_fast_loop;
            [tagLostSearchStartT, lastTagU, lastTagV, lastTagDetectT, haveLastTag, lastTagRxT, tagRxCount] = ...
                autosimRunFastTagControlBurst(cfg, rosCtx, pubCmd, msgCmd, t0, tk, max(0.0, cfg.scenario.sample_period_sec - (toc(t0) - iterStartT)), ...
                xNow, yNow, zNow, tagLostSearchStartT, lastTagU, lastTagV, lastTagDetectT, haveLastTag, lastTagRxT, tagRxCount, ...
                randomLandingPlanned, randomLandingStartT, randomLandingEndT, randomBiasX, randomBiasY, ...
                fastLoopUsePadGlobal, padGlobalValid, padGlobalMeanX, padGlobalMeanY);
        end

        if landingSent
            landedByState = isfinite(stateVal(k)) && (stateVal(k) == cfg.thresholds.land_state_value);
            landedByPose = isfinite(z(k)) && (z(k) <= (cfg.thresholds.landed_altitude_max_m + 0.05));
            if landedByState || landedByPose
                if ~isfinite(landedHoldStartT)
                    landedHoldStartT = tk;
                end
            else
                landedHoldStartT = nan;
            end

            if isfinite(landedHoldStartT) && ((tk - landedHoldStartT) >= cfg.scenario.early_stop_after_landing_sec)
                break;
            end
        end

        pause(max(0.0, cfg.scenario.sample_period_sec - (toc(t0) - iterStartT)));
    end

    t = t(1:kLast);
    xPos = xPos(1:kLast);
    yPos = yPos(1:kLast);
    z = z(1:kLast);
    vz = vz(1:kLast);
    speedAbs = speedAbs(1:kLast);
    rollDeg = rollDeg(1:kLast);
    pitchDeg = pitchDeg(1:kLast);
    tagErr = tagErr(1:kLast);
    windSpeed = windSpeed(1:kLast);
    windDir = windDir(1:kLast);
    stateVal = stateVal(1:kLast);
    contact = contact(1:kLast);
    imuAngVel = imuAngVel(1:kLast);
    imuLinAcc = imuLinAcc(1:kLast);
    contactForce = contactForce(1:kLast);
    armForceFL = armForceFL(1:kLast);
    armForceFR = armForceFR(1:kLast);
    armForceRL = armForceRL(1:kLast);
    armForceRR = armForceRR(1:kLast);
    predStableProb = predStableProb(1:kLast);
    decisionTxt = decisionTxt(1:kLast);
    phaseTxt = phaseTxt(1:kLast);
    windCmdSpeed = windCmdSpeed(1:kLast);
    windCmdDir = windCmdDir(1:kLast);
    semanticWindRisk = semanticWindRisk(1:kLast);
    semanticEnvironment = semanticEnvironment(1:kLast);
    semanticDroneState = semanticDroneState(1:kLast);
    semanticAlign = semanticAlign(1:kLast);
    semanticVisual = semanticVisual(1:kLast);
    semanticSafe = semanticSafe(1:kLast);
    landingFeasibility = landingFeasibility(1:kLast);
    windBodyForceX = windBodyForceX(1:kLast);
    windBodyForceY = windBodyForceY(1:kLast);
    windBodyForce = windBodyForce(1:kLast);
    windBodyRisk = windBodyRisk(1:kLast);
    windGustRisk = windGustRisk(1:kLast);
    windRiskRaw = windRiskRaw(1:kLast);
    thrustMargin = thrustMargin(1:kLast);
    semFeat = semFeat(1:kLast, :);
    cmdXLog = cmdXLog(1:kLast);
    cmdYLog = cmdYLog(1:kLast);
    cmdZLog = cmdZLog(1:kLast);
    ekfUncertaintyLog = ekfUncertaintyLog(1:kLast);
    gpsDropoutActiveLog = gpsDropoutActiveLog(1:kLast);
    movingPadOffsetULog = movingPadOffsetULog(1:kLast);
    movingPadOffsetVLog = movingPadOffsetVLog(1:kLast);
    movingPadVelULog = movingPadVelULog(1:kLast);
    movingPadVelVLog = movingPadVelVLog(1:kLast);
    trajectoryIntentTxt = trajectoryIntentTxt(1:kLast);
    trajectoryTargetULog = trajectoryTargetULog(1:kLast);
    trajectoryTargetVLog = trajectoryTargetVLog(1:kLast);
    trajectoryTargetXLog = trajectoryTargetXLog(1:kLast);
    trajectoryTargetYLog = trajectoryTargetYLog(1:kLast);
    trajectoryTargetZLog = trajectoryTargetZLog(1:kLast);
    trajectoryQualityLog = trajectoryQualityLog(1:kLast);
    navInstabilityLog = navInstabilityLog(1:kLast);
    windHazardousLog = windHazardousLog(1:kLast);
    followerExpectedLog = followerExpectedLog(1:kLast);
    followerPoseReadyLog = followerPoseReadyLog(1:kLast);
    followerStateReadyLog = followerStateReadyLog(1:kLast);
    followerTagDetectLog = followerTagDetectLog(1:kLast);
    followerFlyingLog = followerFlyingLog(1:kLast);
    followerCmdRmsLog = followerCmdRmsLog(1:kLast);

    if isfinite(analysisStartIdx) && (analysisStartIdx <= kLast)
        keepIdx = analysisStartIdx:kLast;
    else
        keepIdx = [];
    end
    t = t(keepIdx);
    if ~isempty(t)
        t = t - t(1);
    end
    xPos = xPos(keepIdx);
    yPos = yPos(keepIdx);
    z = z(keepIdx);
    vz = vz(keepIdx);
    speedAbs = speedAbs(keepIdx);
    rollDeg = rollDeg(keepIdx);
    pitchDeg = pitchDeg(keepIdx);
    tagErr = tagErr(keepIdx);
    windSpeed = windSpeed(keepIdx);
    windDir = windDir(keepIdx);
    stateVal = stateVal(keepIdx);
    contact = contact(keepIdx);
    imuAngVel = imuAngVel(keepIdx);
    imuLinAcc = imuLinAcc(keepIdx);
    contactForce = contactForce(keepIdx);
    armForceFL = armForceFL(keepIdx);
    armForceFR = armForceFR(keepIdx);
    armForceRL = armForceRL(keepIdx);
    armForceRR = armForceRR(keepIdx);
    predStableProb = predStableProb(keepIdx);
    decisionTxt = decisionTxt(keepIdx);
    phaseTxt = phaseTxt(keepIdx);
    windCmdSpeed = windCmdSpeed(keepIdx);
    windCmdDir = windCmdDir(keepIdx);
    semanticWindRisk = semanticWindRisk(keepIdx);
    semanticEnvironment = semanticEnvironment(keepIdx);
    semanticDroneState = semanticDroneState(keepIdx);
    semanticAlign = semanticAlign(keepIdx);
    semanticVisual = semanticVisual(keepIdx);
    semanticSafe = semanticSafe(keepIdx);
    landingFeasibility = landingFeasibility(keepIdx);
    windBodyForceX = windBodyForceX(keepIdx);
    windBodyForceY = windBodyForceY(keepIdx);
    windBodyForce = windBodyForce(keepIdx);
    windBodyRisk = windBodyRisk(keepIdx);
    windGustRisk = windGustRisk(keepIdx);
    windRiskRaw = windRiskRaw(keepIdx);
    thrustMargin = thrustMargin(keepIdx);
    semFeat = semFeat(keepIdx, :);
    cmdXLog = cmdXLog(keepIdx);
    cmdYLog = cmdYLog(keepIdx);
    cmdZLog = cmdZLog(keepIdx);
    ekfUncertaintyLog = ekfUncertaintyLog(keepIdx);
    gpsDropoutActiveLog = gpsDropoutActiveLog(keepIdx);
    movingPadOffsetULog = movingPadOffsetULog(keepIdx);
    movingPadOffsetVLog = movingPadOffsetVLog(keepIdx);
    movingPadVelULog = movingPadVelULog(keepIdx);
    movingPadVelVLog = movingPadVelVLog(keepIdx);
    trajectoryIntentTxt = trajectoryIntentTxt(keepIdx);
    trajectoryTargetULog = trajectoryTargetULog(keepIdx);
    trajectoryTargetVLog = trajectoryTargetVLog(keepIdx);
    trajectoryTargetXLog = trajectoryTargetXLog(keepIdx);
    trajectoryTargetYLog = trajectoryTargetYLog(keepIdx);
    trajectoryTargetZLog = trajectoryTargetZLog(keepIdx);
    trajectoryQualityLog = trajectoryQualityLog(keepIdx);
    navInstabilityLog = navInstabilityLog(keepIdx);
    windHazardousLog = windHazardousLog(keepIdx);
    followerExpectedLog = followerExpectedLog(keepIdx);
    followerPoseReadyLog = followerPoseReadyLog(keepIdx);
    followerStateReadyLog = followerStateReadyLog(keepIdx);
    followerTagDetectLog = followerTagDetectLog(keepIdx);
    followerFlyingLog = followerFlyingLog(keepIdx);
    followerCmdRmsLog = followerCmdRmsLog(keepIdx);

    msgCmd.linear.x = autosimClampNaN(autosimNanLast(xPos), primaryHomeX);
    msgCmd.linear.y = autosimClampNaN(autosimNanLast(yPos), primaryHomeY);
    msgCmd.linear.z = autosimClampNaN(autosimNanLast(z), autosimClampNaN(cfg.control.land_cmd_alt_m, 0.2));
    msgCmd.angular.x = 0.0;
    msgCmd.angular.y = 0.0;
    msgCmd.angular.z = 0.0;
    autosimSendToFleet(rosCtx, 'cmd', msgCmd);

    if ~landingSent
        fprintf('[AUTOSIM] s%03d ended without LAND inference, so landing trajectory was not started.\n', scenarioId);
    end

    postN = max(1, floor(cfg.scenario.post_land_observe_sec / cfg.scenario.sample_period_sec));
    if isfield(cfg, 'scenario') && isfield(cfg.scenario, 'analysis_stop_at_landing') && cfg.scenario.analysis_stop_at_landing && ~requireLandingOutcomeEvaluation
        postN = 0;
    end
    if stopRequested
        postN = 0;
    end
    for m = 1:postN
        if autosimIsStopRequested()
            stopRequested = true;
            stopReason = autosimGetStopReason();
            fprintf('[AUTOSIM] Scenario %03d stop requested during post-observe: %s\n', scenarioId, stopReason);
            break;
        end

        iterStartT = toc(t0);
        poseMsg = autosimTryReceive(subPose, recvTimeoutSec);
        if ~isempty(poseMsg)
            xPos(end+1,1) = double(poseMsg.position.x); %#ok<AGROW>
            yPos(end+1,1) = double(poseMsg.position.y); %#ok<AGROW>
            z(end+1,1) = double(poseMsg.position.z); %#ok<AGROW>
            q = poseMsg.orientation;
            [r, p, ~] = autosimQuat2Eul([q.w, q.x, q.y, q.z]);
            rollDeg(end+1,1) = abs(rad2deg(r)); %#ok<AGROW>
            pitchDeg(end+1,1) = abs(rad2deg(p)); %#ok<AGROW>
        else
            xPos(end+1,1) = nan; %#ok<AGROW>
            yPos(end+1,1) = nan; %#ok<AGROW>
            z(end+1,1) = nan; %#ok<AGROW>
            rollDeg(end+1,1) = nan; %#ok<AGROW>
            pitchDeg(end+1,1) = nan; %#ok<AGROW>
        end

        velMsg = autosimTryReceive(subVel, recvTimeoutSec);
        if ~isempty(velMsg)
            vx = double(velMsg.linear.x);
            vy = double(velMsg.linear.y);
            vz(end+1,1) = double(velMsg.linear.z); %#ok<AGROW>
            speedAbs(end+1,1) = sqrt(vx*vx + vy*vy + vz(end)^2); %#ok<AGROW>
        else
            vz(end+1,1) = nan; %#ok<AGROW>
            speedAbs(end+1,1) = nan; %#ok<AGROW>
        end

        stateMsg = autosimTryReceive(subState, recvTimeoutSec);
        if ~isempty(stateMsg)
            stateVal(end+1,1) = double(stateMsg.data); %#ok<AGROW>
        else
            stateVal(end+1,1) = nan; %#ok<AGROW>
        end

        [hasFreshTag, ~, ~, ~, te, tagRxCountNow] = autosimReadTagInput(subTag, recvTimeoutSec, tagCallbackEnabled, tagCacheKey, tagRxCount);
        if hasFreshTag
            tagRxCount = tagRxCountNow;
            tagErr(end+1,1) = te; %#ok<AGROW>
        else
            tagErr(end+1,1) = nan; %#ok<AGROW>
        end

        windMsg = [];
        if windPollEnabled
            windMsg = autosimTryReceive(subWind, recvTimeoutSec);
        end
        if ~isempty(windMsg)
            [wsPost, wdPost] = autosimParseWindConditionMsg(windMsg);
            windSpeed(end+1,1) = wsPost; %#ok<AGROW>
            windDir(end+1,1) = wdPost; %#ok<AGROW>
        else
            windSpeed(end+1,1) = nan; %#ok<AGROW>
            windDir(end+1,1) = nan; %#ok<AGROW>
        end

        if ~isempty(subImu)
            imuMsg = autosimTryReceive(subImu, recvTimeoutSec);
            if ~isempty(imuMsg)
                [angNow, accNow] = autosimParseImuMetrics(imuMsg);
                imuAngVel(end+1,1) = angNow; %#ok<AGROW>
                imuLinAcc(end+1,1) = accNow; %#ok<AGROW>
            else
                imuAngVel(end+1,1) = nan; %#ok<AGROW>
                imuLinAcc(end+1,1) = nan; %#ok<AGROW>
            end
        else
            imuAngVel(end+1,1) = nan; %#ok<AGROW>
            imuLinAcc(end+1,1) = nan; %#ok<AGROW>
        end

        if ~isempty(subBumpers)
            bumpMsg = autosimTryReceive(subBumpers, recvTimeoutSec);
            if ~isempty(bumpMsg)
                [cNow, fNow, flNow, frNow, rlNow, rrNow] = autosimParseContactForces(bumpMsg, bumperMsgType);
                contact(end+1,1) = cNow; %#ok<AGROW>
                contactForce(end+1,1) = fNow; %#ok<AGROW>
                armForceFL(end+1,1) = flNow; %#ok<AGROW>
                armForceFR(end+1,1) = frNow; %#ok<AGROW>
                armForceRL(end+1,1) = rlNow; %#ok<AGROW>
                armForceRR(end+1,1) = rrNow; %#ok<AGROW>
            else
                contact(end+1,1) = 0; %#ok<AGROW>
                contactForce(end+1,1) = nan; %#ok<AGROW>
                armForceFL(end+1,1) = nan; %#ok<AGROW>
                armForceFR(end+1,1) = nan; %#ok<AGROW>
                armForceRL(end+1,1) = nan; %#ok<AGROW>
                armForceRR(end+1,1) = nan; %#ok<AGROW>
            end
        else
            contact(end+1,1) = 0; %#ok<AGROW>
            contactForce(end+1,1) = nan; %#ok<AGROW>
            armForceFL(end+1,1) = nan; %#ok<AGROW>
            armForceFR(end+1,1) = nan; %#ok<AGROW>
            armForceRL(end+1,1) = nan; %#ok<AGROW>
            armForceRR(end+1,1) = nan; %#ok<AGROW>
        end

        predStableProb(end+1,1) = nan; %#ok<AGROW>
        decisionTxt(end+1,1) = "post_observe"; %#ok<AGROW>
        t(end+1,1) = toc(t0); %#ok<AGROW>
        cmdXLog(end+1,1) = 0.0; %#ok<AGROW>
        cmdYLog(end+1,1) = 0.0; %#ok<AGROW>
        cmdZLog(end+1,1) = 0.0; %#ok<AGROW>
        ekfUncertaintyLog(end+1,1) = autosimClampNaN(autosimNanLast(ekfUncertaintyLog), 0.0); %#ok<AGROW>
        gpsDropoutActiveLog(end+1,1) = double(gpsDropoutEnable); %#ok<AGROW>
        movingPadOffsetULog(end+1,1) = 0.0; %#ok<AGROW>
        movingPadOffsetVLog(end+1,1) = 0.0; %#ok<AGROW>
        movingPadVelULog(end+1,1) = 0.0; %#ok<AGROW>
        movingPadVelVLog(end+1,1) = 0.0; %#ok<AGROW>
        trajectoryIntentTxt(end+1,1) = "post_observe"; %#ok<AGROW>
        trajectoryTargetULog(end+1,1) = 0.0; %#ok<AGROW>
        trajectoryTargetVLog(end+1,1) = 0.0; %#ok<AGROW>
        trajectoryTargetXLog(end+1,1) = autosimNanLast(xPos); %#ok<AGROW>
        trajectoryTargetYLog(end+1,1) = autosimNanLast(yPos); %#ok<AGROW>
        trajectoryTargetZLog(end+1,1) = autosimNanLast(z); %#ok<AGROW>
        trajectoryQualityLog(end+1,1) = autosimClampNaN(autosimNanLast(trajectoryQualityLog), 0.0); %#ok<AGROW>
        navInstabilityLog(end+1,1) = autosimClampNaN(autosimNanLast(navInstabilityLog), 0.0); %#ok<AGROW>
        windHazardousLog(end+1,1) = double(autosimClampNaN(autosimNanLast(windHazardousLog), 0.0) > 0.5); %#ok<AGROW>
        followerExpectedLog(end+1,1) = max(0, followerCount); %#ok<AGROW>
        followerPoseReadyLog(end+1,1) = 0; %#ok<AGROW>
        followerStateReadyLog(end+1,1) = 0; %#ok<AGROW>
        followerTagDetectLog(end+1,1) = 0; %#ok<AGROW>
        followerFlyingLog(end+1,1) = 0; %#ok<AGROW>
        followerCmdRmsLog(end+1,1) = nan; %#ok<AGROW>

        inferPost = "HOLD_LANDING";
        if landingSent
            inferPost = "ATTEMPT_LANDING";
        end
        predPost = autosimNanLast(predStableProb);
        if ~isfinite(predPost)
            predPost = nan;
        end

        if analysisDataSeen && enableScenarioLiveView
            vizState = struct();
            vizState.tSec = t(end) - analysisStartT;
            vizState.phase = "post_observe";
            vizState.inferTxt = string(inferPost);
            vizState.predStableProb = predPost;
            vizState.predLabel = "unknown";
            vizState.decisionTxt = "post_observe";
            vizState.landingFeasibility = autosimLastFinite(landingFeasibility, nan);
            vizState.modelSaysStable = false;
            vizState.modelSaysUnstable = false;
            vizState.modelIsUncertain = false;
            if exist('semantic', 'var') && isstruct(semantic)
                vizState.semantic = semantic;
            else
                vizState.semantic = struct( ...
                    'wind_risk', autosimLastNonEmptyString(semanticWindRisk, "unknown"), ...
                    'environment_state', autosimLastNonEmptyString(semanticEnvironment, "unknown"), ...
                    'drone_state', autosimLastNonEmptyString(semanticDroneState, "unknown"), ...
                    'alignment_state', autosimLastNonEmptyString(semanticAlign, "unknown"), ...
                    'visual_state', autosimLastNonEmptyString(semanticVisual, "unknown"), ...
                    'landing_feasibility', autosimLastFinite(landingFeasibility, nan), ...
                    'isSafeForLanding', logical(autosimLastFinite(double(semanticSafe), 0) > 0.5));
            end
            vizState.semVec = nan(1, numel(cfg.ontology.semantic_feature_names));
            vizState.sensors = struct( ...
                'windSpeed', autosimNanLast(windSpeed), ...
                'windDirDeg', autosimNanLast(windCmdDir), ...
                'rollDeg', autosimNanLast(rollDeg), ...
                'pitchDeg', autosimNanLast(pitchDeg), ...
                'altitude', autosimNanLast(z), ...
                'vz', autosimNanLast(vz), ...
                'tagErr', autosimNanLast(tagErr), ...
                'tagU', nan, ...
                'tagV', nan, ...
                'tagDetected', isfinite(autosimNanLast(tagErr)), ...
                'tagJitterPx', nan, ...
                'tagStabilityScore', nan, ...
                'detectionContinuity', nan, ...
                'estimationUncertainty', autosimClampNaN(autosimNanLast(ekfUncertaintyLog), 0.0), ...
                'gpsDropoutActive', autosimClampNaN(autosimNanLast(gpsDropoutActiveLog), 0.0), ...
                'movingPadOffsetU', autosimClampNaN(autosimNanLast(movingPadOffsetULog), 0.0), ...
                'movingPadOffsetV', autosimClampNaN(autosimNanLast(movingPadOffsetVLog), 0.0), ...
                'movingPadVelU', autosimClampNaN(autosimNanLast(movingPadVelULog), 0.0), ...
                'movingPadVelV', autosimClampNaN(autosimNanLast(movingPadVelVLog), 0.0), ...
                'trajectoryIntent', string(autosimLastNonEmptyString(trajectoryIntentTxt, "hold_and_align")), ...
                'trajectoryTargetU', autosimClampNaN(autosimNanLast(trajectoryTargetULog), 0.0), ...
                'trajectoryTargetV', autosimClampNaN(autosimNanLast(trajectoryTargetVLog), 0.0), ...
                'trajectoryTargetX', autosimClampNaN(autosimNanLast(trajectoryTargetXLog), 0.0), ...
                'trajectoryTargetY', autosimClampNaN(autosimNanLast(trajectoryTargetYLog), 0.0), ...
                'trajectoryTargetZ', autosimClampNaN(autosimNanLast(trajectoryTargetZLog), 0.0), ...
                'trajectoryQuality', autosimClampNaN(autosimNanLast(trajectoryQualityLog), 0.0), ...
                'navigationInstability', autosimClampNaN(autosimNanLast(navInstabilityLog), 0.0), ...
                'cmdX', autosimNanLast(cmdXLog), ...
                'cmdY', autosimNanLast(cmdYLog), ...
                'cmdZ', autosimNanLast(cmdZLog), ...
                'followerExpected', autosimNanLast(followerExpectedLog), ...
                'followerPoseReady', autosimNanLast(followerPoseReadyLog), ...
                'followerStateReady', autosimNanLast(followerStateReadyLog), ...
                'followerTagDetected', autosimNanLast(followerTagDetectLog), ...
                'followerFlying', autosimNanLast(followerFlyingLog), ...
                'followerCmdRms', autosimNanLast(followerCmdRmsLog));
            if ~liveVizInitAttempted
                try
                    liveViz = autosimInitScenarioRealtimePlot(cfg, scenarioId, scenarioCfg);
                catch ME
                    liveViz = struct();
                    warning('[AUTOSIM] Realtime ontology plot disabled: %s', ME.message);
                end
                liveVizInitAttempted = true;
            end
            autosimUpdateScenarioRealtimePlot(liveViz, vizState);
        end

        pause(max(0.0, cfg.scenario.sample_period_sec - (toc(t0) - iterStartT)));
    end

    res = autosimSummarizeAndLabel(cfgEval, scenarioId, scenarioCfg, requireLandingOutcomeEvaluation, z, vz, speedAbs, rollDeg, pitchDeg, tagErr, windSpeed, stateVal, contact, ...
        imuAngVel, imuLinAcc, contactForce, armForceFL, armForceFR, armForceRL, armForceRR, windDir);
    res.landing_cmd_time = landingSentT;
    if isfinite(res.landing_cmd_time) && isfinite(analysisStartT)
        res.landing_cmd_time = max(0.0, res.landing_cmd_time - analysisStartT);
    end
    res.pred_decision = string(landingDecisionMode);
    res.executed_action = string(executedAction);
    res.action_source = string(actionSource);
    res.probe_episode = logical(probeLandingTriggered);
    res.probe_reason = string(probeLandingReason);
    res.gt_safe_to_land = "unstable";
    if string(res.label) == "stable"
        res.gt_safe_to_land = "stable";
    end
    res.decision_outcome = autosimClassifyDecisionOutcome(res.gt_safe_to_land, res.pred_decision);
    res.semantic_environment = autosimLastNonEmptyString(semanticEnvironment, "unknown");
    res.semantic_drone_state = autosimLastNonEmptyString(semanticDroneState, "unknown");
    res.semantic_visual_state = autosimLastNonEmptyString(semanticVisual, "unknown");
    res.landing_feasibility = autosimLastFinite(landingFeasibility, nan);
    res.wind_body_force_x = autosimNanMean(windBodyForceX);
    res.wind_body_force_y = autosimNanMean(windBodyForceY);
    res.wind_body_force = autosimNanMean(windBodyForce);
    res.mean_wind_body_risk = autosimNanMean(windBodyRisk);
    res.mean_wind_gust_risk = autosimNanMean(windGustRisk);
    res.mean_wind_dir_change_risk = autosimNanMean(windDirChangeRisk);
    res.mean_wind_risk_raw = autosimNanMean(windRiskRaw);
    res.wind_risk_enc = autosimClampNaN(autosimVizField(semantic, 'wind_risk_enc', nan), nan);
    res.alignment_enc = autosimClampNaN(autosimVizField(semantic, 'alignment_enc', nan), nan);
    res.visual_enc = autosimClampNaN(autosimVizField(semantic, 'visual_enc', nan), nan);
    res.relation_wind_control = autosimClampNaN(autosimVizField(semantic, 'relation_wind_control', nan), nan);
    res.relation_visual_alignment = autosimClampNaN(autosimVizField(semantic, 'relation_visual_alignment', nan), nan);
    res.relation_estimation_conflict = autosimClampNaN(autosimVizField(semantic, 'relation_estimation_conflict', nan), nan);
    res.wind_moment_risk = autosimClampNaN(autosimVizField(semantic, 'wind_moment_risk', nan), nan);
    res.mean_estimation_uncertainty = autosimNanMean(ekfUncertaintyLog);
    res.gps_dropout_enabled = logical(gpsDropoutEnable);
    res.gps_dropout_start_sec = autosimClampNaN(gpsDropoutStartSec, nan);
    res.gps_dropout_duration_sec = autosimClampNaN(gpsDropoutDurationSec, nan);
    res.moving_pad_enabled = logical(movingPadEnable);
    res.moving_pad_amp_u = autosimClampNaN(movingPadAmpU, nan);
    res.moving_pad_amp_v = autosimClampNaN(movingPadAmpV, nan);
    res.moving_pad_freq_hz = autosimClampNaN(movingPadFreqHz, nan);
    res.trajectory_intent = autosimLastNonEmptyString(trajectoryIntentTxt, "hold_and_align");
    res.trajectory_target_u = autosimNanMean(trajectoryTargetULog);
    res.trajectory_target_v = autosimNanMean(trajectoryTargetVLog);
    res.trajectory_target_x = autosimNanMean(trajectoryTargetXLog);
    res.trajectory_target_y = autosimNanMean(trajectoryTargetYLog);
    res.trajectory_target_z = autosimNanMean(trajectoryTargetZLog);
    res.trajectory_quality = autosimNanMean(trajectoryQualityLog);
    res.navigation_instability = autosimNanMean(navInstabilityLog);
    res.wind_hazardous_ratio = autosimNanMean(windHazardousLog);
    thrFinite = thrustMargin(isfinite(thrustMargin));
    if isempty(thrFinite)
        res.min_thrust_margin_n = nan;
    else
        res.min_thrust_margin_n = min(thrFinite);
    end
    if isfield(scenarioCfg, 'policy_mode')
        res.scenario_policy = string(scenarioCfg.policy_mode);
    end
    if isfield(scenarioCfg, 'target_case')
        res.target_case = string(scenarioCfg.target_case);
    end
    if scenarioTimeoutHit
        res.label = "unstable";
        res.success = false;
        res.failure_reason = "scenario_timeout";
    end
    if stopRequested
        res.exception_message = string(stopReason);
    end

    n = numel(t);
    traceTbl = table();
    traceTbl.scenario_id = repmat(scenarioId, n, 1);
    traceTbl.t_sec = t;
    traceTbl.x = autosimPadLen(xPos, n);
    traceTbl.y = autosimPadLen(yPos, n);
    traceTbl.z = autosimPadLen(z, n);
    traceTbl.vz = autosimPadLen(vz, n);
    traceTbl.speed_abs = autosimPadLen(speedAbs, n);
    traceTbl.roll_deg = autosimPadLen(rollDeg, n);
    traceTbl.pitch_deg = autosimPadLen(pitchDeg, n);
    traceTbl.tag_error = autosimPadLen(tagErr, n);
    traceTbl.wind_speed = autosimPadLen(windSpeed, n);
    traceTbl.wind_cmd_speed = autosimPadLen(windCmdSpeed, n);
    traceTbl.wind_cmd_dir = autosimPadLen(windCmdDir, n);
    traceTbl.state = autosimPadLen(stateVal, n);
    traceTbl.imu_ang_vel = autosimPadLen(imuAngVel, n);
    traceTbl.imu_lin_acc = autosimPadLen(imuLinAcc, n);
    traceTbl.contact_force = autosimPadLen(contactForce, n);
    traceTbl.arm_force_fl = autosimPadLen(armForceFL, n);
    traceTbl.arm_force_fr = autosimPadLen(armForceFR, n);
    traceTbl.arm_force_rl = autosimPadLen(armForceRL, n);
    traceTbl.arm_force_rr = autosimPadLen(armForceRR, n);
    traceTbl.pred_stable_prob = autosimPadLen(predStableProb, n);
    traceTbl.decision = autosimPadLenString(decisionTxt, n);
    traceTbl.control_phase = autosimPadLenString(phaseTxt, n);
    traceTbl.semantic_wind_risk = autosimPadLenString(semanticWindRisk, n);
    traceTbl.semantic_environment = autosimPadLenString(semanticEnvironment, n);
    traceTbl.semantic_drone_state = autosimPadLenString(semanticDroneState, n);
    traceTbl.semantic_alignment = autosimPadLenString(semanticAlign, n);
    traceTbl.semantic_visual = autosimPadLenString(semanticVisual, n);
    traceTbl.semantic_safe = autosimPadLen(double(semanticSafe), n);
    traceTbl.landing_feasibility = autosimPadLen(landingFeasibility, n);
    traceTbl.wind_body_force_x = autosimPadLen(windBodyForceX, n);
    traceTbl.wind_body_force_y = autosimPadLen(windBodyForceY, n);
    traceTbl.wind_body_force = autosimPadLen(windBodyForce, n);
    traceTbl.wind_body_risk = autosimPadLen(windBodyRisk, n);
    traceTbl.wind_gust_risk = autosimPadLen(windGustRisk, n);
    traceTbl.wind_dir_change_risk = autosimPadLen(windDirChangeRisk, n);
    traceTbl.wind_risk_raw = autosimPadLen(windRiskRaw, n);
    traceTbl.thrust_margin = autosimPadLen(thrustMargin, n);
    traceTbl.cmd_x = autosimPadLen(cmdXLog, n);
    traceTbl.cmd_y = autosimPadLen(cmdYLog, n);
    traceTbl.cmd_z = autosimPadLen(cmdZLog, n);
    traceTbl.estimation_uncertainty = autosimPadLen(ekfUncertaintyLog, n);
    traceTbl.gps_dropout_active = autosimPadLen(gpsDropoutActiveLog, n);
    traceTbl.moving_pad_offset_u = autosimPadLen(movingPadOffsetULog, n);
    traceTbl.moving_pad_offset_v = autosimPadLen(movingPadOffsetVLog, n);
    traceTbl.moving_pad_vel_u = autosimPadLen(movingPadVelULog, n);
    traceTbl.moving_pad_vel_v = autosimPadLen(movingPadVelVLog, n);
    traceTbl.trajectory_intent = autosimPadLenString(trajectoryIntentTxt, n);
    traceTbl.trajectory_target_u = autosimPadLen(trajectoryTargetULog, n);
    traceTbl.trajectory_target_v = autosimPadLen(trajectoryTargetVLog, n);
    traceTbl.trajectory_target_x = autosimPadLen(trajectoryTargetXLog, n);
    traceTbl.trajectory_target_y = autosimPadLen(trajectoryTargetYLog, n);
    traceTbl.trajectory_target_z = autosimPadLen(trajectoryTargetZLog, n);
    traceTbl.trajectory_quality = autosimPadLen(trajectoryQualityLog, n);
    traceTbl.navigation_instability = autosimPadLen(navInstabilityLog, n);
    traceTbl.wind_hazardous = autosimPadLen(windHazardousLog, n);
    traceTbl.follower_expected = autosimPadLen(followerExpectedLog, n);
    traceTbl.follower_pose_ready = autosimPadLen(followerPoseReadyLog, n);
    traceTbl.follower_state_ready = autosimPadLen(followerStateReadyLog, n);
    traceTbl.follower_tag_detected = autosimPadLen(followerTagDetectLog, n);
    traceTbl.follower_flying = autosimPadLen(followerFlyingLog, n);
    traceTbl.follower_cmd_xy_rms = autosimPadLen(followerCmdRmsLog, n);
    for i = 1:numel(cfg.ontology.semantic_feature_names)
        fn = char(cfg.ontology.semantic_feature_names(i));
        traceTbl.(['sem_' fn]) = autosimPadLen(semFeat(:, i), n);
    end
    traceTbl.scenario_policy = repmat(string(res.scenario_policy), n, 1);
    traceTbl.target_case = repmat(string(res.target_case), n, 1);
    traceTbl.pred_decision = repmat(string(res.pred_decision), n, 1);
    traceTbl.executed_action = repmat(string(res.executed_action), n, 1);
    traceTbl.action_source = repmat(string(res.action_source), n, 1);
    traceTbl.probe_episode = repmat(double(res.probe_episode), n, 1);
    traceTbl.probe_reason = repmat(string(res.probe_reason), n, 1);
    traceTbl.gt_safe_to_land = repmat(string(res.gt_safe_to_land), n, 1);
    traceTbl.decision_outcome = repmat(string(res.decision_outcome), n, 1);
    traceTbl.final_label = repmat(string(res.label), n, 1);
end

function v = autosimFieldOrDefault(s, name, fallback)
    if isstruct(s) && isfield(s, name)
        v = s.(name);
        return;
    end
    v = fallback;
end



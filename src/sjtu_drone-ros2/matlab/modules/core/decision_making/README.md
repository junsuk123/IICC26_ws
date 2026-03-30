# Decision Making Modules

정책 선택과 최종 판정 해석을 담당하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- 시나리오 정책 선택: exploit/boundary/hard_negative
- 온라인 feature 벡터 조합
- 예측/GT 기반 혼동행렬 지표 계산

## 주요 파일

- `autosimChooseScenarioPolicy.m`
- `autosimBuildAdaptiveScenarioConfig.m`
- `autosimBuildOnlineFeatureVector.m`
- `autosimPredictModel.m`
- `autosimBuildDecisionTable.m`
- `autosimEvaluateDecisionMetrics.m`
- `autosimClassifyDecisionOutcome.m`

## 판단식

$$
\hat{y}=\begin{cases}
\mathrm{AttemptLanding}, & s_{fusion}\ge\tau \\
\mathrm{HoldLanding}, & s_{fusion}<\tau
\end{cases}
$$

$$
\mathrm{UnsafeLandingRate}=\frac{FP}{FP+TN}
$$

## 유지보수 포인트

- 정책 분기 추가 시 `autosimChooseScenarioPolicy.m`와 `autosimBuildScenarioConfig.m`를 함께 수정합니다.
- 지표 계산 변경 시 `autosimEvaluateDecisionMetrics.m`와 후속 시각화 모듈을 함께 검토합니다.

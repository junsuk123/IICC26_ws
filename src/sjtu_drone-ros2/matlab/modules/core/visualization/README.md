# Visualization Modules

실시간 진행률 및 실험 결과 그래프를 생성하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- 실행 중 추세 플롯 초기화/업데이트
- 시나리오 실시간 시각화
- 검증 결과 그래프 및 리포트 저장

## 주요 파일

- `autosimInitPlots.m`
- `autosimUpdatePlots.m`
- `autosimInitScenarioRealtimePlot.m`
- `autosimUpdateScenarioRealtimePlot.m`
- `autosimPlotGtVsPrediction.m`
- `autosimSaveScenarioPerformanceReport.m`

## 핵심 지표

$$
\mathrm{Accuracy}=\frac{TP+TN}{TP+FP+FN+TN}
$$

$$
\mathrm{UnsafeLandingRate}=\frac{FP}{FP+TN}
$$

## 운영 포인트

- 병렬 실행에서는 필수 모니터 그래프만 활성화하는 것을 권장합니다.
- 정책 변경 시 지표 정의와 plot 레이블이 일치하는지 함께 점검합니다.

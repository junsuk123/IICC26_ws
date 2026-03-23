# Visualization Modules

실험 진행과 결과를 해석 가능한 그래프로 표현한다.

## 최근 업데이트 (2026-03-23)

해석 시 다음 두 항목을 기본 가정으로 반영한다.

- 바람 위험도는 벡터 성분 보존형 계산 결과를 사용한다.
- 수집 데이터는 드론 1대 기준 120초를 초과하지 않는다.

$$
r_{wind}=\max\left(r_v,\ r_v+k_a r_a\right),\quad
t_{collect}\le120\,\text{s}
$$

따라서 시계열 플롯/맵 해석에서 장시간 tail 왜곡과 방향 성분 누락 가능성을 줄일 수 있다.

## 기능 설명

- 진행 중 decision/performance 추세 그래프 업데이트
- 시나리오 실시간 온톨로지 플로우 시각화
- 실험 종료 후 GT vs Prediction, 성능 요약 그래프 생성

## 이론 포인트

- 단일 정확도보다 FP/FN 분해가 안전 연구에서 핵심
- 풍속 밴드/문맥 상태별 시각화가 정책 편향 탐지에 유효

시각화의 핵심 축은 confusion 분해다.

$$
\mathrm{Accuracy}=\frac{TP+TN}{TP+FP+FN+TN},\quad
\mathrm{F1}=\frac{2\cdot \mathrm{Precision}\cdot \mathrm{Recall}}{\mathrm{Precision}+\mathrm{Recall}}
$$

안전 관점에서는 위험 착륙 비율을 별도로 추적한다.

$$
\mathrm{UnsafeLandingRate}=\frac{FP}{FP+TN}
$$

풍속 밴드별 비율은 집계형 시각화로 해석한다.

$$
P(\mathrm{safe}\mid b)=\frac{N_{safe,b}}{N_b}
$$

## 핵심 변수/용어 표

| 항목 | 의미 | 단위/범위 | 비고 |
|---|---|---|---|
| dEval | 정책 기준 지표 struct | struct | TP/FP/FN/TN 포함 |
| dExec | 실행 기준 지표 struct | struct | executed_action 기준 |
| cum_accuracy | 누적 정확도 | 0~1 | 시나리오 축 추세 |
| cum_precision | 누적 정밀도 | 0~1 | FP 민감 |
| cum_recall | 누적 재현율 | 0~1 | FN 민감 |
| unsafe_landing_rate | 위험 착륙 비율 | 0~1 | 안전 핵심 지표 |
| wind band b | 풍속 구간 | categorical | 예: 0-1.5, 1.5-2.0 |
| feasibility curve | 의미론 가능도 추세 | 0~1 | 실시간 판단 보조 |

## 대표 파일

- `autosimInitPlots.m`
- `autosimUpdatePlots.m`
- `autosimInitScenarioRealtimePlot.m`
- `autosimUpdateScenarioRealtimePlot.m`
- `autosimPlotGtVsPrediction.m`

## 확장 가이드

- 논문 figure 변경은 이 폴더에서 데이터 집계 방식과 함께 수정한다.

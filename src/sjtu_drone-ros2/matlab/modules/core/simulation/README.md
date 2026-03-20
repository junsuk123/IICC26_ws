# Simulation Modules

Gazebo/ROS 상에서 시나리오를 실제 실행하고 리셋/착륙 흐름을 제어한다.

## 기능 설명

- launch, reset, takeoff, control-loop 실행
- soft reset(`/reset_world` -> `/reset_simulation`) 우선 시도
- 착륙 후 안정화 구간에서 최종 라벨 계산용 통계 추출

## 이론 포인트

- 제어 관점: 착륙 직전 추종 안정성과 touchdown 동역학 분리 평가
- 환경 관점: 풍속/풍향 시계열 및 가속도 기반 난류 성분 반영
- 안전 판정: 상태/자세/속도/접촉 지표를 조합해 stable/unstable 라벨링

풍속 가속도는 최근 시계열 기울기로 계산한다.

$$
a_w \approx \frac{dv}{dt}
$$

풍속/풍향은 벡터로 유지한다.

$$
v_x = v\cos\theta,\quad v_y = v\sin\theta,\quad |\mathbf{v}|=\sqrt{v_x^2+v_y^2}
$$

최종 라벨은 다중 안전 조건의 논리곱으로 표현된다.

$$
\mathrm{stable} = \bigwedge_i c_i,
\quad
\mathrm{unstable}=\neg\mathrm{stable}
$$

## 핵심 변수/용어 표

| 항목 | 의미 | 단위/범위 | 비고 |
|---|---|---|---|
| v, theta | 풍속, 풍향 | m/s, deg | 입력 풍장 모델 |
| v_x, v_y | 풍속 벡터 성분 | m/s | AI 입력까지 유지 |
| a_w | 풍속 가속도 | m/s^2 | dv/dt 근사 |
| controlPhase | 제어 단계 | pre_takeoff/takeoff/xy_hold/landing_track | 상태 머신 핵심 |
| landingSent | 착륙 시작 여부 | bool | true 시 착륙 추적 단계 |
| softResetOK | 서비스 리셋 성공 여부 | bool | /reset_world, /reset_simulation |
| final_state | 종료 시 드론 상태 | int | landed/flying 판정과 결합 |

## 대표 파일

- `autosimRunScenario.m`
- `autosimResetSimulationForScenario.m`
- `autosimSoftReset.m`
- `autosimComputeTagTrackingCommand.m`
- `autosimSummarizeAndLabel.m`

## 확장 가이드

- reset/takeoff 안정성, hover/landing phase 타이밍, 바람 모델 변경은 이 폴더에서 관리한다.

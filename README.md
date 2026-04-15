# IICC26 Workspace

IICC26 워크스페이스는 ROS2/Gazebo 시뮬레이션 계층과 MATLAB AutoSim 수집/학습/검증 계층을 결합한 드론 착륙 안전성 연구 환경입니다.

마지막 업데이트: 2026-03-31

## 1) 최근 변경 핵심 요약

- 파이프라인 중복 종료/강제 kill 스팸 완화: 중첩 실행 가드, 재진입 스로틀, 비대화형 정리 경로로 안정화
- 수집 중 사용자 중단 처리 강화: 중단 시 명시적 오류를 발생시켜 학습/검증/플롯 단계로 진행되지 않도록 변경
- RViz 궤적 시각화 보강:
	- Numeric guidance 토픽과 별개로 Marker 토픽 사용
	- bringup에 guidance->marker 브리지 노드 추가
	- 다중 네임스페이스(drone_w01..N) 자동 매핑 지원
- 검증 지표 전환:
	- 기본 지표를 착륙 이진판단에서 궤적 추종 품질로 전환
	- legacy 판단 지표(accuracy/precision/recall/specificity)는 참고용으로 유지
- 플롯 전환:
	- 논문용 플롯/표의 1차 비교 축을 trajectory follow score, RMSE, success rate 중심으로 변경
	- 기존 threshold baseline 비교를 AI-Only baseline 비교로 교체

## 2) 워크스페이스 구성

- ROS2 실행 계층:
	- src/sjtu_drone-ros2/sjtu_drone_bringup
	- src/sjtu_drone-ros2/sjtu_drone_description
	- src/sjtu_drone-ros2/sjtu_drone_control
	- src/sjtu_drone-ros2/sjtu_drone_interfaces
- MATLAB 분석 계층:
	- src/sjtu_drone-ros2/matlab
- 병렬 실행 스크립트:
	- src/sjtu_drone-ros2/scripts
	- src/sjtu_drone-ros2/matlab/scripts

## 3) 빠른 시작

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

단일 bringup:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py use_gui:=false use_rviz:=false
```

MATLAB 통합 파이프라인:

```matlab
AutoSimMain
```

## 4) 모델 타입과 역할

### AI-Only 모델 (aii_only)

- 순수 센서 특성 기반 GaussianNB 분류기
- 의미론 규칙 결합 없이 확률 기반 착륙 의사결정 수행
- 플롯 비교 시 baseline으로 사용

의사결정:

$$
\hat{y}_{ai}=
\begin{cases}
	ext{AttemptLanding}, & p_{safe}(\mathbf{x})\ge\tau \\
	ext{HoldLanding}, & p_{safe}(\mathbf{x})<\tau
\end{cases}
$$

### Ontology+AI 모델 (ontology_ai)

- AI 확률 출력 + 온톨로지 규칙 기반 의미론 점수 결합
- 풍하중/돌풍/정렬/시각 안정성/상태 전이 문맥까지 반영

융합 점수:

$$
s_{fusion}=w_m\,p_{safe}^{ai}(\mathbf{x})+(1-w_m)\,s_{semantic}
$$

$$
\hat{y}_{ontology+ai}=
\begin{cases}
	ext{AttemptLanding}, & s_{fusion}\ge\tau \\
	ext{HoldLanding}, & s_{fusion}<\tau
\end{cases}
$$

### Ontology 입력 특징 벡터 (8D)

GaussianNB 입력은 아래 8차원으로 고정됩니다.

$$
\mathbf{x}=\left[r_{body},\ r_{gust},\ s_{tilt},\ s_{descent},\ s_{lateral},\ s_{visual},\ s_{align},\ s_{context}\right] \in [0,1]^8
$$

- `r_body`: 정상 풍하중(Drag 기반) 위험도
- `r_gust`: 돌풍(크기 + 방향 변화) 위험도
- `s_tilt`: 기체 기울기 안정도(roll/pitch 기반)
- `s_descent`: 수직강하 안정도(vz 기반)
- `s_lateral`: 수평운동 안정도(횡방향 속도/변동 기반)
- `s_visual`: 시각 안정도(검출 연속성, 지터, 안정점수 기반)
- `s_align`: 착륙 타깃 중심 정렬도
- `s_context`: 도메인 상호작용 위험도

`s_context`는 단순 평균이 아니라 교차항으로 계산됩니다.

$$
s_{context}=\min\left(1,\ \alpha\,r_{gust}(1-s_{visual})+\beta\,r_{body}(1-s_{align})\right)
$$

초기값은 $\alpha=\beta=0.5$이며, 돌풍-시각 불안정 결합 및 정상풍-정렬불량 결합 리스크를 반영합니다.

## 5) 온톨로지 규칙 체계 (직관적 + 상세)

이 섹션은 실제 운용 관점에서 "왜 hold를 냈는지"를 사람이 추적 가능하도록 설명합니다.

### 5.1 규칙 입력 계층

- 바람 계층:
	- mean_wind_speed, max_wind_speed, wind_velocity_x/y, wind_acceleration_x/y
- 자세/동역학 계층:
	- mean_abs_roll_deg, mean_abs_pitch_deg, mean_abs_vz, stability_std_z, stability_std_vz
- 시각 추적 계층:
	- mean_tag_error, max_tag_error, final_tag_error, visual jitter 계열
- 상태/접촉 계층:
	- contact_count, max_contact_force, arm_force_imbalance, final_abs_speed

### 5.2 풍하중 기반 위험 규칙

풍력 성분:

$$
F_{wx}=\frac{1}{2}\rho c_x S_x v_x|v_x|,\quad
F_{wy}=\frac{1}{2}\rho c_y S_y v_y|v_y|
$$

본체 바람 위험도:

$$
r_{body}=\min\left(1,\frac{\sqrt{F_{wx}^2+F_{wy}^2}}{F_{cap}}\right)
$$

돌풍 위험도:

$$
r_{gust}=\min\left(1,\frac{\sqrt{a_x^2+a_y^2}}{a_{thr}}\right)
$$

풍계열 통합 위험:

$$
r_{wind}=\max(r_{body}, r_{gust})
$$

직관:
- 평균풍이 낮아도 순간 가속도(돌풍)가 크면 hold 성향이 강화됩니다.
- 평균풍이 높으면 돌풍이 낮아도 hold 성향이 강화됩니다.

### 5.3 정렬/시각 규칙

- 태그 정렬 오차가 누적되거나 지터가 커지면 착륙 후보 점수 하향
- 시각 손실(태그 불안정) 구간에서는 단기적으로 hold 가중 증가

예시 규칙:
- if visual_confidence is low and wind risk is medium/high then hold preference up
- if alignment error is stable and wind risk is low then attempt preference up

### 5.4 상태 전이 규칙

- 단일 시점 값보다 최근 구간 추세를 반영
- "호전 추세"면 hold에서 attempt로 완만 전이
- "악화 추세"면 attempt를 즉시 hold로 방어 전환

직관:
- 순간 노이즈로 급결정을 하지 않고, 안전한 히스테리시스를 유지합니다.

### 5.5 최종 의미론 점수 구성

규칙 엔진은 각 계층 위험도를 [0,1] 범위로 정규화해 semantic score로 집계합니다.

$$
s_{semantic}=\text{Aggregate}(r_{wind}, r_{visual}, r_{alignment}, r_{state})
$$

Aggregate는 max/weighted-max/guard-rule 조합으로 구성되며, 위험이 큰 항목을 우선 반영합니다.

### 5.6 AI와 온톨로지의 결합 해석

- AI가 "착륙 가능" 확률을 높게 주더라도,
- 온톨로지 규칙이 "환경 리스크 급증"을 감지하면 최종 점수는 hold 쪽으로 이동

즉, 온톨로지는 "확률 모델의 블라인드 스팟"을 보완하는 안전 레이어로 동작합니다.

## 6) 검증/플롯 지표 체계 (Trajectory 우선)

현재 기본 1차 지표:

- trajectory_follow_score
- trajectory_xyz_rmse_m
- trajectory_xy_rmse_m
- trajectory_z_rmse_m
- trajectory_success_rate
- execution_rate

보조/legacy 지표:

- accuracy, precision, recall, specificity, balanced_accuracy
- unsafe_landing_rate

follow score 개념:

$$
	ext{follow\_score}=\text{mean}\big(1-\tilde e_{xy},\;1-\tilde e_z,\;q_{traj},\;success\_rate,\;execution\_rate\big)
$$

여기서 $\tilde e$는 정규화 오차, $q_{traj}$는 trajectory quality입니다.

## 7) AI-Only baseline 비교로의 전환

플롯 비교 기준은 이제 다음 2개입니다.

- Ontology+AI (policy)
- AI-Only baseline

동작 방식:

1. 데이터셋에 AI-Only 예측 컬럼이 있으면 재사용
2. 없으면 최신 AI-Only 모델을 로드해 같은 검증 샘플에 직접 추론

결과적으로 threshold 기반 휴리스틱 baseline 없이도 모델 간 공정 비교가 가능합니다.

## 8) RViz 궤적 시각화 파이프라인

### 토픽 구조

- 입력(수치): /<ns>/trajectory_guidance (std_msgs/Float32MultiArray)
- 출력(시각화): /<ns>/trajectory_guidance_marker (visualization_msgs/Marker)

### 브리지 노드

bringup의 trajectory guidance marker bridge가 수치 guidance를 Marker로 변환하여 RViz에서 항상 렌더링 가능한 형태로 제공합니다.

### 중요 포인트

- bringup만 실행하면 marker 토픽은 보일 수 있으나,
- 실제 선형 궤적 내용은 MATLAB guidance publish가 있어야 업데이트됩니다.

## 9) 병렬 실행

Gazebo 병렬:

```bash
cd /home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2
./scripts/run_parallel_gazebo.sh 4
./scripts/stop_parallel_gazebo.sh
```

AutoSim 병렬:

```bash
cd /home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2
matlab/scripts/run_autosim_parallel.sh auto
matlab/scripts/stop_autosim_parallel.sh
```

결과 병합:

```bash
python3 matlab/scripts/merge_autosim_results.py matlab/parallel_runs/<session_root>
```

## 10) 검증 결과 저장 구조

```text
<data_root>/validation_holdout_aii_only_<TIMESTAMP>/
	autosim_dataset_latest.csv
	autosim_validation_summary.csv
	autosim_validation_split.csv

<data_root>/validation_holdout_ontology_ai_<TIMESTAMP>/
	autosim_dataset_latest.csv
	autosim_validation_summary.csv
	autosim_validation_split.csv
```

## 11) 관련 문서

- src/sjtu_drone-ros2/README.md
- src/sjtu_drone-ros2/matlab/README.md
- DRONE_SPAWN_ERROR_ANALYSIS.md

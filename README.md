# IICC26 Workspace

IICC26 워크스페이스는 ROS2/Gazebo 시뮬레이션 계층과 MATLAB AutoSim 판단/학습 계층을 결합한 드론 착륙 안전성 연구 환경입니다.

마지막 업데이트: 2026-03-30

## 핵심 구성

- ROS2 실행 계층: `src/sjtu_drone-ros2/sjtu_drone_bringup`, `sjtu_drone_description`, `sjtu_drone_control`, `sjtu_drone_interfaces`
- MATLAB 분석 계층: `src/sjtu_drone-ros2/matlab` (수집, 학습, 검증, 플롯)
- 병렬 실행 스크립트: `src/sjtu_drone-ros2/scripts`, `src/sjtu_drone-ros2/matlab/scripts`

## 빠른 시작

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

단일 실행:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py use_gui:=false use_rviz:=false
```

MATLAB 파이프라인:

```matlab
AutoSimMain
```

## 병렬 실행 요약

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

병합:

```bash
python3 matlab/scripts/merge_autosim_results.py matlab/parallel_runs/<session_root>
```

## 연구 이론 요약

바람 벡터와 가속도 벡터는 성분을 유지해 위험도를 계산합니다.

$$
\mathbf{v}_w=[v_x,v_y]^\top,\quad \mathbf{a}_w=[a_x,a_y]^\top
$$

$$
F_{wx}=\frac{1}{2}\rho c_x S_x v_x|v_x|,\quad
F_{wy}=\frac{1}{2}\rho c_y S_y v_y|v_y|
$$

$$
r_{body}=\min\left(1,\frac{\sqrt{F_{wx}^2+F_{wy}^2}}{F_{cap}}\right),\quad
r_{gust}=\min\left(1,\frac{\sqrt{a_x^2+a_y^2}}{a_{thr}}\right)
$$

$$
r_{wind}=\max(r_{body}, r_{gust})
$$

최종 의사결정은 의미론 점수와 모델 확률의 결합으로 계산합니다.

$$
s_{fusion}=w_m\,p_{model}(safe)+(1-w_m)\,s_{semantic}
$$

$$
\hat{y}=\begin{cases}
\mathrm{AttemptLanding}, & s_{fusion}\ge\tau \\
\mathrm{HoldLanding}, & s_{fusion}<\tau
\end{cases}
$$

수집 시간 상한:

$$
t_{collect} \le 120\,\text{s per drone}
$$

## 평가 지표

$$
\mathrm{Accuracy}=\frac{TP+TN}{TP+FP+FN+TN},\quad
\mathrm{BalancedAccuracy}=\frac{\mathrm{Recall}+\mathrm{Specificity}}{2}
$$

$$
\mathrm{UnsafeLandingRate}=\frac{FP}{FP+TN}
$$

핵심 안전 지표는 `UnsafeLandingRate`, `Specificity`, `BalancedAccuracy`입니다.

## 관련 문서

- 저장소 개요: `src/sjtu_drone-ros2/README.md`
- MATLAB 계층: `src/sjtu_drone-ros2/matlab/README.md`
- DRONE spawn 이슈 분석: `DRONE_SPAWN_ERROR_ANALYSIS.md`

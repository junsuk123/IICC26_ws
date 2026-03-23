# Wind Tuner

`wind_tuner.py`는 wind plugin 파라미터 스윕을 수행하고 `/wind_condition`을 기록한다.

## 최근 업데이트 (2026-03-23)

튜닝 결과 해석 시 MATLAB 판단 계층의 최신 기준을 함께 고려한다.

- 위험도는 풍속/풍가속도 벡터 성분 보존형 계산을 사용
- 시나리오 수집은 드론 1대당 120초 상한

$$
\mathbf{v}_w=[v_x,v_y]^\top,\quad
\mathbf{a}_w=[a_x,a_y]^\top
$$

$$
r_{wind}=\max\left(r_v,\ r_v+k_a r_a\right),\quad t_{collect}\le120\,\text{s}
$$

## 사전 준비

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

`sjtu_drone_description`가 빌드되어 있고 `libwind_plugin.so`가 설치되어 있어야 한다.

워크스페이스 루트(`/home/j/INCSL/IICC26_ws`) 기준 실행을 권장한다.

## 실행 예시

```bash
python3 src/sjtu_drone-ros2/sjtu_drone_description/scripts/wind_tuner.py \
  --world src/sjtu_drone-ros2/sjtu_drone_description/worlds/playground.world \
  --area 0.1 0.2 0.5 \
  --coeff 0.5 1.0 2.0 \
  --speed 2.0 5.0 \
  --dir 0 90 180 \
  --duration 15 \
  --publish_rate_hz 10.0 \
  --out /tmp/wind_tuning
```

## 동작 메모

- The script injects a `<plugin name="wind_plugin" ...>` block into a copied world file.
- Prefer a world template without an existing `wind_plugin` block to avoid duplicate plugin entries.

## 기록 결과

- `/wind_condition` time series
- one output folder per parameter combination
- gzserver logs for each run

## 착륙 파이프라인과의 관계

- MATLAB landing node reads `/wind_condition`.
- Startup takeoff target can be tuned via bringup launch args `takeoff_hover_height` and `takeoff_vertical_speed`.
- AprilTag landing observability runs in parallel from bringup.
- Bridge topic `/landing_tag_state` supports MATLAB fallback when custom tag messages are unavailable.
- MATLAB landing node may hold last valid tag state for a short timeout during tag dropouts, so evaluate both raw detector stability and hold-time behavior when tuning.

## 확장 아이디어

착륙 성능 중심 튜닝으로 확장하려면 다음 지표를 추가한다.

- pose drift metrics
- touchdown success criteria
- ranking/scoring across wind parameter sets

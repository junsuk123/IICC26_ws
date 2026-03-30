# sjtu_drone-ros2

IICC26 드론 착륙 실험용 ROS2/Gazebo + MATLAB 통합 저장소입니다.

마지막 업데이트: 2026-03-30

## 패키지 구성

- `sjtu_drone_bringup`: 런치, 스폰, AprilTag bridge
- `sjtu_drone_description`: URDF/SDF, world, Gazebo plugin
- `sjtu_drone_control`: teleop/open-loop/position control
- `sjtu_drone_interfaces`: `SetWind` 서비스 정의
- `matlab`: AutoSim 수집/학습/검증/시각화

## 빌드

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

## 기본 실행

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
  use_gui:=false \
  use_rviz:=false \
  use_teleop:=false \
  use_apriltag:=true
```

## 병렬 Gazebo

스크립트 방식:

```bash
cd /home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2
./scripts/run_parallel_gazebo.sh 4
./scripts/stop_parallel_gazebo.sh
```

launch 방식:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_parallel.launch.py \
  instance_count:=4 \
  domain_id_base:=40 \
  gazebo_port_base:=12045
```

## AutoSim 병렬

```bash
cd /home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2
matlab/scripts/run_autosim_parallel.sh auto
matlab/scripts/stop_autosim_parallel.sh
```

결과 병합:

```bash
python3 matlab/scripts/merge_autosim_results.py matlab/parallel_runs/<session_root>
```

모니터링:

```matlab
monitor_autosim_parallel('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/parallel_runs/<session_root>', 2.0)
```

## 도메인 브리지(옵션)

```bash
OBSERVE_DOMAIN=90 matlab/scripts/run_autosim_domain_bridge.sh matlab/parallel_runs/<session_root>
matlab/scripts/stop_autosim_domain_bridge.sh matlab/parallel_runs/<session_root>
```

## 문서

- MATLAB 실행 가이드: `matlab/README.md`
- 드론 모델/풍장 플러그인: `sjtu_drone_description/README.md`
- 제어 노드: `sjtu_drone_control/sjtu_drone_control/Readme.md`

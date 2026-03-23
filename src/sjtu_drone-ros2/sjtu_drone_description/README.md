# sjtu_drone_description

드론 모델, 월드, Gazebo 플러그인을 제공하는 패키지다.

## 최근 업데이트 (2026-03-23)

MATLAB AutoSim 계층과의 연계 기준을 문서화했다.

- `/wind_condition`은 방향 성분을 포함한 벡터 해석을 전제로 사용한다.
- 상위 수집 파이프라인은 드론 1대당 120초 타임아웃 정책을 적용한다.

풍장 해석 식:

$$
v_x=v\cos\theta,\quad v_y=v\sin\theta
$$

$$
t_{collect}\le120\,\text{s}
$$

## 구조

- `models/`: Gazebo 모델 리소스
- `urdf/`: xacro/urdf
- `src/`: C++ 플러그인 구현
- `include/`: 플러그인 헤더
- `worlds/`: 시뮬레이션 월드

## 월드 파일

기본 포함 월드:

- `playground.world`
- `landingPad.world`

`sjtu_drone_bringup` 기본값은 `landingPad.world`다.

다른 월드 실행 예시:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
	world:=/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/sjtu_drone_description/worlds/playground.world
```

월드/모델 수정 후 install-space 반영:

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --packages-select sjtu_drone_description
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

## Wind Plugin

`libwind_plugin.so`가 월드 기반 바람 외란을 주입한다.

인터페이스:

- `/wind_command` (`std_msgs/msg/Float32MultiArray`): `[speed_mps, direction_deg]`
- `/wind_condition` (`std_msgs/msg/Float32MultiArray`): 바람 상태 출력
- `/set_wind` (`sjtu_drone_interfaces/srv/SetWind`): 서비스 제어 경로

`worlds/landingPad.world` 기본 파라미터:

- `wind_speed: 0.0`
- `wind_direction: 0`
- `area: 0.1`
- `force_coeff: 1.0`
- `publish_rate_hz: 10.0`

빠른 확인:

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [4.0, 45.0]" -1
ros2 topic echo /wind_condition --once
```

## 이륙 호버 설정

이륙 단계 기본 동작을 런치 인자로 조정할 수 있다.

- `takeoffHoverHeight` (YAML/xacro/plugin): altitude increase target in meters
- `takeoffVerticalSpeed` (YAML/xacro/plugin): climb command during takeoff phase

Default values are defined in:

- `sjtu_drone_bringup/config/drone.yaml`

Current defaults in code/yaml:

- `takeoffHoverHeight: 1.0`
- `takeoffVerticalSpeed: 1.0`

실행 시 오버라이드:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
  takeoff_hover_height:=2.0 \
  takeoff_vertical_speed:=0.8
```

## AprilTag + MATLAB 연동

AprilTag 활성화 시:

- detector output topic: `/drone/bottom/tags`
- bridge output topic: `/landing_tag_state`

`/landing_tag_state`는 MATLAB에서 `apriltag_msgs`를 직접 import하기 어려운 환경을 위한 호환 토픽이다.

## URDF/SDF 생성

URDF 생성:

```bash
ros2 run xacro xacro -o ./urdf/sjtu_drone.urdf ./urdf/sjtu_drone.urdf.xacro \
	params_path:="$(ros2 pkg prefix sjtu_drone_bringup)/share/sjtu_drone_bringup/config/drone.yaml" \
	takeoff_hover_height:=2.0 \
	takeoff_vertical_speed:=0.8
```

SDF 생성:

```bash
gz sdf -p ./urdf/sjtu_drone.urdf > ./models/sjtu_drone/model.sdf
```

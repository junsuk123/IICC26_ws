# IICC26_ws

이 워크스페이스는 드론 자율 착륙 연구를 위한 핵심 코드와 시뮬레이션, ROS2 환경을 정리한 공간입니다.

- `drone_autonomous_landing/` : 자율 착륙 관련 전체 코드 및 리소스

## 빠른 실행 가이드 (요약)

이 저장소는 여러 하위 폴더로 구성되어 있습니다. 가장 빠르게 시뮬레이션을 실행하려면 아래 위치로 이동하세요:

- 워크스페이스 (Gazebo/ROS2 관련): `drone_autonomous_landing/drone_ws`

기본 실행 흐름:

1. 워크스페이스로 이동: `cd drone_autonomous_landing/drone_ws`
2. 필요한 의존성을 설치/빌드: `./scripts/build.sh` (또는 `colcon build`)
3. 시뮬레이터 실행(개발용): `./scripts/launch.sh`  
	- `./scripts/launch.sh` (인자 없이) : 개발용 source world(소스 모델/플러그인 사용)
	- `./scripts/launch.sh windy` : 위와 동일
	- `./scripts/launch.sh ros` : 기존 `ros2 launch drone gazebo_drone.launch.py` 를 호출 (ROS2 런치 사용)

문제가 발생하면 `~/.gazebo` 아래의 서버 로그(`server-*/default.log`, `gzserver.log`)와 `/tmp`에 생성된 실행 로그(`/tmp/gzserver_run.log`, `/tmp/gazebo_launch_*.log`)를 확인하세요.

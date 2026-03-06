## Drone Autonomous Landing — Workspace (drone_ws)

간단 소개
- 이 워크스페이스는 Gazebo + ROS 2(Humble)에서 자율 착륙 실험을 위한 드론 시뮬레이션 패키지들을 포함합니다.
- 주요 패키지: `drone`, `drone_description`, `drone_control`, `drone_sensors`, `drone_simulation`, `sjtu_drone_control`, 등

관리자
- Junsuk Kim <bob4587@naver.com>
- 소속: INCSL (지능항법제어시스템연구실, 세종대학교)

빠른 시작 (로컬에서)
1. 워크스페이스 루트로 이동
```
cd /home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws
```
2. (선택) 가상환경 생성 — 이미 `scripts/create_venv.sh`가 있음
```
./scripts/create_venv.sh
source .venv/bin/activate
```
3. 빌드(환경 정리 포함)
```
./scripts/build.sh
```
4. 시뮬레이터 실행
```
./scripts/launch.sh
```

자주 사용하는 명령 (예)
- 토픽 확인: `ros2 topic list | grep simple_drone`
- 이륙: `ros2 topic pub /simple_drone/takeoff std_msgs/msg/Empty "{}" -1`
- 착륙: `ros2 topic pub /simple_drone/land std_msgs/msg/Empty "{}" -1`
- 이동(속도 제어): `ros2 topic pub -r 10 /simple_drone/cmd_vel geometry_msgs/msg/Twist "{linear:{x:0.5,y:0.0,z:0.0}, angular:{x:0.0,y:0.0,z:0.0}}"`

환경 관련 노트
- 시스템에 이미 설치된(또는 사용자 셸에서 자동으로 활성화되는) 외부 Python 번들이 colcon/ros2 실행에 문제를 줄 수 있습니다 (예: IsaacSim/Omniverse). 이 리포지토리에는 다음 보정이 포함되어 있습니다:
  - `scripts/build.sh`, `scripts/launch.sh` — PYTHONPATH 제거, PYTHONNOUSERSITE 설정, `/usr/bin` 우선화 등 환경 정리 wrapper.
  - `scripts/create_venv.sh` — 로컬 `.venv`를 만들어 패키징 도구를 격리 설치합니다.

GitHub로 배포
- 아래 `./.github/workflows/colcon.yml` 에 간단한 CI 예제가 포함되어 있습니다.
- 로컬에서 깃 리포지터리 초기화 및 업로드 예:
```
git init
git add .
git commit -m "Initial import"
git remote add origin git@github.com:<your-org>/<repo>.git
git branch -M main
git push -u origin main
```

더 자세한 패키지별 설명은 각 패키지 폴더의 README.md를 확인하세요.
# ROS2 드론 패키지 통합 워크스페이스

이 워크스페이스는 드론 자율비행/착륙 연구를 위한 ROS2 핵심 패키지들을 통합 관리합니다.

* `src/sjtu_drone_bringup/` : 드론 bringup 및 시스템 통합, 런치, 설정
* `src/sjtu_drone_control/` : 드론 제어 노드, 제어 알고리즘, 센서 연동

각 패키지는 ROS2 표준 구조를 따르며, launch/config/resource/scripts 등 세부 폴더로 구성되어 있습니다.

실제 코드, 설정, 모델 파일 등은 기존 패키지에서 복사해 넣으세요.

## Gazebo WindPlugin 및 실행 가이드 (개발자용)

이 저장소에는 Gazebo에서 바람을 시뮬레이션하기 위한 World 플러그인(`WindPlugin`)과 예제 월드(`AI_Center3_windy.world`)가 포함되어 있습니다. 빠르게 시뮬레이션을 실행하려면 다음을 따르세요.

빌드

```
cd /home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws
./scripts/build.sh
```

실행(개발용, 소스 파일 사용)

```
./scripts/launch.sh        # 또는 인자 없이 실행하면 소스 월드를 사용합니다
```

실행(ROS2 런치 사용)

```
./scripts/launch.sh ros
# 또는
source install/setup.bash
ros2 launch drone gazebo_drone.launch.py
```

환경 변수

- 개발용 실행은 `scripts/launch.sh`가 자동으로 `GAZEBO_MODEL_PATH`와 `LD_LIBRARY_PATH`를 소스 폴더로 설정합니다. 수동 실행 시 동일한 환경을 설정해야 합니다.

예: 수동 실행 전

```
export GAZEBO_MODEL_PATH="$PWD/src/drone_description/models:${GAZEBO_MODEL_PATH:-}"
export LD_LIBRARY_PATH="$PWD/src/drone_description/plugins:${LD_LIBRARY_PATH:-}"
gzserver -v src/drone_description/worlds/AI_Center3_windy.world
```

디버그 팁

- Gazebo 서버 로그: `~/.gazebo/server-*/default.log` 및 `~/.gazebo/server-*/gzserver.log`
- 빠르게 발생하는 즉시 종료 문제는 `strace` 또는 `LD_DEBUG=files`로 라이브러리 로드 문제를 확인하세요.
- ROS2 쪽에서 플러그인 런타임 파라미터·토픽을 확인하려면 `ros2 topic list | grep wind` 및 `ros2 param get` 등을 사용하세요.

플러그인 위치

- 빌드 후 플러그인 라이브러리: `install/drone_description/lib/libplugin_wind.so` 또는 개발 소스: `src/drone_description/plugins/libplugin_wind.so`

문제가 발생하면 위 로그와 `/tmp/gzserver_run.log`, `/tmp/strace_gzserver_full.*` 파일을 첨부해 주세요.

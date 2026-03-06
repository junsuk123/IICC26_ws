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

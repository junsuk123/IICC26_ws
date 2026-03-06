# package: drone

간단 소개
- `drone` 패키지는 URDF/Xacro, launch 파일, 그리고 시뮬레이션에서 드론을 스폰하기 위한 설정을 포함합니다.

주요 파일
- `urdf/sjtu_drone.urdf.xacro` — 드론의 URDF 템플릿
- `launch/gazebo_drone.launch.py` — Gazebo world 및 spawn launcher

사용법
1. 워크스페이스 루트에서 빌드 및 설치
```
./scripts/build.sh
```
2. 시뮬레이터 실행
```
./scripts/launch.sh
```

토픽/서비스
- 드론 네임스페이스: `/simple_drone` (SDF에서 설정). 토픽 예: `/simple_drone/cmd_vel`, `/simple_drone/takeoff`, `/simple_drone/land`.

관리자
- Junsuk Kim <bob4587@naver.com>

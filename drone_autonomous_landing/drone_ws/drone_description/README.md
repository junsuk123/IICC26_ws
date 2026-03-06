# package: drone_description

간단 소개
- `drone_description` 패키지는 드론의 모델(SDF/URDF), 메시(mesh), 그리고 Gazebo 플러그인(`libplugin_drone.so`)을 포함합니다.

주요 파일
- `models/sjtu_drone/sjtu_drone.sdf` — Gazebo 모델
- `src/` — C++ 플러그인 소스 (plugin_drone.cpp 등)
- `CMakeLists.txt`, `package.xml` — 빌드 및 설치 규칙

사용법
- 플러그인과 모델은 `colcon build` 후 `install/drone_description`에 복사됩니다. Gazebo에서 모델을 사용하려면 `GAZEBO_PLUGIN_PATH` 및 `GAZEBO_MODEL_PATH`가 올바로 설정되어야 합니다. `./scripts/launch.sh`에서 이 점을 처리합니다.

유의사항
- SDF 내 IMU/noise 관련 필드는 Gazebo 버전에 따라 경고를 발생시킬 수 있어 표준 구조로 정리해두었습니다.

관리자
- Junsuk Kim <bob4587@naver.com>

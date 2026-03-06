# Windy world 실행 가이드

이 문서는 로컬 개발 중인 `drone_description`의 Gazebo 바람 플러그인(WindPlugin)을 빌드하고 실행하며 디버그하는 방법을 정리합니다.

요약
- 권장 실행: 워크스페이스 최상위에서 `./scripts/launch.sh`를 실행하면 개발용 소스 world/model/plugin을 사용해 Gazebo를 띄웁니다.
- 수동 실행: `gzserver`와 `gzclient`를 직접 실행해 소스 world를 지정할 수 있습니다.

전제 조건
- Linux
- ROS 2 Humble(예: /opt/ros/humble)
- Gazebo Classic 11.x
- 워크스페이스 경로(예시):
  - `/home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws`

주요 경로
- 소스 world: `src/drone_description/worlds/AI_Center3_windy.world`
- 소스 모델: `src/drone_description/models/windy_box/model.sdf`
- 플러그인 라이브러리(소스 빌드 후): `src/drone_description/plugins/libplugin_wind.so`
- 런치 스크립트: `./scripts/launch.sh` (개발용 기본 설정 포함)

1) 빌드

터미널에서 워크스페이스 루트로 이동한 뒤 아래를 실행하세요.

```bash
cd /home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws
colcon build --packages-select drone_description
```

빌드 완료 후(또는 필요 시) 설치된 오버레이를 소스합니다:

```bash
source install/setup.bash
```

2) 권장 실행 (편리한 스크립트)

개발 중에는 `./scripts/launch.sh`를 사용하세요. 이 스크립트는 기본적으로 소스의 `AI_Center3_windy.world`를 사용하도록 설정되어 있습니다.

```bash
./scripts/launch.sh
```

스크립트는 내부적으로 `GAZEBO_MODEL_PATH`와 `LD_LIBRARY_PATH`를 소스의 `models`/`plugins` 디렉터리로 설정하고 `gzserver`(소스 world) + `gzclient`를 실행합니다.

원래의 ROS2 `ros2 launch` 동작을 사용하려면 인자를 붙여 호출하세요:

```bash
./scripts/launch.sh ros
```

3) 수동 실행 (직접 gzserver 사용)

환경 변수를 맞춘 뒤 `gzserver`/`gzclient`를 실행합니다.

```bash
export GAZEBO_MODEL_PATH=/home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws/src/drone_description/models:$GAZEBO_MODEL_PATH
export LD_LIBRARY_PATH=/home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws/src/drone_description/plugins:$LD_LIBRARY_PATH

# gzserver (백그라운드로 띄우려면 & 추가)
gzserver -v /home/j/INCSL/IICC26_ws/drone_autonomous_landing/drone_ws/src/drone_description/worlds/AI_Center3_windy.world &

# GUI 클라이언트
gzclient
```

4) 정상 동작 확인

- Gazebo 로그(실시간 또는 파일): `~/.gazebo/server-11345/default.log` 또는 `/home/j/.gazebo/server-11345/gzserver.log`
- 로그에서 다음 메시지 확인:
  - `WindPlugin loaded` (플러그인 로드)
  - 모델 관련 메시지 (windy_box 로드 등)

```bash
tail -f ~/.gazebo/server-11345/default.log
```

- 플러그인 존재/의존성 확인:

```bash
ls -l src/drone_description/plugins/libplugin_wind.so
ldd src/drone_description/plugins/libplugin_wind.so
```

- ROS 토픽/노드 확인(플러그인이 rclcpp를 사용하면):

```bash
ros2 node list
ros2 topic list
```

5) 흔한 문제와 해결

- 모델을 찾을 수 없음: `Unable to find uri[model://windy_box]`
  - 원인: `GAZEBO_MODEL_PATH`에 models 폴더가 포함되어 있지 않음
  - 해결: `export GAZEBO_MODEL_PATH=.../src/drone_description/models:$GAZEBO_MODEL_PATH` 또는 world에서 `file:///absolute/path/model.sdf` 사용

- 플러그인 로드 실패: `Failed to load plugin libplugin_wind.so: cannot open shared object file`
  - 원인: `LD_LIBRARY_PATH`에 플러그인 디렉터리가 없음 또는 .so 파일 권한/존재 문제
  - 해결: `export LD_LIBRARY_PATH=.../src/drone_description/plugins:$LD_LIBRARY_PATH` 및 `ls -l`/`ldd`로 확인

- SDF 파서 에러: `Missing element description for [aerodynamics]`
  - 원인: 모델 SDF에 비표준(스키마 외) 태그 추가
  - 해결: 모델 SDF 내부에 직접 커스텀 태그를 두지 말고, plugin SDF의 `<model_overrides>` 같은 블록으로 이동시키거나 `<gazebo>` 확장 규약을 따르세요.

- gzserver가 즉시 종료(exit code 255):
  1. 다른 gzserver가 포트를 점유하는지 확인: `ps aux | grep gzserver` → kill 필요 시 kill
  2. `ulimit -c unlimited` 후 재실행해서 core 덤프 확인
  3. `LD_DEBUG=files gzserver ...` 또는 `strace -ff -o /tmp/strace_gzserver gzserver ...`로 로더/시스템콜 추적

6) 디버깅 명령 모음 (복사해서 사용)

```bash
# 플러그인 의존성 확인
ldd src/drone_description/plugins/libplugin_wind.so

# Gazebo 로그(파일)
tail -n 200 ~/.gazebo/server-11345/default.log

# LD 로더 로그(심층)
LD_DEBUG=files gzserver -v path/to/AI_Center3_windy.world 2>&1 | tee /tmp/lddebug_gzserver.log

# 시스템콜 추적
strace -ff -o /tmp/strace_gzserver gzserver -v path/to/AI_Center3_windy.world 2>&1 | tee /tmp/gzserver_strace.log

# gdb로 실행(크래시시 백트레이스)
ulimit -c unlimited
gdb --batch --ex "run" --ex "bt full" --args gzserver -v path/to/AI_Center3_windy.world 2>&1 | tee /tmp/gdb_gzserver.log
```

7) 개발 팁
- 개발 중에는 `GAZEBO_MODEL_PATH`와 `LD_LIBRARY_PATH`가 항상 소스 폴더(`src/...`)를 가리키게 하세요. 설치된(`install/`) 복사본과 충돌이 발생하면 오래된 내용이 로드될 수 있습니다.
- 반복 테스트 중에는 `install/drone_description/share/drone_description/models` 같은 설치 복사본을 제거(또는 덮어쓰기)하여 혼선을 줄이세요.

8) 도움받기
- 로그/에러 출력과 함께 알려주시면 제가 직접 로그를 분석해 드리겠습니다. 주요 파일(플러그인 .so, world, model) 경로와 실행 명령을 함께 알려주세요.

---
이 파일을 워크스페이스의 `src/drone_description/README_RUN.md`로 추가했습니다. 원하시면 이 README를 `README.md`로 통합하거나 `./scripts/launch.sh`를 더 사용자 친화적으로(옵션/플래그) 개선해 드리겠습니다.

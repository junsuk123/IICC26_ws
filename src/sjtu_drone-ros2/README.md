# sjtu_drone for IICC26

이 저장소는 드론 착륙 안전성 연구를 위한 ROS2/Gazebo 실행 계층과 MATLAB AutoSim 분석 계층을 함께 제공한다.

## 아키텍처 개요

- 실행 계층(ROS2/Gazebo): 물리 시뮬레이션, 센서/토픽, 풍속 외란 플러그인
- 판단 계층(MATLAB): 온톨로지+AI 융합 판단, 정책 평가, 학습/검증 루프
- 데이터 계층(CSV/MAT): 시나리오 결과, trace, 모델 스냅샷, 논문용 요약 산출물

## 패키지 구성

- `sjtu_drone_bringup`: Gazebo, AprilTag, bridge, 런치 인자 관리
- `sjtu_drone_description`: URDF/SDF, world, wind plugin
- `sjtu_drone_control`: 제어 노드
- `sjtu_drone_interfaces`: `SetWind` 서비스
- `matlab/`: `AutoSimMain.m`, `AutoSim.m`, 검증/플롯 스크립트

## 요구 환경

- Ubuntu 22.04
- ROS2 Humble
- Gazebo Classic 11
- MATLAB R2024b 이상 권장

## 빌드

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

주의:

- `install/setup.bash` 기준으로 실행 경로를 통일한다.
- `src/` 하위 launch/xacro/python/cpp를 수정하면 관련 패키지를 재빌드해야 반영된다.

## ROS 실행 예시

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash

ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
  use_gui:=false \
  use_rviz:=false \
  use_teleop:=false \
  use_apriltag:=true \
  apriltag_camera:=/drone/bottom \
  apriltag_image:=image_raw \
  apriltag_tags:=tags \
  apriltag_type:=umich \
  apriltag_bridge_topic:=/landing_tag_state
```

## 핵심 인터페이스

- `/wind_command`: 풍속/풍향 명령 입력
- `/wind_condition`: 풍속/풍향 상태 출력
- `/set_wind`: 풍속 설정 서비스
- `/landing_tag_state`: MATLAB 호환 AprilTag bridge
- `/drone/gt_pose`, `/drone/gt_vel`, `/drone/state`: AutoSim 주요 입력

## MATLAB 실행

```matlab
AutoSimMain
```

또는

```matlab
run('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/AutoSim.m')
```

AutoSim 주요 기능:

- 시나리오 생성/실행/정리 자동화
- 온톨로지+AI 융합 판단
- 누적 데이터셋 기반 모델 학습/검증
- 결과 CSV, 추적 로그, 논문용 figure/table 생성

상세 문서:

- [matlab/README.md](matlab/README.md)
- [matlab/ROS2_Gazebo_MATLAB_Validation_Guideline.md](matlab/ROS2_Gazebo_MATLAB_Validation_Guideline.md)

## 산출물 취급 원칙

- `build/`, `install/`, `log/`는 빌드/실행 산출물
- `matlab/data`, `matlab/logs`, `matlab/models`, `matlab/plots`는 실험 산출물
- 버전 관리 대상과 산출물 경로를 분리해 재현성을 유지한다

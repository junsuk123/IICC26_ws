# 드론 ROS2 시스템 파트별 구조

- `drone_sensors/` : IMU, GPS, 바람센서 등 드론 센서 노드 및 인터페이스
- `drone_control/` : 드론 제어(추력, 롤, 피치, 요, 각속도, 모터별 제어 등 세부 제어)
- `drone_simulation/` : 시뮬레이션 환경, launch, world, URDF 등
- `drone_disturbance/` : 외란(바람 등) 시뮬레이션 및 플러그인 연동

각 파트별로 ROS2 패키지 구조를 따르며, 실제 코드/설정/모델은 이 폴더에 분배해 관리합니다.

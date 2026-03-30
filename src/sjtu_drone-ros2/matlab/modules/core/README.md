# Core Modules Overview

`modules/core`는 AutoSim의 도메인별 구현 레이어입니다.

마지막 업데이트: 2026-03-30

## 폴더 맵

- `orchestration`: 설정, 실행 흐름, 체크포인트, 종료
- `simulation`: 시나리오 실행, reset, takeoff/landing 제어
- `ros_io`: 토픽/서비스 IO, 메시지 파싱, ROS 컨텍스트
- `ontology`: 의미 상태 구성, 인코딩, 규칙 추론
- `decision_making`: 정책 선택, 온라인 feature 벡터, 결과 평가
- `learning`: 모델 로드/학습/추론/GaussianNB
- `visualization`: 실시간/오프라인 플롯
- `utils`: 공통 수치/시스템/프로세스 유틸

## 공통 원칙

- 벡터 성분(`wind_velocity_x/y`, `wind_acceleration_x/y`)을 유지한 채 위험도/feature를 계산합니다.
- 수집 타임아웃은 드론 기준 120초 상한을 따릅니다.
- 모듈 간 공통 로직은 `utils`로 올리고, 도메인 로직은 해당 모듈에 둡니다.

## 참고

각 폴더의 상세 문서는 하위 `README.md`를 참조하세요.

# ROS I/O Modules

ROS2 토픽/서비스 IO와 메시지 파싱을 담당하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- ROS context 생성/해제
- subscriber/publisher 구성
- tag/wind/IMU/contact 메시지 파싱
- callback cache 및 receive fallback 처리

## 주요 파일

- `autosimCreateRosContext.m`
- `autosimReleaseRosContext.m`
- `autosimTryReceive.m`
- `autosimParseTag.m`
- `autosimParseWindConditionMsg.m`
- `autosimParseImuMetrics.m`
- `autosimParseContactForces.m`
- `autosimSendToFleet.m`

## 운영 포인트

- 파싱 실패는 NaN-safe 경로로 처리하여 루프 중단을 피합니다.
- tag state cache(`autosimTagStateCallback.m`)를 사용해 순간 누락을 완화합니다.
- wind 벡터 성분은 ontology 모듈로 전달되어 후속 위험도 계산에 사용됩니다.

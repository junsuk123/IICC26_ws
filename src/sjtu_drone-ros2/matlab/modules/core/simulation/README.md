# Simulation Modules

Gazebo/ROS 시나리오 실행과 단계별 제어 루프를 담당하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- launch/reset/takeoff/landing 실행
- 시나리오별 wind command 생성
- 태그 추종 제어와 touchdown 통계 계산
- 최종 라벨 요약

## 주요 파일

- `autosimRunScenario.m`
- `autosimStartLaunch.m`
- `autosimResetSimulationForScenario.m`
- `autosimSoftReset.m`
- `autosimComputeWindCommand.m`
- `autosimComputeWindAcceleration.m`
- `autosimComputeTagTrackingCommand.m`
- `autosimSummarizeAndLabel.m`

## 운영 포인트

- 시나리오 수집은 드론 기준 120초 상한을 따릅니다.
- reset 실패 시 fallback 경로가 실행됩니다.
- wind 벡터 성분과 크기를 함께 유지해 후속 ontology/learning 모듈로 전달합니다.

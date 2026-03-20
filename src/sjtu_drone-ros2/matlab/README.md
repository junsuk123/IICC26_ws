# MATLAB AutoSim Guide

이 폴더는 IICC26 드론 착륙 연구의 MATLAB 실험 파이프라인을 담당한다. 기본 진입점은 `AutoSimMain.m`이며, 내부적으로 `AutoSim.m`을 실행한다.

## 실행 목적

AutoSim은 다음 과정을 자동화한다.

- ROS2/Gazebo 실행/종료 관리
- 시나리오별 바람 외란 주입
- 센서 및 AprilTag 기반 안정성 특성 추출
- 온톨로지+AI 융합 판단(`AttemptLanding`/`HoldLanding`)
- 데이터셋 누적 및 모델 재학습
- 검증, 요약 테이블/플롯 생성

## 실행 방법

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

```matlab
AutoSimMain
```

호환 경로:

```matlab
run('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/AutoSim.m')
```

## 분석 구간 정의

유효 분석 구간:

- 시작: 목표점 도달 후 `xy_hold` 진입
- 종료: `landing_track` 이후 착륙 hold 조건 충족

제외 구간:

- 이륙 전 준비
- 목표점 도달 전 이동/상승
- 착륙 이후 관측 tail 구간

## 주요 토픽

입력:

- `/drone/gt_pose`
- `/drone/gt_vel`
- `/drone/state`
- `/wind_condition`
- `/landing_tag_state`

출력:

- `/wind_command`
- `/drone/takeoff`
- `/drone/cmd_vel`

## 판단 파이프라인

1. ROS 센서 수집
2. AprilTag 기반 시각 안정성 계산
3. 바람/자세/속도 특성 생성
4. 온톨로지 상태 추론
5. 모델 입력 벡터 구성
6. 의미론 점수와 모델 확률 융합
7. 정책 판단(`pred_decision`) 산출
8. 결과 라벨링 및 학습/검증 데이터 반영

## 정책 판단 vs 실제 실행

- `pred_decision`: 정책이 원래 내린 판단(모델 성능 해석용)
- `executed_action`: 실제 실행 액션(개입/타임아웃 반영 가능)
- `action_source`: 액션 생성 경로(model/semantic/fallback/timeout 등)

논문용 method 비교는 현재 `AutoSimPaperPlots.m` 기준으로 `Ontology+AI (policy)`와 `Threshold baseline` 중심으로 정리한다.

## 핵심 스위치

- `cfg.modules.use_wind_engine`
- `cfg.modules.use_ai_engine`
- `cfg.modules.use_learning_engine`
- `cfg.modules.use_ontology_engine`

파이프라인 모드:

- `joint` (기본): 학습+검증 동시
- `train_only`: 학습 전용
- `validate_only`: 검증 전용

## 산출물 경로

- `matlab/data/<run_id>/`
- `matlab/logs/<run_id>/`
- `matlab/models/autosim_model_*.mat`
- `matlab/plots/...`

주요 CSV 필드 예시:

- `pred_decision`
- `executed_action`
- `action_source`
- `gt_safe_to_land`
- `decision_outcome`

## 운영 메모

- launch 반영 기준은 항상 `install/setup.bash`다.
- ROS 패키지 수정 후에는 해당 패키지를 재빌드해야 한다.
- AprilTag bridge 포맷: `[detected, tag_id, center_x_px, center_y_px, area_px2, margin, num_tags]`
- 상세 연동 가이드는 `ROS2_Gazebo_MATLAB_Validation_Guideline.md`를 참고한다.

# MATLAB AutoSim Guide

`matlab` 폴더는 데이터 수집, 학습, 검증, 시각화 파이프라인을 담당합니다.

마지막 업데이트: 2026-03-30

## 주요 진입점

- `AutoSimMain.m`: 통합 파이프라인(수집 → 학습 → 검증 → 플롯)
- `AutoSimCollect.m`: 수집 전용 실행
- `AutoSimTrain.m`: FinalDataset 기반 학습
- `AutoSimValidation.m`: holdout 검증
- `AutoSimPaperPlots.m`: 결과 시각화

## 핵심 동작

- `AutoSimMain` 기본 수집 설정
- `scenario_count=5000`, `drone_count=5`
- `independent_per_drone=true` (멀티 워커 독립 수집)
- `domain_base=60`
- `launch_use_gui=false`, `launch_use_rviz=true`
- 안전 정리 옵션: 시작/에러/종료 시 프로세스 cleanup

## 실행

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

## 병렬 워커 실행

주요 스크립트:

- `scripts/run_autosim_parallel.sh`
- `scripts/stop_autosim_parallel.sh`
- `scripts/merge_autosim_results.py`
- `scripts/monitor_autosim_parallel.m`
- `scripts/run_autosim_domain_bridge.sh`
- `scripts/stop_autosim_domain_bridge.sh`

실행:

```bash
cd /home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2
matlab/scripts/run_autosim_parallel.sh auto
```

중지:

```bash
matlab/scripts/stop_autosim_parallel.sh
```

## 병렬 모니터링

```matlab
monitor_autosim_parallel('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/parallel_runs/<session_root>', 2.0)
```

관찰용 RViz를 하나만 띄우고 싶으면 도메인 브리지를 함께 실행하세요.

```bash
OBSERVE_DOMAIN=90 matlab/scripts/run_autosim_domain_bridge.sh matlab/parallel_runs/<session_root>
```

## 병렬 결과 병합

```bash
python3 matlab/scripts/merge_autosim_results.py /home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/parallel_runs/<session_root>
```

병합 결과:

- `merged/autosim_dataset_merged.csv`
- `merged/autosim_trace_merged.csv`
- `merged/autosim_learning_merged.csv`

## 데이터/모델 산출물

- 데이터 루트: `matlab/data`
- 모델 루트: `matlab/models`
- 병렬 실행 루트: `matlab/parallel_runs/<session_root>`

## 모듈 구조

상세 모듈 설명: `modules/core/README.md`

- `modules/core/orchestration`
- `modules/core/simulation`
- `modules/core/ros_io`
- `modules/core/ontology`
- `modules/core/decision_making`
- `modules/core/learning`
- `modules/core/visualization`
- `modules/core/utils`

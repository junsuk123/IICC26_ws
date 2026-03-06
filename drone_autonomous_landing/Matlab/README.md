# Matlab 시뮬레이션 및 모델

- `simulation_proposed.m`, `simulation_proposed_withSensor.m`, `simulation_baseline.m` 등: 자율 착륙 시뮬레이션 코드
- `models/`: TD3 등 강화학습 기반 드론 에이전트 모델
- `episodes/`: 실험 결과 및 평가 데이터

## 실행/재현 팁

- Matlab 스크립트는 로컬 Matlab 환경에서 실행하세요. 예: `simulation_proposed.m`을 열고 Run 버튼으로 실행하거나 스크립트 창에서 `run('simulation_proposed.m')`을 사용합니다.
- 실험 모델(`models/`)은 Matlab 버전에 따라 호환성 차이가 있을 수 있으니 Matlab R2020b 이상을 권장합니다.

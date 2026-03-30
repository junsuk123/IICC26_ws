# Wind Tuner

`wind_tuner.py`는 wind plugin 파라미터를 스윕하고 `/wind_condition`을 기록하는 도구입니다.

마지막 업데이트: 2026-03-30

## 준비

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

## 실행 예시

```bash
python3 src/sjtu_drone-ros2/sjtu_drone_description/scripts/wind_tuner.py \
  --world src/sjtu_drone-ros2/sjtu_drone_description/worlds/playground.world \
  --area 0.1 0.2 0.5 \
  --coeff 0.5 1.0 2.0 \
  --speed 2.0 5.0 \
  --dir 0 90 180 \
  --duration 15 \
  --publish_rate_hz 10.0 \
  --out /tmp/wind_tuning
```

## 출력

- 파라미터 조합별 결과 폴더
- `/wind_condition` 시계열
- 실행 로그

## 참고

- 템플릿 world에 `wind_plugin`이 이미 있으면 중복 삽입을 피하도록 확인하세요.
- AutoSim 연계 시 `/wind_condition`과 `/landing_tag_state`를 함께 관찰하는 것을 권장합니다.

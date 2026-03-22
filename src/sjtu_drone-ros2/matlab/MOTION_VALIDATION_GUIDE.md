# 4대 드론 움직임 검증 매뉴얼

## 개요
이 검증은 다음 3가지를 정량적으로 측정합니다:
1. **cmd_vel 로깅** - 각 드론의 속도 명령 추출
2. **gt_pose 분석** - 5초 윈도우로 실제 위치 변화(dxy) 계산
3. **최종 판정** - "진짜 1대만 이동"인지, "4대 모두 이동하지만 크기 다름"인지 확정

---

## 📌 실행 절차

### Step 1: 터미널 준비 (4개)
각 터미널을 다른 탭에서 열어둡니다.

---

### Step 2: 환경 설정
```bash
cd /home/j/INCSL/IICC26_ws
source install/setup.bash
```

---

### Step 3: 3개 스크립트 실행 (동시에)

#### 터미널 1: cmd_vel 로깅 시작
```bash
python3 src/sjtu_drone-ros2/matlab/cmd_vel_extractor.py
```
**출력:**
```
[INFO] cmd_vel Extractor started
[INFO] Output file: /home/j/.ros/cmd_vel_logs/cmd_vel_log_20260322_034500.csv
[INFO] Subscribed to /drone_w01/cmd_vel
[INFO] Subscribed to /drone_w02/cmd_vel
[INFO] Subscribed to /drone_w03/cmd_vel
[INFO] Subscribed to /drone_w04/cmd_vel
```

#### 터미널 2: gt_pose 분석 시작
```bash
python3 src/sjtu_drone-ros2/matlab/gt_pose_analyzer.py
```
**출력:**
```
[INFO] gt_pose Analyzer started (window_size=5.0s)
[INFO] Output file: /home/j/.ros/gt_pose_logs/gt_pose_dxy_log_20260322_034500.csv
[INFO] Subscribed to /drone_w01/ground_truth/state
[INFO] Subscribed to /drone_w02/ground_truth/state
...
```

#### 터미널 3: AutoSim 실행
```bash
cd src/sjtu_drone-ros2/matlab
matlab -batch "AutoSimMain"
```
또는 MATLAB GUI에서 실행.

#### 터미널 4: 로그 모니터링 (선택사항)
```bash
watch -n 1 "ls -lh ~/.ros/cmd_vel_logs/ && echo '---' && ls -lh ~/.ros/gt_pose_logs/"
```

---

### Step 4: 시뮬레이션 완료 후, 스크립트 종료

각 터미널에서 `Ctrl+C` 를 눌러 종료합니다:
- 터미널 1 (cmd_vel): `Ctrl+C`
- 터미널 2 (gt_pose): `Ctrl+C`
- 터미널 3 (AutoSim): `Ctrl+C` 또는 MATLAB 종료

---

### Step 5: 최종 리포트 생성
```bash
python3 src/sjtu_drone-ros2/matlab/motion_validation_report.py
```

**출력 예시:**
```
================================================================================
  4대 드론 움직임 검증 리포트
================================================================================

1️⃣  cmd_vel 명령 분석

  [drone_w01]
    총 명령: 1250
    비영 vx: 450 | 비영 vy: 380 | 비영 vz: 150
    평균: vx=+0.032, vy=+0.028, vz=-0.015
    최대: vx=+1.200, vy=+0.800, vz=+0.500

  [drone_w02]
    총 명령: 0
    ...

2️⃣  gt_pose 위치 변화 분석 (5초 윈도우)

  [drone_w01]
    관측: 1250 | 이동한 관측: 890
    이동률: 71.2%
    5초 평균 dxy: 0.1250 m
    5초 최대 dxy: 0.8900 m
    총 이동거리: 156.000 m
    최종 위치: (10.20, 15.50, 0.50)

  [drone_w02]
    관측: 1250 | 이동한 관측: 0
    이동률: 0.0%
    ...

🎯 최종 판정
─────────────────────────────────────────────────────────────────────────────

  이동 드론 목록:
    [drone_w01] 이동거리=156.000 m

  결론: ⚠️  진짜 1대만 이동: [drone_w01] (이동거리=156.000m)

📁 리포트 저장: /home/j/.ros/motion_validation_report.txt
```

---

## 📊 로그 파일 위치

### 로깅 데이터
```
~/.ros/cmd_vel_logs/cmd_vel_log_YYYYMMDD_HHMMSS.csv
~/.ros/gt_pose_logs/gt_pose_dxy_log_YYYYMMDD_HHMMSS.csv
~/.ros/motion_validation_report.txt
```

### CSV 포맷

#### cmd_vel_log_*.csv
```csv
timestamp_ns,drone_name,vx,vy,vz,angular_z,time_sec
1773994541123456789,drone_w01,0.1,0.05,0.0,0.0,10.5
1773994541234567890,drone_w01,0.15,0.05,0.0,0.0,10.6
1773994541345678901,drone_w02,0.0,0.0,0.0,0.0,10.7
...
```

#### gt_pose_dxy_log_*.csv
```csv
timestamp_ns,drone_name,x,y,z,dx_5sec,dy_5sec,dxy_magnitude,time_sec
1773994541123456789,drone_w01,5.0,3.5,1.0,0.05,0.02,0.054,10.5
1773994541234567890,drone_w01,5.1,3.52,1.0,0.1,0.04,0.108,10.6
1773994541345678901,drone_w02,-0.1,0.0,1.0,0.0,0.0,0.0,10.7
...
```

---

## 🔍 판정 기준

### 결론 분류

| 상황 | 판정 |
|:---:|:---|
| 모든 드론 이동거리 < 0.05m | 모든 드론이 내내 정지 상태 ✅ |
| 정확히 1개 드론만 이동거리 > 0.05m | 진짜 1대만 이동 ⚠️ |
| 2~3개 드론 이동 | 부분 이동 (원인 레 분석 필요) ❌ |
| 4개 드론 모두 이동 | 4대 모두 이동 |
| → 최대/최소 비율 > 2.0x | 크기 차이 큼 ❌ |
| → 최대/최소 비율 ≤ 2.0x | 유사한 크기 ✓ |

---

## 🛠️ 문제 해결

### 1. "Subscribed to" 메시지가 나오지 않음
- **원인**: ROS2 토픽이 발행되지 않음 또는 namespace 다름
- **해결**:
  ```bash
  ros2 topic list | grep cmd_vel
  ros2 topic list | grep ground_truth
  ```

### 2. CSV 파일이 비어있음
- **원인**: 콜백이 호출되지 않음 (토픽 없음)
- **해결**: AutoSim/Gazebo가 실제로 시작되었는지 확인

### 3. "File not found" 오류
- **원인**: cmd_vel 또는 gt_pose 로그가 생성되지 않음
- **해결**: Step 1-2의 스크립트가 정상 실행되었는지 확인

---

## 📋 체크리스트

- [ ] 3개 스크립트를 모두 동시에 시작
- [ ] AutoSim이 완전히 실행 (로그 메시지 확인)
- [ ] 최소 2~3시나리오 이상 완료
- [ ] Ctrl+C로 모든 스크립트 종료
- [ ] `motion_validation_report.py` 실행
- [ ] 최종 판정 결과 확인 및 기록

---

## 📞 문의

데이터 분석 관련 문의: 로그 파일 위치와 CSV 샘플과 함께 제공.

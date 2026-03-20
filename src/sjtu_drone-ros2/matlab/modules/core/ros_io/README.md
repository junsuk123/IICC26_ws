# ROS I/O Modules

ROS2 토픽/서비스 입출력과 메시지 파싱을 담당한다.

## 기능 설명

- ROS context 생성/해제
- subscriber/publisher 구성
- AprilTag, wind, IMU, contact 메시지 파싱
- callback cache 및 receive fallback 관리

## 이론 포인트

- 실험 신뢰성은 입력 지연/누락 처리에 크게 좌우됨
- 파싱 실패를 NaN-safe 흐름으로 흡수해 루프 중단을 방지

입력 신선도는 수신 시간 기반으로 본다.

$$
\Delta t_{rx}=t_{now}-t_{last\_rx}
$$

태그 중심 오차는 정규화 좌표에서 계산한다.

$$
e_{tag}=\sqrt{u^2+v^2}
$$

NaN-safe 처리는 기본값 치환 형태로 적용한다.

$$
x'=
\begin{cases}
x, & \mathrm{isfinite}(x) \\
x_{fallback}, & \text{otherwise}
\end{cases}
$$

## 핵심 변수/용어 표

| 항목 | 의미 | 단위/범위 | 비고 |
|---|---|---|---|
| subPose/subVel/subState | 핵심 subscriber | ROS 핸들 | 위치/속도/상태 |
| subTag | 태그 상태 subscriber | ROS 핸들 | AprilTag bridge 입력 |
| subWind | 풍 상태 subscriber | ROS 핸들 | wind_condition 입력 |
| pubCmd/pubTakeoff/pubLand | 제어 publisher | ROS 핸들 | cmd_vel/takeoff/land |
| recvTimeoutSec | receive 타임아웃 | sec | polling 안전성 |
| tagErr | 태그 중심 오차 | 정규화 값 | sqrt(u^2+v^2) |
| rx_count | 콜백 수신 카운트 | 정수 | callback 우선 모드 진단 |
| msg_unsupported | 메시지 지원 부족 플래그 | bool | MATLAB message generation 필요 |

## 대표 파일

- `autosimCreateRosContext.m`
- `autosimTryReceive.m`
- `autosimParseTag.m`
- `autosimParseWindConditionMsg.m`
- `autosimParseContactForces.m`

## 확장 가이드

- 새로운 센서 토픽 추가 시 parser + context + trace 반영을 함께 적용한다.

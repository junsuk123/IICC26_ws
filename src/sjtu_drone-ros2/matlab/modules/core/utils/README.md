# Utility Modules

다른 도메인 모듈에서 공통으로 사용하는 보조 함수 모음이다.

## 최근 업데이트 (2026-03-23)

유틸 계층의 적용 기준을 다음처럼 명확히 했다.

- 바람 벡터는 성분 유지 후 크기 계산을 병행한다.
- 타임아웃 상한은 clamp 기반으로 안전하게 적용한다.

$$
\|\mathbf{v}\|_2=\sqrt{v_x^2+v_y^2},\quad
\mathrm{compMax}(\mathbf{v})=\max(|v_x|,|v_y|)
$$

$$
t' = \min(t,\ t_{max}),\quad t_{max}=120\,\text{s}
$$

## 기능 설명

- 수치 처리: clamp, nan-safe 통계, 정규화
- 시스템 처리: process/lock 관리, 문자열/시간 유틸
- 물리/좌표 보조: quaternion 변환, wind vector 변환

## 이론 포인트

- nan-safe 유틸은 센서 결측 상황에서 실험 중단을 방지
- lock/process 유틸은 반복 실험의 안정성 보장

기본 수치 유틸은 다음 형태를 따른다.

$$
\mathrm{clamp}(x,l,u)=\min(\max(x,l),u)
$$

$$
\mathrm{nanmean}(\mathbf{x})=\frac{1}{|\mathcal{I}|}\sum_{i\in\mathcal{I}}x_i,
\quad
\mathcal{I}=\{i\mid x_i\in\mathbb{R},\;\mathrm{isfinite}(x_i)\}
$$

풍속 벡터 크기 계산은 다음과 같다.

$$
|\mathbf{v}|=\sqrt{v_x^2+v_y^2}
$$

## 핵심 변수/용어 표

| 항목 | 의미 | 단위/범위 | 비고 |
|---|---|---|---|
| clamp(x,l,u) | 범위 제한 함수 | 실수 -> 실수 | 수치 폭주 방지 |
| nanmean/nanstd | 결측 무시 통계 | 벡터 -> 실수 | 센서 결측 내성 |
| safe divide | 0분모 보호 나눗셈 | 실수 -> 실수/NaN | 지표 계산 안전화 |
| lockPath | 실행 락 경로 | path | 중복 인스턴스 방지 |
| pid/start_ticks | 프로세스 식별자 | 정수 | stale lock 판별 |
| q=(w,x,y,z) | quaternion | 무차원 | 자세 계산 입력 |
| roll,pitch,yaw | 오일러 각 | rad 또는 deg | 제어/판정 사용 |
| wind vector | 풍속 벡터 | (v_x,v_y) | 방향성 유지 핵심 |

## 대표 파일

- `autosimClamp.m`, `autosimNanMean.m`, `autosimSafeDivide.m`
- `autosimAcquireLock.m`, `autosimCleanupProcesses.m`
- `autosimQuat2Eul.m`, `autosimWindVectorFromSpeedDir.m`

## 확장 가이드

- 특정 도메인에 종속된 로직은 이 폴더에 두지 않고 해당 도메인 폴더로 이동한다.

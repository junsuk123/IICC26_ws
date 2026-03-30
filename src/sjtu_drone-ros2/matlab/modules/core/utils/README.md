# Utility Modules

AutoSim 전역 공통 유틸 함수 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- 수치 유틸: clamp, nan-safe 통계, 정규화
- 프로세스 유틸: 락/프로세스 탐지/정리
- 변환 유틸: quaternion/euler, wind vector 변환
- 파서 유틸: yaml/xml 숫자값 읽기

## 대표 파일

- `autosimClamp.m`, `autosimNanMean.m`, `autosimNanStd.m`, `autosimSafeDivide.m`
- `autosimAcquireLock.m`, `autosimReleaseLock.m`, `autosimCleanupProcesses.m`
- `autosimGetActiveProcessSnapshot.m`, `autosimKillActiveProcessTrees.m`
- `autosimQuat2Eul.m`, `autosimWindVectorFromSpeedDir.m`, `autosimWindVectorMag.m`
- `autosimReadYamlScalar.m`, `autosimReadXmlTagScalar.m`

## 운영 포인트

- 실험 중단 없이 진행되도록 NaN/Inf 방어 로직을 우선 적용합니다.
- 병렬 실행 안정성을 위해 락/프로세스 스냅샷 기반 정리를 사용합니다.

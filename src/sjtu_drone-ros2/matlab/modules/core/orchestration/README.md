# Orchestration Modules

실행 흐름과 설정 병합, 종료/체크포인트를 담당하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- 기본 설정 생성 및 외부/런타임 override 반영
- 단일/병렬 실행 orchestration
- 결과 finalize, 요약 테이블, 체크포인트 저장

## 주요 파일

- `autosimDefaultConfig.m`
- `autosimApplyExternalOverride.m`
- `autosimApplyRuntimeOverrides.m`
- `autosimMainOrchestrate.m`
- `autosimSingleWorldPipeline.m`
- `autosimSaveCheckpoint.m`
- `autosimFinalize.m`

## 운영 원칙

- 수집 시간 상한은 120초 기준으로 적용됩니다.
- runtime override는 환경변수 우선순위를 따릅니다.
- 병렬 실행 시 워커별 경로와 domain이 분리되어야 합니다.

## 유지보수 포인트

- 새 환경변수 추가 시 `autosimApplyRuntimeOverrides.m`와 호출 스크립트(`matlab/scripts/*.sh`)를 함께 갱신합니다.
- 종료/정리 정책 변경 시 `autosimFinalize.m`와 cleanup 유틸(`utils`)을 함께 검토합니다.

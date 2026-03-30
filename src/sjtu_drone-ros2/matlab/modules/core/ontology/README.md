# Ontology Modules

센서 상태를 의미론 상태로 변환하고 위험/안전 인코딩을 생성하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- wind/drone/vision 상태 구성
- 규칙 기반 위험도 및 정렬/안정 점수 계산
- decision/learning 입력용 `*_enc` 피처 생성

## 주요 파일

- `autosimBuildOntologyState.m`
- `autosimBuildTemporalSemanticState.m`
- `autosimOntologyReasoning.m`
- `autosimBuildSemanticFeatures.m`
- `autosimResolveWindVectorFeatures.m`
- `autosimLinearSigmoid.m`

## 핵심 식

$$
\mathbf{v}_w=[v_x,v_y]^\top,\quad \mathbf{a}_w=[a_x,a_y]^\top
$$

$$
r_{body}=\min\left(1,\frac{\sqrt{F_{wx}^2+F_{wy}^2}}{F_{cap}}\right),\quad
r_{gust}=\min\left(1,\frac{\sqrt{a_x^2+a_y^2}}{a_{thr}}\right)
$$

$$
s_{sem}=w_w(1-r_w)+w_v c_v+w_a s_a
$$

## 유지보수 포인트

- 임계치 조정 시 `autosimOntologyReasoning.m`과 downstream feature 소비 모듈을 함께 검토합니다.
- 바람 관련 필드 변경 시 `autosimResolveWindVectorFeatures.m`와 파서(`ros_io`)를 함께 수정합니다.

# Ontology Modules

온톨로지 상태 생성과 의미론 기반 위험/안전 추론을 담당한다.

## 최근 업데이트 (2026-03-23)

바람 위험도 계산이 body-frame 축별 항력 하중 + gust 가속도 결합 방식으로 갱신되었다.

$$
\mathbf{v}_w=[v_x,v_y]^\top,\ \mathbf{a}_w=[a_x,a_y]^\top
$$

$$
F_{wx}=\frac{1}{2}\rho c_x S_x\,v_x|v_x|,\quad
F_{wy}=\frac{1}{2}\rho c_y S_y\,v_y|v_y|
$$

$$
F_{body}=\sqrt{F_{wx}^2+F_{wy}^2},\quad
r_{body}=\min\left(1,\frac{F_{body}}{F_{cap}}\right)
$$

$$
c_{tilt}=\cos(|roll|)\cos(|pitch|),\quad
T_{req}=\frac{mg}{\max(c_{tilt},c_{min})},\quad
F_{cap}=\max(T_{max}-T_{req},F_{min})
$$

$$
a_w=\sqrt{a_x^2+a_y^2},\quad
r_{gust}=\min\left(1,\frac{a_w}{a_{thr}}\right)
$$

$$
r_{wind}=\min\left(1,w_{body}r_{body}+w_{gust}r_{gust}\right)
$$

semantic 출력에도 `wind_velocity_x/y`, `wind_acceleration_x/y`를 유지해 차원 누락을 방지한다.

## 기능 설명

- Wind/Drone/Vision 관측을 객체 상태로 구조화
- 정렬/시각 신뢰/자세 안정을 점수화
- 규칙 기반/경량 AI 결합으로 semantic encoding 산출

## 이론 포인트

- 위험도 결합: 항력 하중비 + 변동성/방향 변화량
- 시각 안정도: 태그 검출 연속성 + 중심 오차 + jitter
- 최종 의미 점수는 decision feature의 `*_enc`로 전달

동체 외란 + gust 결합 위험도 예시는 다음과 같다.

$$
F_{wx}=\frac{1}{2}\rho c_x S_x\,v_x|v_x|,\quad
F_{wy}=\frac{1}{2}\rho c_y S_y\,v_y|v_y|
$$

$$
r_{body}=\min\left(1,\frac{\sqrt{F_{wx}^2+F_{wy}^2}}{F_{cap}}\right),\quad
r_{gust}=\min\left(1,\frac{\sqrt{a_x^2+a_y^2}}{a_{thr}}\right)
$$

$$
r_w = \min\left(1,w_{body}r_{body}+w_{gust}r_{gust}\right)
$$

여기서 $F_{cap}$은 현재 자세 기울기(roll/pitch)에 따라 감소하는 유효 추력 여유를 사용한다.

시각 정렬 신뢰도는 중심 오차 정규화로 계산한다.

$$
c_v = \min\left(1,\max\left(0,1-\frac{e_{tag}}{e_{thr}}\right)\right)
$$

자세 안정도는 roll/pitch 크기에 대한 지수 감쇠로 정의한다.

$$
s_a = \exp\left(-\beta_r\frac{|roll|}{roll_{thr}}-\beta_p\frac{|pitch|}{pitch_{thr}}\right)
$$

최종 의미 점수는 가중 결합 형태다.

$$
s_{sem}=w_w(1-r_w)+w_v c_v+w_a s_a
$$

## Sigmoid 인코딩: 특징 정규화

온톨로지 모듈은 위의 규칙 기반 점수들($r_w, c_v, s_a$)을 **Sigmoid 인코딩**을 통해 확률 범위 [0,1]로 변환한다. 이는 학습 모듈의 의사결정 모델에 입력되기 전 단계이다.

### 아키텍처

$$
\text{Raw Features} \xrightarrow[\text{규칙식}]{r_w, c_v, s_a} \text{점수 (0~∞)} \xrightarrow[\text{Sigmoid}]{\sigma} \text{인코딩 (0~1)} \xrightarrow[\text{GaussianNB}]{\text{Learning}} \text{판정}
$$

### Sigmoid 변환 함수

각 의미 특징을 독립적으로 sigmoid 활성화한다.

$$
\text{Enc}_{WindRisk}= \sigma(w_w^T[\|\mathbf{v}_w\|, \|\mathbf{a}_w\|, \ldots] + b_w) \in [0,1]
$$

$$
\text{Enc}_{Alignment} = \sigma(w_a^T[e_{tag}, \text{trend}, \ldots] + b_a) \in [0,1]
$$

$$
\text{Enc}_{Visual} = \sigma(w_v^T[\text{stability}, \text{jitter}, \ldots] + b_v) \in [0,1]
$$

여기서 $\sigma(z) = \frac{1}{1 + e^{-z}}$이다.

### 왜 Sigmoid를 사용하나?

| 이유 | 상세 |
|------|------|
| **확률 해석** | [0,1] 범위로 정규화되어 물리량이 아닌 "신뢰도" 또는 "위험도"로 해석 가능 |
| **비선형 분리** | 선형 결합 후 비선형 활성화로 복잡한 특징 공간 매핑 |
| **극도 경량** | exp 연산만 필요, 온콜로지 엔진에서 실시간 계산 가능 |
| **미분 가능** | $\frac{d\sigma}{dz}=\sigma(z)(1-\sigma(z))$ — 향후 학습 기반 최적화 확장 가능 |
| **Learning 예비** | 변환된 특징 공간에서 GaussianNB가 클래스 경계를 더 잘 학습 |

### 구현

[autosimLinearSigmoid.m](autosimLinearSigmoid.m)에서 구현되며, 안전 핸들링(NaN/inf 방지)을 포함한다.

```matlab
function y = autosimLinearSigmoid(x, w, b, fallback)
    z = sum(x .* w) + b;
    y = 1.0 / (1.0 + exp(-z));
end
```

## 수식 변수 정의 (상세)

아래 변수 정의는 본 문서의 풍하중/자세/Sigmoid 수식 전체에 공통으로 적용한다.

### 1) 바람 벡터와 축별 항력 식 변수

- $\mathbf{v}_w=[v_x,v_y]^\top$: 수평면 바람 속도 벡터 (m/s)
- $v_x, v_y$: 바람 속도의 x/y 성분 (m/s)
- $F_{wx}, F_{wy}$: 동체 x/y축 항력 성분 (N)
- $F_{body}=\sqrt{F_{wx}^2+F_{wy}^2}$: 등가 동체 풍하중 (N)
- $\rho$: 공기 밀도 (kg/m^3)
- $c_x, c_y$: 축별 항력 계수 (무차원)
- $S_x, S_y$: 축별 기준 면적 (m^2)

### 2) 기울기 보정 추력 여유 변수

- $roll, pitch$: 드론 자세 각도 (rad, 절대값 사용)
- $c_{tilt}=\cos(|roll|)\cos(|pitch|)$: 수직 성분 보정 계수 (무차원)
- $c_{min}$: 극단 자세에서 분모 발산 방지를 위한 최소 코사인 클램프 (무차원)
- $m$: 드론 질량 (kg)
- $g$: 중력가속도 (m/s^2)
- $T_{req}$: 현재 기울기에서 고도 유지를 위해 필요한 총 추력 (N)
- $T_{max}$: 기체 총 최대 추력 (N)
- $F_{min}$: 최소 추력 여유 하한 (N)
- $F_{cap}$: 횡풍 대응에 사용 가능한 유효 추력 여유(항력 허용치) (N)

### 3) 풍위험 인코딩 변수

- $r_{body}=\min(1,F_{body}/F_{cap})$: 동체 외란 기반 위험도
- $a_w=\sqrt{a_x^2+a_y^2}$: 가속도 크기 (m/s$^2$)
- $r_{gust}=\min(1,a_w/a_{thr})$: gust 기반 위험도
- $r_w=\min(1,w_{body}r_{body}+w_{gust}r_{gust})$: 최종 풍위험 인코딩
- $\min(1,\cdot)$: 위험도 상한 1로 포화

### 4) 시각/자세 변수

- $c_v$: 시각 정렬 신뢰도 (0~1)
- $e_{tag}$: 태그 중심 정렬 오차 (정규화 값)
- $e_{thr}$: 허용 태그 오차 임계값
- $s_a$: 자세 안정도 인코딩 (0~1)
- $\beta_r, \beta_p$: roll/pitch 감쇠 계수 (무차원)
- $roll_{thr}, pitch_{thr}$: 자세 허용 임계각 (rad)
- $\mathrm{clamp}(x,0,1)$: 값을 0~1 범위로 제한하는 연산

### 5) 최종 의미 점수 결합 변수

- $s_{sem}$: 온톨로지 기반 최종 의미 안전 점수 (0~1)
- $w_w, w_v, w_a$: 풍위험/시각정렬/자세안정 가중치
- 가중치 합 제약: $w_w+w_v+w_a=1$

## 핵심 변수/용어 표

| 항목 | 의미 | 단위/범위 | 비고 |
|---|---|---|---|
| r_body | 동체 외란 위험도 | 0~1 | 축별 항력 기반 |
| r_gust | gust 위험도 | 0~1 | 가속도 기반 |
| r_w | 최종 풍 위험도 인코딩 | 0~1 | 높을수록 위험 |
| c_v | 시각 정렬 신뢰도 | 0~1 | 높을수록 안정 |
| s_a | 자세 안정도 | 0~1 | roll/pitch 기반 |
| wind_risk_enc | 풍 위험 feature | 0~1 | decision 입력 |
| alignment_enc | 정렬 feature | 0~1 | decision 입력 |
| visual_enc | 시각 안정 feature | 0~1 | decision 입력 |

## 대표 파일

- `autosimBuildOntologyState.m`
- `autosimBuildTemporalSemanticState.m`
- `autosimOntologyReasoning.m`
- `autosimBuildSemanticFeatures.m`

## 확장 가이드

- 규칙 임계치와 개념 정의 변경은 이 폴더를 기준으로 수행한다.

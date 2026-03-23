# Learning Modules

모델 생명주기(로드/검증/학습/예측)를 담당한다.

## 최근 업데이트 (2026-03-23)

학습 모듈 인터페이스/스키마는 유지하되, 입력으로 들어오는 온톨로지 파생 특성의 물리 차원 보존이 강화되었다.

특히 바람 관련 의미 인코딩은 벡터 성분 기반 위험도에서 계산되어, 클래스 분리에 필요한 방향성 정보를 더 잘 반영한다.

요약식:

$$
x_{wind\_sem}=f(\|\mathbf{v}_w\|_2,\max(|v_x|,|v_y|),\|\mathbf{a}_w\|_2,\max(|a_x|,|a_y|))
$$

## 기능 설명

- 모델 스키마 호환성 검증
- GaussianNB 학습 및 추론
- 데이터 누적 기반 incremental update

## 이론 포인트

- 현재 기본 모델은 Gaussian Naive Bayes
- feature schema 불일치 시 안전하게 placeholder 모델로 폴백
- class imbalance를 고려한 업데이트 조건 포함

클래스별 조건부 분포는 가우시안으로 둔다.

$$
p(x\mid y=c)=\prod_{j=1}^{d}\mathcal{N}(x_j;\mu_{c,j},\sigma_{c,j}^2)
$$

예측은 사후확률 최대 클래스를 선택한다.

$$
\hat{y}=\arg\max_c\;\log p(y=c)+\sum_{j=1}^{d}\log \mathcal{N}(x_j;\mu_{c,j},\sigma_{c,j}^2)
$$

불균형 완화를 위해 prior를 균등 prior와 혼합한다.

$$
\pi'_c=(1-\lambda)\pi_c+\lambda\frac{1}{K}
$$

## 핵심 변수/용어 표

| 항목 | 의미 | 단위/범위 | 비고 |
|---|---|---|---|
| X | 입력 feature 행렬 | N x d | d=feature 수 |
| y | 클래스 라벨 | AttemptLanding/HoldLanding | 학습 타깃 |
| mu_c,j | 클래스별 평균 | 실수 | GaussianNB 파라미터 |
| sigma2_c,j | 클래스별 분산 | 양수 실수 | 너무 작으면 floor 적용 |
| pi_c | 클래스 prior | 0~1 | 합=1 |
| lambda | prior uniform blend | 0~1 | 불균형 완화 |
| schema_version | feature 스키마 버전 | 문자열 | 불일치 시 폴백 |
| placeholder model | 임시 모델 | struct | cold start/불일치 안전 처리 |

## 대표 파일

- `autosimLoadOrInitModel.m`
- `autosimTrainGaussianNB.m`
- `autosimPredictGaussianNB.m`
- `autosimIncrementalTrainAndSave.m`
- `autosimModelFeatureSchemaMatches.m`

## 확장 가이드

- 다른 분류기 추가 시 `predict/train` 인터페이스를 유지해 교체 가능하게 구현한다.

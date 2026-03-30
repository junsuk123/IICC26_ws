# Learning Modules

모델 로드/학습/검증/예측을 담당하는 모듈입니다.

마지막 업데이트: 2026-03-30

## 역할

- FinalDataset 로딩 및 스키마 정합
- GaussianNB 학습/예측
- 모델 신뢰도 점검 및 placeholder 폴백
- 학습 on/off 파이프라인 제어

## 주요 파일

- `autosimLoadAllFinalDataset.m`
- `autosimTrainGaussianNB.m`
- `autosimPredictGaussianNB.m`
- `autosimIncrementalTrainAndSave.m`
- `autosimLoadOrInitModel.m`
- `autosimModelFeatureSchemaMatches.m`
- `autosimIsModelReliable.m`
- `autosimCreatePlaceholderModel.m`

## 기본 수식

$$
p(x\mid y=c)=\prod_{j=1}^{d}\mathcal{N}(x_j;\mu_{c,j},\sigma^2_{c,j})
$$

$$
\hat{y}=\arg\max_c\left(\log p(y=c)+\sum_{j=1}^{d}\log\mathcal{N}(x_j;\mu_{c,j},\sigma^2_{c,j})\right)
$$

## 유지보수 포인트

- feature 스키마 변경 시 `autosimEnsureOntologyFeatureColumns.m`와 모델 로드 검증 로직을 함께 수정합니다.
- 검증 분할 정책 변경 시 `AutoSimValidation.m`의 split 파라미터와 함께 맞춥니다.

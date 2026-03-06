# 드론 자율 착륙 프로젝트

이 폴더는 드론의 자율 착륙 관련 Matlab 시뮬레이션, 학습 모델, ROS2 패키지, URDF, 월드 파일 등을 정리한 공간입니다.

- `Matlab/` : 시뮬레이션 및 평가 코드, 학습 모델, 에피소드 결과 등
- `ros2_description/` : ROS2 패키지, launch 파일, URDF, 월드 파일 등

## 실행 가이드 (요약)

이 폴더의 핵심 개발/테스트 대상은 `drone_ws`입니다. Gazebo + ROS2 기반 시뮬레이션을 실행하려면:

1. 워크스페이스로 이동:

```
cd drone_ws
```

2. 의존성 설치 및 빌드:

```
./scripts/build.sh
```

3. 시뮬레이터 실행:

```
./scripts/launch.sh       # 개발용: 소스 모델/플러그인 사용
./scripts/launch.sh ros   # ROS2 launch 사용 (원래 런치 파일)
```

추가 설명과 자세한 실행/디버깅 팁은 `drone_ws/README.md`를 확인하세요.

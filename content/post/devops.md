---
title: "MLOps 정의 알아보기"
date: 2021-03-17T23:21:10+09:00
draft: false
summary: "MLOps에 대해 알아보기 위해 DevOps의 정의부터 시작해서 Google 에서 제시한 MLOps 와 관련된 내용에 대해서 정리하였습니다."
---

# 1. DevOps?

## 1.1. DevOps의 정의

- [위키백과](https://ko.wikipedia.org/wiki/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4) : 데브옵스(DevOps)는 소프트웨어의 개발(Development)과 운영(Operations)의 합성어로서, 소프트웨어 개발자와 정보기술 전문가 간의 소통, 협업 및 통합을 강조하는 개발 환경이나 문화를 말한다. 데브옵스는 소프트웨어 개발조직과 운영조직간의 상호 의존적 대응이며 조직이 소프트웨어 제품과 서비스를 빠른 시간에 개발 및 배포하는 것을 목적으로 한다.

- [MS Azure](https://azure.microsoft.com/ko-kr/overview/what-is-devops/) : 개발(Dev)과 운영(Ops)의 합성어인 DevOps는 고객에게 지속적으로 가치를 제공하도록 지원하는 사람, 프로세스 및 기술의 합집합입니다.

- [AWS](https://aws.amazon.com/ko/devops/what-is-devops/) : DevOps는 애플리케이션과 서비스를 빠른 속도로 제공할 수 있도록 조직의 역량을 향상시키는 문화 철학, 방식 및 도구의 조합입니다. 기존의 소프트웨어 개발 및 인프라 관리 프로세스를 사용하는 조직보다 제품을 더 빠르게 혁신하고 개선할 수 있습니다. 

## 1.2. DevOps 구성요소

1. CI(Continuous Integreation) : 항상 코드가 안정화된 상태를 유지할 수 있도록, 새로운 코드가 커밋될 때마다 자동화된 테스트가 실행되야 한다.

2. CD(Continuous Deployment or Delivery) : Production에 릴리스하기 위한 코드 변경이 자동으로 빌드, 테스트 및 준비되는 개발 방식을 의미한다. 언제나 즉시 배포할 수 있고, 표준화된 테스트 프로세스를 통과한 아티팩트를 보유하게 된다.

3. 지속적인 모니터링 : 애플리케이션을 실행하는 기본 인프라부터 소프트웨어 구성요소까지 전체 애플리케이션 스택의 성능과 상태에 대한 완전한 실시간 가시성을 갖는 것을 의미한다.

4. 코드형 인프라(Infrastructure as Code) : 버전 관리 및 지속적 통합(CI)를 통해서 인프라를 관리하는 방식. 코드를 통해 인프라가 정의되어 인프라와 서버를 표준화된 패턴을 사용하여 배포, 업데이트, 복제 등이 가능

=============

# 2. [MLOps](https://cloud.google.com/solutions/machine-learning/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning?hl=ko)?

## 2.1 MLOps Level 0

![MLOpslevel0](/images/devops/1.svg)

- 많은 팀에서 ML 연구원은 있지만, 훈련된 ML 모델을 빌드하고 배포하는 과정은 위와 같이 완전한 수동으로 이루어 집니다.

- 프로덕션 단계에서 적극적인 품질 모니터링 필요

- 프로덕션 모델을 자주 재학습 및 재배포 할 수 있어야 함

- 최신 아이디어와 기술의 발전을 적용하기 위해 새로운 구현의 시도가 필요

## 2.2 MLOps Level 1

![MLOpslevel1](/images/devops/2.svg)

- ML 파이프라인을 자동화하여 모델을 지속적으로 학습시키는 것입니다. 새 데이터를 사용하여 프로덕션 단계에서 모델을 재학습시키는 프로세스를 자동화하려면 파이프라인 트리거 및 메타데이터 관리뿐만 아니라 자동화된 데이터 및 모델 검증 단계를 파이프라인에 도입해야 합니다.

- 데이터 및 모델 검증

- 특성 저장소

- 메타데이터 관리

- ML 파이프라인 트리거

## 2.3 MLOps Level 2

![MLOpslevel2](/images/devops/3.svg)

- 소스 제어, 서비스 테스트 및 빌드, 배포 서비스, 모델 레지스트리, 특성 저장소, ML 메타데이터 저장소, ML 파이프라인 조정자

![MLOpslevel2Features](/images/devops/4.svg)

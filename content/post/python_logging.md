---
title: "Python_logging"
date: 2021-04-10T21:40:59+09:00
draft: false
summary: "Python의 logging 라이브러리에 대한 고찰"
---

# 한줄 요약

Python logger는 계층적 구조를 가지고 있는 표준 라이브러리로, Singleton pattern이 적용되어 있다.

## logging 이란?

로깅은 어떤 소프트웨어가 실행될 때 발생하는 이벤트를 추적하는 수단입니다. 소프트웨어 개발자는 코드에 로깅 호출을 추가하여 특정 이벤트가 발생했음을 나타냅니다. 이벤트는 선택적으로 가변 데이터 (즉, 이벤트 발생마다 잠재적으로 다른 데이터)를 포함할 수 있는 설명 메시지로 기술됩니다. 이벤트는 또한 개발자가 이벤트에 부여한 중요도를 가지고 있습니다; 중요도는 수준(level) 또는 심각도(severity) 라고도 부를 수 있습니다. - [파이썬 로깅 HOWTO](https://docs.python.org/ko/3/howto/logging.html#logging-basic-tutorial)

프로그램에서 발생하는 이벤트(결과 혹은 에러 메세지)를 추적하기 위해 사용하는 수단이라고 정리 할 수 있을 것 같습니다.

## logging은 왜 쓰나요?

프로그램의 문제를 추적하기 위해 가장 기본적으로는 print문을 사용하여 console창에 출력되는 내용을 보는 방법이 있습니다. 그러나 복잡한 프로그램일수록, 간단한 print문보다는 logging 라이브러리를 선호하고 권장하는데, 그 이유는 아래와 같은 logging 라이브러리의 장점 때문 입니다.

1. 출력해야되는 정보를 쉽게 생성 및 출력할 수 있다.
2. 단순 콘솔화면에 출력하는 것 뿐만 아니라, log file이나 socket등 다양한 곳에 기록할 수 있다.
3. 위험성(DEBUG, WARN 등등)에 따라, 다르게 출력할 수 있다.

## logging singleton pattern?

logging에 대해서 배우다보니, python의 logging 라이브러리는 [singleton pattern](https://ko.wikipedia.org/wiki/%EC%8B%B1%EA%B8%80%ED%84%B4_%ED%8C%A8%ED%84%B4)이라고 합니다.([링크참고](https://stackoverflow.com/a/7341564)) 그러나 실제로 logging 라이브러리를 사용하다보면, 이 설명이 매우 이해가 안 가는데, 실험을 통해 왜 python logging이 singleton pattern이 적용되어 있다고 하는지에 대해 배워보겠습니다.

### 실험1. Root Logger를 통한 싱글톤 확인

```Python Script
logger.py
import logging

def getCustomLogger():
    logger = logging.getLogger()
    formatter = logging.Formatter(
    '%(filename)s:%(lineno)s - %(name)s - %(message)s')
    
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)

    logger.addHandler(stream_handler)
    logger.setLevel(logging.DEBUG)

    return logger
```

logging 라이브러리의 getLogger를 통해 logger 인스턴스를 호출할 수 있는데, 이때 parameter를 아무것도 전달하지 않을경우, 자동적으로 root에 해당하는 logger를 반환해줍니다.
위와 같이 logger를 생성하는 코드를 만들고, 다른 모듈에서 생성된 logger의 [instance id](https://docs.python.org/ko/3/library/functions.html#id) 를 확인해보겠습니다.

```Python Script
main.py
from logger import getCustomLogger
import testA

if __name__ == '__main__':
    logger = getCustomLogger()
    logger_id = hex(id(logger))
    logger.debug(f"Initiating Logger : {logger_id}")
    testA.testA(logger)
```
```Python Script
testA.py
import logging

def testA(logger):
    logger = logging.getLogger()
    logger_id = hex(id(logger))
    logger.debug(f"testA Logger : {logger_id}")
```
```shell script
>>> python main.py
main.py:7 - root - Initiating Logger : 0x7fbac5d4e340
testA.py:6 - root - testA Logger : 0x7fbac5d4e340
```
다른 모듈에서 발생된 debug 이벤트에 대해서, 각각 알맞는 filename과 lineno를 가진 log가 동일한 logger instance id와 logger 이름을 가진 객체에서 부터 출력됨을 확인 할 수 있습니다.

### 실험 2. 각기 다른 Moudle 이름을 통한 logger 생성

위에 1까지만 보면 설명대로 logging은 싱글톤 패턴이 맞는데? 라고 하실 수 있겠지만, 실제로 프로그램을 사용하다 보면 예상치 못한 결과물이 종종 나옵니다. Root의 logger를 사용하지 않고, 각 모듈별로 logger를 설정할 경우 이런 경우가 발생합니다.

```Python Script
logger.py
import logging

def getCustomLogger(modulename):
    
    logger = logging.getLogger(modulename)
    formatter = logging.Formatter(
    '%(filename)s:%(lineno)s - %(module)s - %(message)s')
    
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)

    logger.addHandler(stream_handler)
    logger.setLevel(logging.DEBUG)

    return logger
```
```Python Script
main.py
from logger import getCustomLogger
import testA

if __name__ == '__main__':
    logger = getCustomLogger("메인모듈")
    logger_id = hex(id(logger))
    logger.debug(f"Initiating Logger : {logger_id}")
    testA.testA(logger)
```
```Python Script
testA.py
import logging

def testA(logger):
    logger = logging.getLogger("테스트A")
    logger_id = hex(id(logger))
    logger.debug(f"testA Logger : {logger_id}")
```
```shell script
>>> python main.py
main.py:7 - main - Initiating Logger : 0x7fcfa128a070
```
testA.py의 testA의 로깅이 누락되었다. Logging의 Logger는 singleton pattern이 적용되었으니, Main모듈에서 설정한 handler가 적용되서, 테스트A라는 이름의 logger를 호출해도 적용되어야 하는게 아닌가? 라는 의문이 생기지만, logging.getLogger를 통해서 테스트A라는 이름을 가진 logger를 생성할 경우, "메인모듈"에서 생성된 logger handler가 적용되지 않아 테스트A에 정상적인 로그가 발생하지 않은 것이다. 이를 확인하고 싶으면 아래와 같은 코드를 추가하여 시도해보면 된다.
```python script
testA.py
logger.warning(f"testA Logger : {logger_id}")
```
```shell script
>>> python main.py
main.py:7 - main - Initiating Logger : 0x7fea7479a070
testA Logger : 0x7fea74659160
```
다른 logger 인스턴스가 적용되어 포멧팅이 유지가 안되는 것을 알 수 있다.

### 설명. Singleton 이라매? modulename은 왜 쓰는 건데??

2번의 상황이 당연하게 느껴질 수도 있고, 복잡하게 느껴질 수도 있는데 정리해보자면 아래의 그림과 같은 상황이다.

![logging0.png](/images/python_logging/test.png)

맨위 요약에 정리하였듯, Python logging은 계층적 구조를 가진다. getLogger를 통해서 logger 인스턴스를 생성하고 이때 parameter로 모듈이름을 주면, .을 기준으로 모듈의 계층을 만들어 생성한다. 가장 기본적인 Root를 바탕으로, 새로운 모듈이름이 들어오면, root의 자식으로 생성되는 방식이다. 2번의 상황에서 "메인모듈"에서만 handler 설정을 하다보니, 메인모듈에서 설정한 formater와 같은 설정이 테스트A에선 적용되지 않은 것이다. 

Singleton Pattern과 관련하여 헷갈린 부분을 바로잡자면, 모든 Logger가 단 하나의 instance인건 아니고, 같은 모듈이름을 가진 logger을 요청할 경우, singleton 패턴을 적용하여 이미 생성된 logger instance를 반환하는 것이다.

그래서 python logging은 계층적 구조를 가지고 있으며, singleton pattern이 네이티브하게 적용되어 있다고 할 수 있다.

### 결론. 왜 이렇게 했을까? - 뇌피셜

Singleton Pattern이니 다른 모듈의 이름을 가지고 호출하여도, 동일한 instance를 반환, 모듈 이름을 호출된 모듈에 따라 다르게 불러주면 안되나? 라고 생각하여 찾아보니 의외로 쉽게 답이 나왔다.

Logging을 사용하는 전략의 경우 4가지 경우가 있다.

1. 모듈명 별로 logger 만들기
2. 객체인스턴스 별로 logger 만들기
3. 클래스명 별로 logger 만들기
4. 함수명 별로 logger 만들기

만약 하나의 거대한 logger instance가 존재하고, 각각의 경우에 대비하여 modulename과 모듈, 객체인스턴스, 클래스명, 함수명 별로 mapping된 정보를 다 가져가게 된다면, singleton pattern이 적용된 객체에 너무 많은(굳이 공유될 필요가 없는) 정보들이 다 담기게 되어 설계상 이점이 없어지게 된다.

Python의 logging은 구조적 계층을 통해, 필요한 formatter 정보는 공유하는 parent에 저장하고 각 logger는 singleton pattern에 맞춰 다양한 곳에서 reference 되도, 유일한 하나의 instance가 활용되게 하는 방식으로 logging이 이루어지게 되어 있다.
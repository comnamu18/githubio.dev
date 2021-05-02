---
title: "Tail_recursion"
date: 2021-05-02T14:29:16+09:00
draft: true
summary: "Tail Recursion을 Python 내장 라이브러리들을 활용해서 이해해보자"
---

# 한줄 요약

재귀 함수에서 Tail Recursion을 통해서 최적화를 할 수 있고, 이는 Disassembly된 코드를 통해서 직접 확인 가능 하다.

## Tail Recursion

함수에서 자기 자신을 재귀적으로 호출하지만, 재귀 호출이 반환된 뒤에 계산을 수행하지 않고 즉시 값을 변환하는 경우를 Tail Recuisive Function 이라고 합니다. 재귀 함수에서 Call Stack이 계속 쌓이는 것을 프로그래밍 적으로 최적화하여 일부 언어에서는 loop를 통한 구현 만큼이나마 효율적으로 동작 할 수 있습니다.([참고링크](https://www.cs.cornell.edu/courses/cs3110/2019sp/textbook/data/tail_recursion.html))

### 실험1. 일반적인 피보나치 함수로 Tail Recursion 확인하기

프로그래밍을 처음 배울 때, 재귀 함수의 예시로 많이 사용되는 피보나치 함수를 재귀를 통해 구현하여 Tail Recursion 에 대해 알아보도록 해보겠습니다.

```Python Script
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

가장 손쉽게 구현가능한 피보나치 함수는 위와 같은 모습이 될 것입니다. 해당 함수를 Python의 내장 라이브러리중 하나인 [dis](https://docs.python.org/ko/3.8/library/dis.html)를 사용하여 어셈블리 코드를 확인해보도록 하겠습니다.

```Python Script
import dis

def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
    
dis.dis(fibonacci)
```

위의 코드를 실행하게 되면 아래와 같은 아웃풋을 볼 수 있습니다.

```
5           0 LOAD_FAST                0 (n)
            2 LOAD_CONST               1 (2)
            4 COMPARE_OP               0 (<)
            6 POP_JUMP_IF_FALSE       12

6           8 LOAD_FAST                0 (n)
            10 RETURN_VALUE

7     >>   12 LOAD_GLOBAL              0 (fibonacci)
            14 LOAD_FAST                0 (n)
            16 LOAD_CONST               2 (1)
            18 BINARY_SUBTRACT
            20 CALL_FUNCTION            1
            22 LOAD_GLOBAL              0 (fibonacci)
            24 LOAD_FAST                0 (n)
            26 LOAD_CONST               1 (2)
            28 BINARY_SUBTRACT
            30 CALL_FUNCTION            1
            32 BINARY_ADD
            34 RETURN_VALUE
```

위의 어셈블리 코드에서 알 수 있듯, 일반적인 재귀 함수가 실행될 경우에 fibonacci(n-1) 을 실행 후, fibonacci(n-2)가 동일한 call stack 레벨에서 실행되는 것을 확인 할 수 있습니다.
```
call fibonacci(4)
    call fibonacci(3)
        call fibonacci(2)
            call fibonacci(1)
                return 1
            call fibonacci(0)
                return 0
            add fibonacci(1) and fibonacci(0)
            return 1
        call fibonacci(1)
            return 1
        add fibonacci(2) and fibonacci(1)
        return 2
    call fibonacci(2)
        call fibonacci(1)
            return 1
        call fibonacci(0)
            return 0
        add fibonacci(1) and fibonacci(0)
        return 1
    add fibonacci(3) and fibonacci(2)
    return 3
```
fibonacci(4)를 실행할 경우, call stack에서는 이와 같은 깊이로 function call을 저장하면서 실행될 것으로 예상됩니다. 4만해도 stack의 깊이가 저렇게 깊어지고 연산이 많아지니 n이 조금만 커지게 되어도, 예를 들면 fibonacci(10) 정도만 실행 하게 되면 재귀 함수의 끝없는 recursive call로 인해 고통받을 것이다.

### 실험2. Tail Recursive한 피보나치 함수를 작성해보자

위의 fibonacci함수에서 문제가 되었던 부분은, return에서 fibonacci(n-1)과 fibonacci(n-2)를 더하는 추가적인 연산작업 때문에 이전 단계의 fibonacci 함수에서 그 다음 단계의 함수 결과를 어딘가에 저장하고, 결과를 return 받기를 기다려야 한다는 부분이 있었다. 그렇다면, function parameter로 이전 스텝과 그 전전 스텝의 결과를 저장 하는 optimization 방식을 통해 Tail Recursive한 함수를 작성해 볼 수 있을 것이다. 실험1에서와 동일하게 해당 함수를 작성하고, dis를 통해 어셈블리 코드로 변환해 보았다.

```Python Script
import dis

def optimized_fibonacci(n, before_fibo=1, before_before_fibo=0):
    if n < 2:
        return n * before_fibo
    return optimized_fibonacci(n-1, 
                               before_fibo + before_before_fibo, 
                               before_fibo)

dis.dis(optimized_fibonacci)
```

```
2           0 LOAD_FAST                0 (n)
            2 LOAD_CONST               1 (2)
            4 COMPARE_OP               0 (<)
            6 POP_JUMP_IF_FALSE       16

3           8 LOAD_FAST                0 (n)
            10 LOAD_FAST                1 (before_fibo)
            12 BINARY_MULTIPLY
            14 RETURN_VALUE

4     >>   16 LOAD_GLOBAL              0 (optimized_fibonacci)
            18 LOAD_FAST                0 (n)
            20 LOAD_CONST               2 (1)
            22 BINARY_SUBTRACT

5          24 LOAD_FAST                1 (before_fibo)
            26 LOAD_FAST                2 (before_before_fibo)
            28 BINARY_ADD

6          30 LOAD_FAST                1 (before_fibo)

4          32 CALL_FUNCTION            3
            34 RETURN_VALUE
```

이렇게 optimized 된 함수를 통해서 fibonacci(4)를 실행시킨다고 가정해 보자.
```
call optimized_fibonacci(4, 1, 0)
    call optimized_fibonacci(3, 1, 1)
        call optimized_fibonacci(2, 2, 1)
            call optimized_fibonacci(1, 3, 2)
                return 1 * 3
            return 3
        return 3
    return 3
```

정확한 비교는 아니지만, 위에서 22 line이나 필요했던 과정이 무려 8 line으로 줄어든 것을 확인 할 수 있다. 이는 n이 커지면 커질 수록 더욱 큰 차이를 이뤄 낼 것이다.

### 실험3. 실행시간 비교

위의 call stack은 어디까지나 assembly code를 보고 따라한 예시이기에, 실제로 실행시간에 차이가 있을 수 있다. 이를 확인하기 위해 python 내장 라이브러리 중 하나인 [timeit](https://docs.python.org/ko/3/library/timeit.html)을 활용해서 정확한 동작 시간을 측정해보겠습니다. 정확한 실험을 위해 timeit.repeat을 통해 10번의 실험 후, 평균을 출력하는 함수를 작성해보았습니다.

```Python Script
import dis
import timeit

def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def optimized_fibonacci(n, before_fibo=1, before_before_fibo=0):
    if n < 2:
        return n * before_fibo
    return optimized_fibonacci(n-1, 
                               before_fibo + before_before_fibo, 
                               before_fibo)

normal = timeit.repeat('fibonacci(number)', 
                        setup='number=4', 
                        repeat=10,
                        globals=globals())
optimized = timeit.repeat('optimized_fibonacci(number)', 
                           setup='number=4',
                           repeat=10, 
                           globals=globals())

print(f"normal elapsed time = {sum(normal)/len(normal)}")
print(f"optimized elapsed time = {sum(optimized)/len(optimized)}")
```

number=4의 숫자를 바꿔서, 실행 속도를 측정하고 싶은 피보나치 수를 변경 가능하다.

```Shell Script
>>> python test.py
normal elapsed time = 1.40076568
optimized elapsed time = 0.8498700699999999
// number를 10으로 바꾼 후
>>> python test.py
normal elapsed time = 27.693402090000006
optimized elapsed time = 2.1311155000000044
// number를 13으로 바꾼 후
>>> python test.py
normal elapsed time = 118.45083089999999
optimized elapsed time = 2.809851790000039
```

이처럼 유의미한 실행 속도 감소를 볼 수 있다.

## Python은 Tail Recursion Optimization을 지원하지 않는다.

다만 참고해야 할 것은, Python 언어에서는 Tail Recursion Optimization을 지원하지 않는다. ([참고링크](https://stackoverflow.com/a/13592002)) Tail Recursion optimization의 핵심은, return에서 추가적인 작업이 필요하지 않을 경우, function call이 아닌 jump를 통해서 call stack이 더 깊어지지 않도록 하는 것이다.([C에서의 Tail Recursion Optimization](https://helloacm.com/understanding-tail-recursion-visual-studio-c-assembly-view/)) Scala같은 함수형 언어나 C와 같은 컴파일언어에서 주로 이런 optimization 기능을 지원하고 있다. 그러나 Python으로도 위에서 본 실험결과와 같이 Assembly code상에서 유의미한 차이와 성능향상을 볼 수 있으니 항상 명심해서 재귀함수를 짜면 좋을 것 같다. 물론 recursive하지 않은 iteration 방식으로 짜는 게 가장 생각하기 편할 것 같긴 하다.

## Reference - 참고자료

- Tail Recursion : https://www.cs.cornell.edu/courses/cs3110/2019sp/textbook/data/tail_recursion.html
- JS를 통한 Tail Recursion설명 : https://homoefficio.github.io/2015/07/27/%EC%9E%AC%EA%B7%80-%EB%B0%98%EB%B3%B5-Tail-Recursion/
- C를 통한 Tail Recursion : https://helloacm.com/understanding-tail-recursion-visual-studio-c-assembly-view/
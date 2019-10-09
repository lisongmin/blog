
+++
title = "python多重继承顺序"
date = 2019-09-30T22:33:00+08:00

[taxonomies]
tags = ["mro", "inheritance"]
categories = ["python"]
+++

# python多重继承顺序

之前一直习惯使用单重继承，主要是对python的多重继承继承顺序不太了解，不太敢使用。
今天特意去学习python多重继承的关系，以增强自身的底蕴。

## 简要说明

python的多重继承采用的是线性继承关系，一般按照从左到右，从顶层到底层的方式排序。
我们通过下面这个例子来做一个说明：

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-


class X:
    def name(self):
        if hasattr(super(), 'name'):
            print(f"super of X is {super().name()}")

        return "X"


class Y:
    def name(self):
        if hasattr(super(), 'name'):
            print(f"super of Y is {super().name()}")

        return "Y"


class A(X, Y):
    def name(self):
        print(f"super of A is {super().name()}")
        return "A"

A().name()
```

根据上面的python定义，一共定义了三个类，A, X, Y，一般的理解，是A继承自X, Y，而X和Y之间没有继承关系。

```
A----X --- object
  `--Y --/
```

但是，在python里面，不是这么算的，python的继承关系最终会压缩成线性关系，按照从左到右继承。
采用线性继承关系主要是因为python所有类都是继承自object的，这会导致多基类继承时，
会有多个路径调用最终都走到object对象的函数(`A -- X -- object` 和 `A -- Y -- object`)，出现多次调用的情况。

所以python的实际的继承关系是：

```
A --- X --- Y
```

也就是说，X和Y本来是没有继承关系的，但是，A给他们两个牵了线，在A的实例中，X和Y是存在继承关系的，
X会继承自Y的函数。如上面这个例子中，`A().name()`的输出结果是：

```
super of X is Y
super of A is X
```

## 复杂例子

前面这个例子比较简单，下面我们使用一个复杂的例子来展示python的完整继承关系，如下：

```python
class X: pass
class Y: pass
class Z: pass

class A(X,Y): pass
class B(Y,Z): pass

class M(B,A,Z): pass

for m in M.mro():
    print(m)
```

这里，从M的继承关系，可以得到下面继承顺序：

```
M -- B -- A -- Z
```

这里，B由Y, Z 继承过来，可以得出Y优先于Z，而Y和A没有依赖关系，但Y是M的直接继承，所以Y应该放在A的后面。
所以将B的基类加入后，可以得出下面的继承顺序：

```diff
- M -- B -- A -- Z
+ M -- B -- A -- Y -- Z
```

A由X, Y继承过来，可以得出X优先于Y，将A的基类展开后，得出如下顺序：

```diff
- M -- B -- A -- Y -- Z
+ M -- B -- A -- X -- Y -- Z
```

这个继承关系可以使用`mro()`函数打印出来，以上例子的输出结果如下：



```
<class '__main__.M'>
<class '__main__.B'>
<class '__main__.A'>
<class '__main__.X'>
<class '__main__.Y'>
<class '__main__.Z'>
<class 'object'>
```

* mro是**Method Resolution Order**的缩写，用于描述python的函数继承关系

# 参考

* [Python Multiple Inheritance](https://www.programiz.com/python-programming/multiple-inheritance)

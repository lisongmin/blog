
+++
title = "python默认参数的陷阱"
date = 2019-07-09T22:07:00+08:00

[taxonomies]
tags = ["python-fallibly", "default argument"]
categories = ["python"]
+++

# 问题

今天在类的__init__方法中给一个参数制定了默认值，将默认值设置为空字典`{}`。
结果发现单元测试无法通过，对这个参数的修改会影响到类的所有实例，和类的成员变量一个效果。

简化代码如下：

```python

class A(object):
    def __init__(self, a={}):
        self.a = a

a1 = A()
a2 = A()

a1.a['test'] = 'c'
print(a1.a)
print(a2.a)
```

结果输出：

```
{'test': 'c'}
{'test': 'c'}
```

可以看到，a1, a2两个实例的值同时发生了变化。
通常情况下，这种情况不是预期的。

# 原因

python在函数第一次调用的时候，会生成一个全局的对象用于保存默认值，后续再调用的时候，会将这个全局对象作为默认值传递给函数。
如果函数内修改了默认值对象，会导致这个默认值发生变化，一般会导致非预期的行为。

所以不要使用可以修改的对象作为默认值，这一般会导致问题。

# 最佳实践

* 不要使用可变参数作为函数的默认参数，对于空列表或空字典，使用None来替代。
* 使用pylint检查python代码的规范性

# 参考

* [Using a mutable default value as an argument](https://docs.quantifiedcode.com/python-anti-patterns/correctness/mutable_default_value_as_argument.html)

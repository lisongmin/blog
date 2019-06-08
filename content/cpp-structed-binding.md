
+++
title = "c++ 17 结构化绑定学习"
date = 2019-06-08T13:00:00+08:00

[taxonomies]
tags = ["structured binding"]
categories = ["c++", "c++-lang"]
+++

# c++ 17 结构化绑定学习

结构化绑定是c++17引入的新特性，它可以对数组，元组，结构体的成员变量进行绑定。

根据我的理解，从使用角度来看，

* 对数组的绑定会比较少一点，因为数组中保存的是相同元素，一般更常见的操作是遍历，需要对不同元素做不同处理的场景会比较少
* 对结构体(类)的绑定次之，结构体(类)已经通过成员变量名来实现成员的区分，一般可以直接使用，不需要再做绑定。
而且，当前版本的结构化绑定要求绑定所有成员变量，如果成员变量过多，会很麻烦，如果成员变量在当前作用域下不可用(如private成员)，也会造成无法绑定。
* 大多数场景都是对元组（包括std::pair)的结构绑定。**对元组的绑定则可以让我们的代码具有更高的可阅读性**，可以从绑定的变量名识别元组中元素的类型，意义等。

## 应用实例

结构化绑定的详细介绍可以参考[cppreference](https://en.cppreference.com/w/cpp/language/structured_binding)，
这里通过一个实际的例子来帮助记忆：

```c++
// file: a.cpp
// compile with `g++ -std=c++17 a.cpp`
// run with `./a.out`
#include <iostream>
#include <string>
#include <tuple>

int main() {
  std::tuple<std::string, std::string> record{"name", "email"};
  auto& [name, email] = record;

  std::cout << name << "\n";
  std::cout << email << "\n";
  return 0;
}
```

这里，重点关注`auto& [name, email] = record`这一行，它实现了结构化绑定，
将`record`这个tuple实例中的两个成员分别绑定到了变量`name`和`email`中。

注意，这里使用了`auto&`的方式绑定，这意味着`name`和`email`是对`record`中成员的引用，
他们不会拷贝，这节省了开销，同时也意味着，这两个变量的生命周期不能超过`record`的生命周期，
否则会出现不可预知的错误。

## 延伸阅读 std::tie

在c++17引入结构化绑定前，c++11就已经存在std::tie这个函数了，它可以用来构建一个左值引用的元组，
也可以用于将元组中的元素从元组中拆解出来。

拆解的动作一般可以使用结构化绑定来替代，这里主要介绍一个构建左值引用的元组的用法, 它可以用于简化
自定义数据结构的比较操作的实现。

假定我们有这么一个数据结构，要我们实现`<`操作符的重载：

```c++
struct A {
  int a;
  int b;
  int c;

  bool operator<(const A& another) const noexcept;
};
```

在以前，我们可能需要这么实现：

```c++

bool A::operator<(const A& another) const noexcept{
  return a < another.a || \
      (a == another.a && (b < another.b || \
          ( b == another.b && c < another.c)));
}
```

里面存在较多的逻辑操作，容易写错，如果成员变量增多，表达式也会变得更加复杂。而如果使用tie，我们的代码将会变得简洁而易于理解：

```c++

bool A::operator<(const A& another) const noexcept{
  return std::tie(a, b, c) < std::tie(another.a, another.b, another.c);
}
```

这里，通过左值引用构建了两个临时的tuple，然后通过tuple的比较操作来实现两个结构的比较。由于是左值引用，
这里是不需要进行拷贝动作的，所以并不存在额外的开销。

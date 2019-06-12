
+++
title = "std::remove_if相关函数学习"
date = 2019-06-12T23:17:00+08:00

[taxonomies]
tags = ["remove_if", "erase_if", "container"]
categories = ["c++", "c++-lang"]
+++

# std::remove_if相关函数学习

今天重新认识了[std::remove_if](https://en.cppreference.com/w/cpp/algorithm/remove)，
以前一直认为std::remove_if是直接删除容器中的元素，今天才被纠正过来，所以把相关知识重新梳理一下，
以加深印象。

std::remove_if会在匹配到需要删除的元素时，直接将后面一个不需要删除的元素通过move()语义移动过来。
执行了移动操作后，被移动的位置就会填充成一个未定义的值。在遍历一遍后，容器前半部分保存的是保留的
元素，保持和原有的出现顺序一致。后半部分元素中的值是不确定的，不再有使用的意义。

假设有一个数组

```
1 2 3 4 5 6
```

我们要remove其中的偶数，那么，执行remove_if后，容器中的元素会变为：

```
1 3 5 N N N
    ^ ^   ^
    | |---`-- 被执行过move动作的元素，这些元素不应该再使用
    | `- remove_if返回值指向的迭代器位置
    `- 从这里往前是保留的元素
```

这里，移动后的元素，并不会保存移动前的2, 4, 6元素，而是未定义的无效值，其位置的元素已经通过move移动到了前面，
这些位置不应该再被使用。

需要注意的是，**std::remove_if本身并不会对容器的size，迭代器进行变更**，这是与我之前理解不一样的地方，
它只是删除了数据，但是没有动容器，相当是软删除，必须配置erase才能把容器清理干净。
一般用法是和容器的erase结合在一起使用，以下的例子摘抄自[cppreference](https://en.cppreference.com/w/cpp/algorithm/remove):

```c++
#include <algorithm>
#include <string>
#include <iostream>
#include <cctype>

int main()
{
    std::string str2 = "Text\n with\tsome \t  whitespaces\n\n";
    str2.erase(std::remove_if(str2.begin(),
                              str2.end(),
                              [](unsigned char x){return std::isspace(x);}),
               str2.end());
    std::cout << str2 << '\n';
}
```

## 替代方案

我一向比较抗拒使用这种让人产生误解的函数，所以继续调查了一下，发现在c++20中，提供了std::erase_if来替代上面的功能，
目前gcc 9.0已经支持，期待[c++20](https://en.cppreference.com/w/cpp/compiler_support)早点到来^_^。

而如果是std::list或std::forward_list，还可以使用容器自带的remove_if来完成直接删除的目的。


+++
title = "boost::circular_buffer 性能对比及用法小结"
date = 2019-06-02T08:34:00+08:00

[taxonomies]
tags = ["container", "memory", "circular_buffer", "boost"]
categories = ["c++", "c++-libs"]
+++

# boost::circular_buffer 性能对比及用法小结

最近在项目中用到了循环队列的语义，于是引进了boost库的circular_buffer.

从直观了解，circular_buffer是预分配整块连续内存，并通过维护其首尾指针来实现循环，大部分情况下，性能应该和vector是一致的，
只有在first指针发生翻转时，会出现性能的损失。

来自[Kurt Guntheroth](http://oldhandsblog.blogspot.com)的[circular_buffer和vector, deque, list的性能比对](https://www.codeproject.com/Articles/1185449/Performance-of-a-Circular-Buffer-vs-Vector-Deque-a)
更加清晰的展现了其性能的比对情况，推荐阅读。

这里引用其中的一些比对结果数据：

操作 | circular_buffer | vector | deque | list
---- | --------------- | ------ | ----- | ----
assign      | 1534     | 1162   | 10237 | 9389
assign part | 1383     | 1050   | 7312  | 6724
delete part | 151      | 112    | 2925  | 2665
insert(end()) | 1004   | 1074   | 7234  | 6493
insert(end()), with reserve| - | 1032 | - | -
insert(begin()) | 9147849 | 4084888 | 13195 | 6745
push_back() |  997     | 4724   | 6814  | 6635
push_back(), with reserve | -  | 1412 | - | -
push_front()|  1212    | -      | 6738  | 6641
容器遍历(iterator) | 154 | 158  | 554   | 388
sort()      |  3337.9  | 2335.8 | 2968.5| 3333.5
sort() sorted | 954.9  | 420.8  | 460.5 | 1301.5
search container  | 3580 | 2452 | 3729  | -
push/pop as queue | 1155 | -    | 1848  |  8463

从上面的数据，我们可以看出，circular_buffer在大部分操作上和vector性能接近，
大部分场景下，使用circular_buffer优于deque和list.

同时，我们可以看到，往circular_buffer数据中插入一个数据是耗费很大的操作，
因为它需要对插入位置后的所有数据做一次移动的操作。
所以，**如果有插入数据的情景，应该避免使用circular_buffer.**

## std::copy的效率

针对circular_buffer复制的效率，我通过[test_circular_buffer.cpp](../assets/test_circular_buffer.cpp)进行了测试，
比较了直接使用array_one进行复制以及使用迭代器(begin(), end())进行复制的效率，结果如下：

4M数据拷贝100次，取最小值，最大值，和平均值，这里单位为微秒(micro seconds)

操作 | 最小值 | 最大值 | 均值
---- | ------ | ------ | ----
copy with c array cost | 181   | 1438 | 304
copy with iterator cost | 2175 | 4261 | 2435

从上面测试结果可以看到，使用array_one提供的连续内存拷贝会更快，应该是编译器识别到其是连续内存，而采取了优化措施。
所以，在进行块拷贝时，我们还是需要使用array_one(), array_two()进行复制。

## circular_buffer使用心得

* 只使用push语义，即往尾部插入数据
* 在拷贝一段数据时，推荐转换成c风格的数组后，再通过std::copy拷贝
* circular_buffer默认是固定长度，在满后，会覆盖尾部指针，所以，在插入数据前，需要确定数据有空间，避免数据被覆盖。

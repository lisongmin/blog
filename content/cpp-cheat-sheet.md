
+++
title = "我的c++知识速查表"
date = 2019-06-02T15:15:00+08:00

[taxonomies]
tags = ["cheat sheet"]
categories = ["c++"]
+++

# 我的c++知识速查表

记录我对c++的理解，以及在拥抱现代c++时，对之前方法的替代思路，持续更新。

## 内存相关

旧方法 | 推荐方法 | 头文件
------ | -------- | ------
memcpy | [std::copy](https://en.cppreference.com/w/cpp/algorithm/copy) | algorithm
memmove| [std::move](https://en.cppreference.com/w/cpp/algorithm/move) | algorithm
memset | [std::fill](https://en.cppreference.com/w/cpp/algorithm/fill) | algorithm


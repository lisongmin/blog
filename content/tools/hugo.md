
---
title: "Hugo 环境搭建及使用"
date: 2018-07-15T10:05:30+08:00
tags: 
    - hugo
---

## 安装hugo

hugo 的安装方法可以参见[官方的文档](https://gohugo.io/getting-started/installing/)。
对于Arch Linux来说，只要简单的执行`sudo pacman -S hugo`就可以完成安装了。

## hugo主题

在hugo的网站上，有很多[hugo主题](https://themes.gohugo.io/)可以选择，
我比较偏向于像写一本书一样写博客，所以选择了[hugo-theme-learn](https://github.com/matcornic/hugo-theme-learn)这个主题。

这个主题的主要亮点:

1. 支持搜索
1. 支持[Mermaid](https://mermaidjs.github.io/)，可以通过文本方式支持流程图，顺序图，甘特图
1. 支持收缩扩展
1. 支持告警，提示框


{{% notice note %}}
中文搜索目前支持的不是很好，主要支持英文搜索。后续需要寻找解决方案。

* http://www.linfuyan.com/add-chinese-support-to-lunrjs/
* https://github.com/MihaiValentin/lunr-languages

{{% /notice %}}


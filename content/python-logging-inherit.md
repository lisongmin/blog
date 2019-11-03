
+++
title = "python logging继承关系"
date = 2019-11-03T10:25:00+08:00

[taxonomies]
tags = ["logging"]
categories = ["python"]
+++

# python logging继承关系

这篇文章主要解析python logging模块不同logger间日志级别的继承关系，以及日志输出的机制。

在python的logging模块中，通过`logging.getLogger()`函数可以获取到指定的logger，如果没有指定参数，
那么返回的是root logger. 通过指定不同的logger名称，这个函数可以返回指定的logger.这里，logger名字
本身体现了logger的继承关系，它通过"."分隔父logger和子logger，可以存在很多个"."，他们一路继承下来。

如"a.b"这个logger存在一个父logger"a", 而"a"则从root logger继承而来。如下图所示：

![logging inherit](/assets/python-logging-inherit.svg)

每个logger下面可能存在0个或多个handler，handler实现日志的输出，每个handler对应一个输出目标。
通过配置多个handler，可以实现同时输出到文件，控制台的功能。
同时，每个handler可以定制日志级别，从而使得某些日志级别可以只输出到文件中，而不输出到控制台。

## logger的日志级别

每个logger都可以设置日志级别，如果没有设置，默认是NOSET。当logger的日志级别是NOSET时，它会按照继承关系向上层获取日志级别，
直到日志级别不是NOSET，或达到root logger为止。如以上关系，

* a.b logger是NOSET，那么他会获取a logger的日志级别
* 如果a logger的日志级别不是NOSET，那么a.b logger的日志级别将采用a logger的日志级别
* 如果a logger的日志级别也是NOSET，那么继续向上取root logger的日志级别。
如果没有手动设置，root logger默认的日志级别是WARNING

这个机制在[官方文档setLevel](https://docs.python.org/3/library/logging.html#logging.Logger.setLevel)中有详细介绍。

## 日志记录的机制

logger中，有一个字段[propagate](https://docs.python.org/3/library/logging.html#logging.Logger.propagate)，这个字段用于控制是否
继承父logger的handler，默认是继承。

当这个选项打开时，logger除了将日志写入自身的handler外，还会将日志写入祖先的handler中。

假设我们往a.b这个logger写入一条日志，其过程如下：

1. 日志的级别是否大于等于a.b这个logger设定的日志级别？
   * 如果日志级别小于a.b logger的日志级别，那么不需要记录日志，**流程结束**。
   * 否则，继续往下执行
2. 日志的级别是否大于等于a.b的handler设置定的日志级别？
   * 如果日志级别小于a.b handler的日志级别，那么不需要往这个handler写入日志
   * 否则，将日志写入这个handler中
3. 检查propagate标记
   * 如果propagate标记是False，不需要向上层handler输出，**流程结束**
   * 否则，准备往上层logger的handler输出日志
4. 对于上层logger的每一个handler，判断日志的级别是否大于等于handler的日志级别
   * 如果日志级别小于handler的日志级别，那么不需要往这个handler写入日志
   * 否则，将日志写入这个handler中
5. 重复3, 4步骤，直到满足退出条件。

这里需要注意的是，logger的日志级别用于在入口处过滤，handler用于出口处过滤，在propagate的时候，已经过了输入阶段，到达输出阶段，
不需要再判断上层logger的日志级别，只判断handler的级别是否满足。

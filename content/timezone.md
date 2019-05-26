

+++
title = "时区介绍和用法"
date = 2019-05-26T11:04:00+08:00

[taxonomies]
tags = ["python", "datetime", "timezone"]
categories = ["datetime"]
+++

# 时区介绍

时区的相关详细介绍可以参考[维基百科](https://zh.wikipedia.org/wiki/%E5%8D%8F%E8%B0%83%E4%B8%96%E7%95%8C%E6%97%B6).

这里只做简单介绍，主要是介绍不同地区的时间是如何转换的。

首先介绍一些时间相关的概念，这里按照自己理解给出的表述，不是准确描述。

* 本地时间 我们日常生活中使用的时间，是某个地区统一使用的时间，它一般会以太阳直射成影最小作为正午时间。
我们知道地球是圆的，中国的中午12点和美国的中午12点不是同一个时间，但是都是太阳在头顶的时间点。
* 世界协调时间(UTC) 是标准时间，是全球各地时间的基准。本地时间是按照UTC时间的偏移来表示。
* 时区 用于表示本地时间和UTC时间的偏移。

## 时间表示方法

不带时区的时间可以表示为

```
2019-05-26T14:28:00
```

由于没有时区信息，它并不能表达是哪个地区的时间。这种格式的时间只能在同一个时区内传播。

带时区的时间可以有两种表示方法，一种是显示本地时间，并显示时间偏移，如:

```
2019-05-26T14:28:00+08:00 # 北京时间
2019-05-26T15:28:00+09:00 # 东京时间
```

另一种是显示本地时间，并加上时区的别名，如下：

```
2019-05-26T14:28:00 CST # 北京时间(China Standard Time)
2019-05-26T15:28:00 JST # 东京时间(Japan Standard Time)
```

但注意使用别名是可能存在冲突的，如美国也有一个时区是用CST表示的。所以一般用时间偏移来表示更加准确。

## 时钟转换

* UTC时间转换成本地时间，只要加上时间偏移即可
* 本地时间转换成UTC时间，只要减去时间偏移即可
* 两个本地时间转换，只要加上两个时区的差值即可

地区 | 时间
---- | ----
UTC时间 |2019-05-26T06:28:00+00:00
北京时间 |2019-05-26T14:28:00+08:00
东京时间 |2019-05-26T15:28:00+09:00

## 使用哪种时间

一般，带时区的时间可以自由转换为不同地区的本地时间，而不带时区的时间不能转换，所以，如果是基于全球化的应用，
一般都需要使用带时区的时间。


# 用法

## python下的用法

在python中，需要注意不带时区的时间和带时区信息的时间是不能比较大小的，带时区信息的时间即使时区不一样，也可以比较大小，因为他们可以转换成UTC时间。

python默认使用的是不带时区的本地时间，如果要获取带时区的时间，需要一些额外操作。

1. 获取当前时间

    * 不带时区

        ```python
        from datetime import datetime
        now = datetime.now()
        ```

    * 带时区信息

        ```python
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc).astimezone()
        ```
        需要python 3.2及以后版本，如果需要支持更早的版本，需要引入pytz库

2. 将字符串转换成时间

    * 转换不带时区的字符串

        ```python
        from datetime import datetime
        date = datetime.strptime('2019-05-26T14:28:00', '%Y-%m-%dT%H:%M:%S')
        ```

    * 转换带时区的字符串

        ```python
        from datetime import datetime
        date = datetime.strptime('2019-05-26T14:28:00+0800', '%Y-%m-%dT%H:%M:%S%z')
        ```

3. 将时间转换成字符串

    * 转换成不带时区的字符串

        ```python
        from datetime import datetime
        now = datetime.now()
        now.strftime('%Y-%m-%dT%H:%M:%S.%f')
        ```

    * 转换成带时区的字符串

        ```python
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc).astimezone()
        now.strftime('%Y-%m-%dT%H:%M:%S.%f%z')
        ```

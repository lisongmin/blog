
+++
title = "linux下避免内存耗尽导致系统hang住或频繁读写swap"
date = 2020-05-10T21:10:00+08:00

[taxonomies]
tags = ["oom", "swap"]
categories = ["tools", "linux"]
+++

# linux下避免内存耗尽导致系统hang住或频繁读写swap

最近Fedora 32发布，其中有一个新特性启用[earlyoom](https://github.com/rfjakob/earlyoom).

这个特性对我来说，是比较感兴趣的，因为之前使用笔记本跑ci的时候，出现过系统不能反应的情况，
应该是因为多个任务同时运行，编译c++程序导致的。如果有earlyoom，最多是某个编译任务失败，
而不需要硬重启电脑。

earlyoom在系统可用内存以及swap都下降到某个点时(默认10%)，给占用内存最多的进程发terminate信号，
如果可用内存继续下降（到5%)，将发送kill信号终止进程释放内存。

## 安装部署earlyoom

这里以arch linux为例介绍整个过程。
首先是安装，通过以下命令安装：

```bash
# pacman -S earlyoom
```

安装完成后，可以修改配置，配置文件在`/etc/default/earlyoom`中。earlyoom配置比较简单，基本是零配置。
可能唯一需要注意的是，如果内存太大，建议通过`-M`指定触发的时机点。通过`man earlyoom`可以看到完整的帮助。

默认参数为：

```
EARLYOOM_ARGS="-r 3600 -n --avoid '(^|/)(init|systemd|Xorg|sshd)$'"
```

这里，增加`-m 10 -M 1048576`两个参数，将触发terminate的时机限定为`min(10%, 1G)`，
这样，避免在大内存的情况下，还有几G内存可用就有进程被强制退出。

```
EARLYOOM_ARGS="-m 10 -M 1048576 -r 3600 -n --avoid '(^|/)(init|systemd|Xorg|sshd)$'"
```

最后，启动并启用earlyoom服务，完成整个配置。

```bash
# systemctl start earlyoom
# systemctl enable earlyoom
```


+++
title = "通过systemd支持自动挂载"
date = 2019-10-07T15:46:00+08:00

[taxonomies]
tags = ["systemd", "autofs", "automount"]
categories = ["os", "linux", "systemd"]
+++

# 通过systemd支持自动挂载

## 背景

家里的nas存储是放在独立硬盘盒里面，通过usb连接到电脑中。目前nas不是一直连接到电脑上的，而是使用时连接。
这里有个麻烦的地方，就是连接后，需要手动mount文件系统，这一点很不方便。查了一下资料，
发现可以通过systemd的automount来实现自动挂载，这样就不需要每次手动挂载了。

## 应用场景

我们往电脑上插上u盘或移动硬盘时，如果移动硬盘有文件系统，操作系统也会自动挂载这些分区，
这个功能是每个操作系统下基本上都有的，实现的方法可能不一样，我比较了解的是[udisks2](https://wiki.archlinux.org/index.php/Udisks)，所以下面会通过
它和systemd automount做对比，以了解各自的应用场景。

| 对比项 | udisks | systemd automount |
| ------ | ------ | ----------------- |
| 挂载时机 | 在移动硬盘插入时挂载 | 首次访问挂载路径时挂载 |
| 挂载点 | 自动在 `/run/media/$user/` 目录下生成挂载点，不同用户挂载点不一样 | 需要手动配置挂载点，固定挂载点 |
| 配置方式 | 不需要配置，主要针对移动存储 | 需要给每个自动挂载的磁盘配置，所以主要针对已知的存储 |

## 配置systemd automount

我们可以在 `/etc/fstab` 中配置自动挂载的文件系统。在fstab中加入以下行即可实现自动挂载:

```
/dev/nas/personal /nas/personal xfs defaults,noauto,nofail,x-systemd.automount,x-systemd.device-timeout=10s,x-systemd.idle-timeout=5min 0 0
```

这里，

* `/dev/nas/personal` 表示设备名，注意，这里需要使用不会飘移的名字，如lv名，或使用UUID的形式(如`UUID=a9132c5e-4336-4800-a929-5b4f9fa68474`)，
不要使用sdX这种可能会变化的名字
* `/nas/personal` 表示挂载点，根据实际情况填写
* `xfs` 表示文件系统类型，根据实际情况填写
* 接下来是挂载时使用的选项，比较多，这里一一介绍，记不住不要紧，可以通过`man systemd.mount`查看帮助:
    * `defaults` 默认挂载选项
    * `noauto` 开机启动时不挂载，避免影响开机启动速度，如果一个挂载项需要配置成自动挂载，这个选项是**必须的**
    * `nofail` 挂载失败时，不影响系统继续启动，感觉和`noauto`有点重合？可能加noauto就够了，这里没做深入了解
    * `x-systemd.automount` 这个属性是重点，通过这个选项来告诉systemd，这个挂载项需要实现自动挂载
    * `x-systemd.device-timeout=10s` 可选参数,当存储不存在时，访问挂载点会导致卡住90s，这个是systemd默认的超时时间，通过指定这个参数，
    我们可以在设备不存在时，更早的返回，避免访问挂载点时，长时间无反应。这个属性可能需要systemd 230及以上版本才能生效？
    参考这个[issue](https://github.com/systemd/systemd/pull/3170)
    * `x-systemd.idle-timeout=5min` 可选属性，这个属性告诉systemd，如果文件系统超过5分钟没有人使用，就自动卸载，下次有人访问时，再次挂载。

在增加记录后，执行`systemctl daemon-reload`使修改生效。

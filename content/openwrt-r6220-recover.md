
+++
title = "修复被玩坏的 r6220"
date = 2021-10-01

[taxonomies]
tags = ["r6220", "brick", "recovery", "nmrpflash"]
categories = ["os", "openwrt"]
+++

# 修复被玩坏的 r6220

准备在10.1期间升级openwrt到21.02版本，并重新划分vlan，
隔离家庭网络，访客网络以及lot网络。

结果，在升级r6220的时候，提示swconfig升级到dsa不支持。
脑子一热，用了`-F`来强制升级，结果是再也连不上了...

接下来就是想办法恢复r6220.

第一个尝试的方法是[nmrpflash](https://github.com/jclehner/nmrpflash).

1. 先从netgear官网下载[r6220的固件包](https://www.downloads.netgear.com/files/GDC/R6220/R6220-V1.1.0.110_1.0.1.zip)
1. 通过网线，将r6220的lan1口连接到电脑上
1. 保持r6220处于关机状态
1. 执行命令 `sudo ./nmrpflash -i br0 -f /home/lsm/Downloads/R6220_V1.1.0.110.img`

    这里, `br0` 是电脑上的网卡端口
1. 在看到`Waiting for Ethernet connection`的输出后，启动r6220
1. 等待官方固件刷入， 结果出现了如下错误

    ```
    bind: Cannot assign requested address
    ```
1. `nmrpflash` 官网有解决方案，把命令行改为：

    ```
    sudo ./nmrpflash -i br0 -f /home/lsm/Downloads/R6220_V1.1.0.110.img -a 192.168.1.1 -A 192.168.1.10
    ```

    这里，`-A` 指定的ip为电脑上`br0`的ip，`-a` 指定的是r6220的ip

1. 等待，等待，等待。当看到`Remote finished. Closing connection.`时，刷入官方固件成功，
重启路由器即可。
1. 接下来可以按照[在 r6220 上部署 openwrt](./openwrt-r6220.md)安装openwrt 21.02

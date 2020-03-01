
+++
title = "使用systemd-networkd管理网络"
date = 2020-03-01T16:48:00+08:00

[taxonomies]
tags = ["systemd", "network", "iwd"]
categories = ["os", "linux", "systemd"]
+++

# 使用systemd-networkd管理网络

早在一个月前，就将网络管理从`netctl`切换到`systemd-networkd`了，
虽然很反对systemd什么都搞，但systemd-networkd确实要用，配置也比较简单。

## 停止现有网络管理服务

这里主要介绍配置有线网络，以及无线网络的过程。
在开始配置前，需要把正在使用的网络管理服务停止掉，以避免出现冲突。

## 配置有线网络

有线网络主要配置时，考虑到可能使用手机usb连接共享收集的网络，为了保持命名的一致性，
通过 bridge 来归一化所有有线连接。配置如下：

1. 将所有有线连接都作为br0的底层设备

    ```
    $ cat /etc/systemd/network/19-en.network
    ```

    ```
    [Match]
    Name=en*

    [Network]
    Bridge=br0
    ```

2. 定义br0设备

    ```
    $ cat /etc/systemd/network/20-br0.netdev
    ```

    ```
    [NetDev]
    Name=br0
    Kind=bridge
    ```

3. 配置br0的网络

    这里采用了dhcp的方式获取ip，由于我采用了独立的DNS解析，这里配置不使用DNS.

    ```
    $ cat /etc/systemd/network/20-br0.network
    ```

    ```
    [Match]
    Name=br0

    [Network]
    DHCP=yes
    IPForward=yes
    IPv6AcceptRA=true

    [DHCP]
    UseDNS=false
    RouteMetric=100
    ```

以上是有线网络的所有配置。

## 配置无线网络

接下来是无线网络的配置，无线网络采用iwd来管理wifi。

1. 启动iwd服务

    ```
    systemctl start iwd.service
    ```

2. 扫描并设置wifi密码

    ```
    $ iwctl
    [iwd]# device list
                                        Devices                                   *
    --------------------------------------------------------------------------------
      Name                Address             Powered   Adapter   Mode
    --------------------------------------------------------------------------------
      wlan0               54:27:1e:4f:14:87   on        phy0      station

    [iwd]# station wlan0 scan
    [iwd]# station wlan0 get-networks
                                   Available networks                             *
    --------------------------------------------------------------------------------
        Network name                    Security  Signal
    --------------------------------------------------------------------------------
      > CMCC-cqhu                       psk       ****

    [iwd]# station wlan0 connect CMCC-cqhu
    ```

3. 设置无线网络的配置

    ```
    $ cat /etc/systemd/network/25-wireless.network
    ```

    ```
    [Match]
    Name=wl*

    [Network]
    DHCP=yes
    IPForward=yes
    IPv6AcceptRA=true

    [DHCP]
    UseDNS=false
    RouteMetric=200
    ```

## 启动服务及开机自启动

使用`systemctl start systemd-networkd`启动服务，看配置是否生效，网络是否正常。

在网络正常后，通过下面命令设置开机自启动，完成所有配置。

```
systemctl enable iwd.service
systemctl enable systemd-networkd.service
```

## libvirt 网络无法启动问题

在使用systemd-networkd管理网络后，libvirtd开机无法自启动网卡，会有下面的报错：

```
enabling IPv6 forwarding with RA routes without accept_ra set to 2 is likely to cause routes loss
```

[相关问题单链接](https://bugzilla.redhat.com/show_bug.cgi?id=1639087)

`man systemd.network` 可以看到systemd-networkd对这个参数的相关解释:

Note that kernel's implementation of the IPv6 RA protocol is always disabled,
regardless of this setting. If this option is enabled, a userspace implementation
of the IPv6 RA protocol is used, and the kernel's own implementation remains disabled,
since systemd-networkd needs to know all details supplied in the advertisements,
and these are not available from the kernel if the kernel's own implementation is used.

目前通过在libvirtd的脚本中手动启动网卡来规避这个问题：

```
$ cat /etc/systemd/system/libvirtd.service.d/override.conf
```

```
[Service]
# set accept_ra
ExecStartPost=-/usr/bin/sysctl -w net.ipv6.conf.wlan0.accept_ra=2
ExecStartPost=-/usr/bin/sysctl -w net.ipv6.conf.br0.accept_ra=2
# start network
ExecStartPost=-/usr/bin/virsh net-start --network net99
ExecStartPost=-/usr/bin/virsh net-start --network net100
ExecStartPost=-/usr/bin/virsh net-start --network default
# unset accept_ra
ExecStartPost=-/usr/bin/sysctl -w net.ipv6.conf.wlan0.accept_ra=0
ExecStartPost=-/usr/bin/sysctl -w net.ipv6.conf.br0.accept_ra=0
```

# libvirtd 有虚拟机运行时，br0 拔网线后，ip不会自动消失

在 libvirtd 没有虚拟机运行时，拔网线后，上面自动分配的ip会被 systemd-networkd 清理掉，
但如果 libvirtd 有虚拟机正在运行，那么拔网线后，br0 上面的ip不会清理，路由仍然存在，
这导致拔网线后，不能自动切换到 wlan0 运行，因为br0的路由优先级比较高。

这个问题目前还没找到自动解决的办法。

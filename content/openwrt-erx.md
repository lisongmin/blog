
+++
title = "在 er-x 上部署 openwrt"
date = 2020-04-20T14:51:00+08:00

[taxonomies]
tags = ["er-x"]
categories = ["os", "openwrt"]
+++

# 在 er-x 上部署 openwrt

新入手一台er-x，用作家庭网络的主路由，架设在光猫和家庭网络之间。
计划刷openwrt，通过开源方案来保证家庭网络的纯洁以及方便统一维护。

准备工作：

* pc机一台，这里使用linux系统
* er-x 一台
* 网线一根

## 备份分区

参照[备份原始固件](https://openwrt.org/toh/ubiquiti/ubiquiti_edgerouter_x_er-x_ka#backup_the_original_firmware)的方式备份。
以备在出现问题时，可以恢复。

这次没有执行这个操作，裸上了^_^!!

## 刷 openwrt 固件

用电脑连接 er-x 的 eth0 口，这个网口在er-x侧默认配置了`192.168.1.1`，需要在电脑端配置一个同网段的ip以实现通信。
如果电脑有其他网络也是使用`192.168.1.0/24`这个网段的地址，最好停用掉这个网络以避免干扰。

1. 配置pc上的ip

    这里通过`ip`命令配置网络

    ```
    $ sudo ip addr add 192.168.1.5/24 dev br0
    ```

2. 下载固件

    根据 [Factory firmware installation method](https://openwrt.org/toh/ubiquiti/ubiquiti_edgerouter_x_er-x_ka#factory_firmware_installation_method) 章节的方式刷如固件，
    这里注意，当前的18.06, 19.07版本都不能刷入，会提示`image does not support the device`

    ```
    ubnt@ubnt:/tmp$ add system image openwrt-19.07.2-ramips-mt7621-ubnt-erx-initramfs-kernel.bin
    Checking upgrade image...Upgrade image does not support the device. Upgrade failed.
    /tmp
    ```

    根据安装方法的提示，下载一个[比较老的固件](https://www.freifunk-winterberg.net/wp-content/uploads/2017/07/lede-ramips-mt7621-ubnt-erx-initramfs-factory.tar)刷入，再升级上来。
    由于有线接er-x，这里通过手机共享的网络下载固件。

3. 上传固件到er-x

    ```
    scp lede-ramips-mt7621-ubnt-erx-initramfs-factory.tar ubnt@192.168.1.1:/tmp/
    ```

    默认密码是`ubnt`

4. 安装固件

    先登录到er-x里面

    ```
    $ ssh ubnt@192.168.1.1
    ```

    进入 `/tmp/` 目录

    ```
    ubnt@ubnt:~$ cd /tmp
    ```

    增加固件

    ```
    ubnt@ubnt:/tmp$ add system image lede-ramips-mt7621-ubnt-erx-initramfs-factory.tar
    Checking upgrade image...Done
    Preparing to upgrade...Done
    Copying upgrade image.../usr/bin/ubnt-upgrade: line 580: [: too many arguments
    Done
    Removing old image...Done
    Checking upgrade image...Done
    Copying config data...Done
    Finishing upgrade...Done
    Upgrade completed
    ```

    查看固件情况，应该可以看到新增的固件

    ```
    ubnt@ubnt:/tmp$ show system image
    The system currently has the following image(s) installed:

    ramips                         r4434-b91a38d                  SNAPSHOT                       (default boot)
    v1.10.7.5127989.181001.1227    (running image)

    A reboot is needed to boot default image
    ```

    重启使其生效

    ```
    ubnt@ubnt:/tmp$ reboot
    Proceed with reboot? [confirm]y

    Broadcast message from root@ubnt (pts/0) (Thu Jan  1 01:39:41 2015):

    The system is going down for reboot NOW!
    ```

5. 升级固件到最新版本

    需要将网口从`eth0` 移到 `eth1`上，因为openwrt默认在这个端口上侦听。
    换网口后，需要检查ip是否还存在，如果不存在，需要再次增加。

    ```
    $ sudo ip addr add 192.168.1.5/24 dev br0
    ```

    下载最新版本固件，当前是19.07.2版本，并上传到er-x上。

    ```
    $ scp 19.07.2/openwrt-19.07.2-ramips-mt7621-ubnt-erx-squashfs-sysupgrade.bin root@192.168.1.1:/tmp/
    ```

    使用`root`用户登录 openwrt

    ```
    $ ssh root@192.168.1.1
    ```

    升级固件

    ```
    root@LEDE:/tmp# sysupgrade openwrt-19.07.2-ramips-mt7621-ubnt-erx-squashfs-sysupgrade.bin
    Cannot save config while running from ramdisk.
    killall: watchdog: no process killed
    Commencing upgrade. All shell sessions will be closed now.
    Connection to 192.168.1.1 closed by remote host.
    Connection to 192.168.1.1 closed.
    ```

    刷新固件需要点时间，等待固件刷新完成。

## 配置 openwrt

### 设置root密码

首先，我们需要配置ssh的登录时使用的root密码，保证别人不能随意登录上来。这是很重要的一步。
密码最好复杂到自己都记不住，这里，使用KeePaasXC来生成密码，并通过`passwd`命令设置密码。

```
 $ ssh root@192.168.1.1
Warning: Permanently added '192.168.1.1' (RSA) to the list of known hosts.


BusyBox v1.30.1 () built-in shell (ash)

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 OpenWrt 19.07.2, r10947-65030d81f3
 -----------------------------------------------------
=== WARNING! =====================================
There is no root password defined on this device!
Use the "passwd" command to set up a new password
in order to prevent unauthorized SSH logins.
--------------------------------------------------
root@OpenWrt:~# passwd
```

为了方便访问，将ssh 的public key写入到er-x上的`/etc/dropbear/authorized_keys`文件中，
这样下次访问时就不需要再次输入密码。

### 更改 LAN 默认使用的网段

内网默认是使用`192.168.1.0/24`这个网段，如果不使用桥接模式通过pppoe拨号的话，这个网段会和光猫使用的网段重合。
为了避免网段冲突，将网段改为`192.168.2.0/24`网段。

### 接入光猫

openwrt默认已经做好了各种配置，基本不需要修改即可上网，只要把光猫出来的网线接到eth0口即可。

### 更新软件

软件可以通过`opkg`命令来更新，用法和`apt`类似，

1. 更新软件源

    ```
    $ opkg update
    ```

2. 查看变化的软件

    ```
    $ opkg list-upgradable
    ```

3. 更新软件包

    ```
    $ opkg upgrade <pkg1 pkg2 ...>
    ```

openwrt没有提供一键式升级的方案，因为路由器本身的内存，存储比较小，一次更新所有的软件比较容易出现问题导致路由器变砖。

## 折腾

到这里，openwrt基本安装完成，后面就是折腾自己的东西了，后续可能增加以下内容

* 光猫设置桥接模式，由路由器pppoe拨号，关闭光猫的wifi
* 部署nginx + acme.sh
* 部署v2ray
* wifi roaming (802.11rkv 802.11s)

## 参考

* [Ubiquiti EdgeRouter X (ER-X), EdgeRouter X-SFP (ER-X-SFP) and EdgePoint R6 (EP-R6)](https://openwrt.org/toh/ubiquiti/ubiquiti_edgerouter_x_er-x_ka)

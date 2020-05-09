
+++
title = "在 r6220 上部署 openwrt"
date = 2020-04-21T14:51:00+08:00

[taxonomies]
tags = ["r6220"]
categories = ["os", "openwrt"]
+++

# 在r6220上部署openwrt

## 在r6220上安装openwrt

从京东二手入手一个r6220，作为客厅的AP。确定功能基本正常后，开始刷openwrt.

1. 首先把外网连接到wan口，同时电脑连其中一个lan口，并将电脑的ip配置为和r6200默认ip同网段的ip，这里配置为`192.168.1.10/24`.
2. 在浏览器上访问192.168.1.1网页
3. 这时候，提示是否通过网件精灵恢复，选择"是"，并继续
4. 这里，会提示输入新密码，这时候，建议尝试用`password`这个默认密码（刚开始当成设置自己的密码，结果提示没有权限)。
5. 成功后，再次访问192.168.1.1，上传[openwrt的固件19.07.2](http://downloads.openwrt.org/releases/19.07.2/targets/ramips/mt7621/openwrt-19.07.2-ramips-mt7621-r6220-squashfs-factory.img)，开始刷新openwrt.

    ![](/assets/openwrt-r6220-refresh.png)

6. 等待固件刷新完成后，再次登录web，可以看到，openwrt的web界面，到此openwrt安装完成。
7. 通过ssh登录openwrt，并设置root密码，同时配置/etc/dropbear/authorized_keys，以实现无密码登录。

## 将r6220配置成ap模式

1. 将上游有线网络连到r6220的lan口(**不要连到wan口**)，这里连到eth0(1)上。
2. 将电脑也连到r6220的lan口，这里连到eth1(2)上。
3. 通过ssh登录r6220，修改/etc/config/network 的lan配置

    ipv4 设置为静态ip地址，方便后续管理，这里，`gateway`和`dns`配置为主路由的ip，同时配置的静态ip也和主路由在同一网段内。
    这样，后续所有通过lan或wifi接入的设备，都可以从主路由获取ip，保证所有设备在同一网段内。

    ```
    config interface 'lan'
            option type 'bridge'
            option ifname 'eth0.1'
            option proto 'static'
            option ipaddr '192.168.2.2'
            option netmask '255.255.255.0'
            option gateway '192.168.2.1'
            list dns '192.168.2.1'
    ```

    同时增加一个虚拟接口，配置动态ipv6地址，实现对外的ipv6连接。

    ```
    config interface 'lan6'
            option proto 'dhcpv6'
            option ifname '@lan'
            option reqprefix no
    ```

    重启网络，使配置生效。

    ```
    service network restart
    ```

    以上操作也可以通过web修改，web修改出现问题的机率更小一点，因为他提供在失败后，会自动回退配置，
    这样更加安全一点。

4. 配置wifi. 到这里，wifi还没有开启，需要配置并启用wifi，以完成最后一步。登录`http://192.168.2.2`，点击`network` -> `wireless`，
依次开启2.4G, 5G的网络。这里以5G为例，2.4G雷同，不再介绍。

    ![](/assets/openwrt-r6220-config-wifi.png)

    启用5G网络，对于5G，选择AC模式，信道最好选择国内支持的信道，避免手机等设备无法连接。选择最高的80MHz频宽。
    ![](/assets/openwrt-r6220-channel-width.png)

    如果信道选择自动，建议在高级选项中将国家码选择为本国，避免出现手机，电脑无法发现wifi的情景。

    ![](/assets/openwrt-r6220-region.png)

    接下来开始配置AP，取一个对外显示的wifi名

    ![](/assets/openwrt-r6220-ap.png)

    在安全选项中，选择加密算法，并设置密码。

    ![](/assets/openwrt-r6220-security.png)

    最后，需要应用变更，使配置生效。


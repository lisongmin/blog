
+++
title = "在 r6850 上部署 openwrt"
date = 2020-04-25T17:16:00+08:00

[taxonomies]
tags = ["r6850", "network"]
categories = ["os", "openwrt"]
+++

# 在r6850上部署openwrt

## 在r6850上安装openwrt

在r6850上安装openwrt和[在r6220上安装openwrt](../openwrt-r6220)方法一致，只是当前r6850还没有进入官方支持状态，需要从snapshot下载镜像。

## 将r6850配置成ap模式

在配置r6220时，我们采用静态ip的方式配置，这种方式不够灵活，这里改用dhcp的方式配置，同时，在主路由上，
根据MAC地址分配固定的永久ip，来保证ip不会变化，达到同样的效果。

1. 在r6850上，将lan口的ip分配方式改为`DHCP client`

    ![](/assets/openwrt-r6850-dhcp-client.png)

2. 登录主路由，点击"DHCP and DNS"，在"Server Settings"中，点击"Add"增加一条静态dhcp信息，
将r6850的MAC地址，和静态ip地址配置上，期限选择`infinite`.

    ![](/assets/openwrt-main-router-set-static-dhcp.png)

经过这两个步骤，r6850以后会固定获取到特定的静态ip。ipv6的配置保持和r6220配置一样，通过增加一个虚拟网口来实现。

## 注意事项

目前shapshot对mt76的支持好像有问题，经常出现无法获取ip或无法授权的情况，目前没有时间切换到19.07，先搁置。

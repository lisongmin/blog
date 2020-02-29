
+++
title = "基于ssh tunnel建立vpn"
date = 2020-02-04T23:14:00+08:00

[taxonomies]
tags = ["badvpn", "ssh", "tunnel", "systemd", "network", "vpn"]
categories = ["os", "linux", "systemd"]
+++

# 基于ssh tunnel建立vpn

最近这场疫情，导致远程办公成为大部分公司的选择，最简单的远程方式是通过ssh tunnel的动态端口转发方式，构建socks5代理.
但这种模式需要每个应用都以代理方式运行，不太方便。而badvpn这个软件可以将socks代理转成vpn，从而实现无缝访问公司内网。

这里介绍通过ssh, [badvpn](https://github.com/ambrop72/badvpn), systemd-networkd共同构建vpn的方案。

## 配置TUN网络

这里通过systemd-networkd来管理网络，可以通过NetDev来创建tun设备，如下：

```
$ cat /etc/systemd/network/30-sshtun.netdev

[NetDev]
Name=sshtun
Kind=tun
Description=ssh tunnel

[Tun]
User=lsm
```

这里注意User后跟的用户名是tun设备的属主，这样后续就可以使用这个用户运行`badvpn-tun2socks`，
如果不设置用户，那只能使用root用户来运行`badvpn-tun2socks`.

tun设备配置好后，开始配置网络，如下：

```
$ cat /etc/systemd/network/30-sshtun.network

[Match]
Name=sshtun

[Network]
Address=10.4.199.4/24

[Route]
Gateway=10.4.199.1
Destination=192.168.33.0/24

[Route]
Gateway=10.4.199.1
Destination=192.168.34.0/24
```

这里，

* `Address=10.4.199.4/24` 指定网卡上使用的静态ip
* `Gateway=10.4.199.1` 是badvpn的ip，同时也是vpn的网关ip
* `Destination=192.168.34.0/24`, `Destination=192.168.33.0/24` 是远端(公司)的网段，这里写了两个`[Route]`章节，
表示有两条路由，如果有更多的路由，按照同样的方式增加

到这里，网络部分配置完成。执行`systemctl restart systemd-networkd`使配置生效。重启后，执行`ip addr`可以看到新增的设备，
如下：

```
24: sshtun: <NO-CARRIER,POINTOPOINT,MULTICAST,NOARP,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 500
    link/none
    inet6 fe80::9bba:710d:bd04:b907/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
```

可以看到，sshtun设备上并没有ip存在，这是因为vpn是sshtun的承载，vpn还没有启动，承载不存在，就像是网线没有插上，所以network不会生效。

## 启动vpn

接下来开始启动vpn

```
badvpn-tun2socks --tundev sshtun --netif-ipaddr 10.4.199.1 --netif-netmask 255.255.255.0 --socks-server-addr localhost:10800
```

* `--tundev` 指定tun设备的名字，这个需要和上一步NetDev中的设备名一致
* `--netif-ipaddr` 是vpn的ip
* `--socks-server-addr` 指定的是socks5代理的地址

启动后，再次执行`ip addr show dev sshtun`，可以看到ip已经存在，如下：

```
24: sshtun: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 500
    link/none
    inet 10.4.199.4/24 brd 10.4.199.255 scope global sshtun
       valid_lft forever preferred_lft forever
```

## 开启ssh tunnel

```
ssh -Nfq -D 10800 user@ssh.server
```

到这里，vpn已经通了，可以通过ssh直接访问公司内网服务器，或直接使用浏览器访问公司内网网站。

但是，这个配置还有以下问题：

1. 这个vpn只能转发tcp请求，不能处理udp请求，所以，不能ping公司内网，这个需要服务端的支持，后续解决。
2. 这里没有DNS配置，如果公司内网https需要域名解析，需要自行更改dns配置。

最后，建立vpn和ssh隧道可以考虑做成systemd服务，举例如下：


```
 $ cat ~/.config/systemd/user/ssh-to-company.service

[Unit]
Description=ssh tunnel to company

[Service]
Type=simple
ExecStart=/usr/bin/autossh -M 0 -o ServerAliveInterval=45 -o ServerAliveCountMax=2 -TN -D 10800 user@ssh.server

[Install]
WantedBy=default.target
```

这里，如果直接使用ssh，不能在连接中断时，自动重连，所以，一般会使用autossh，这个辅助程序会感知tunnel的状态，
并在需要时自动重启ssh.


```
$ cat ~/.config/systemd/user/vpn-to-company.service

[Unit]
Description=tun2socks to company

[Service]
Type=simple
ExecStart=/usr/bin/badvpn-tun2socks --tundev sshtun --netif-ipaddr 10.4.199.1 --netif-netmask 255.255.255.0 --socks-server-addr localhost:10800

[Install]
WantedBy=default.target
```

配置完成后，设置为用户登录后自启动

```
systemctl --user enable ssh-to-company.service
systemctl --user enable vpn-to-company.service
```

## 参考

* [vpn over ssh](https://wiki.archlinux.org/index.php/VPN_over_SSH)
* [badvpn tun2socks](https://github.com/ambrop72/badvpn/wiki/Tun2socks)
* [autossh on archwiki](https://wiki.archlinux.org/index.php/OpenSSH#Autossh_-_automatically_restarts_SSH_sessions_and_tunnels)

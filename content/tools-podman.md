
+++
title = "podman 初步使用"
date = 2020-01-18T09:47:00+08:00

[taxonomies]
tags = ["docker", "podman"]
categories = ["tools", "virtualization"]
+++

# podman 初步使用

之前主要使用docker，podman已经出来一段时间了，但还没有使用过，
今天尝尝鲜。

## 安装podman

在Arch linux下，直接安装podman即可。

```
sudo pacman -S podman
```

## 配置subuid/subgid

podman支持在非root用户下运行，这需要配置/etc/subuid 和 /etc/subgid，
使得podman可以将host的用户id映射到container里面去。

如下是我的配置，更多详细信息可以通过`man /etc/subuid`查看

```
$ cat /etc/subuid

lsm:100000:65535
```

```
$ cat /etc/subgid

lsm:100000:65535
```

修改以上两个文件后，注意podman并不会加载新的变更，需要先执行`podman system migrate`命令更新。

```
$ podman system migrate
```

这个机制类似于systemd的`systemctl daemon-reload`？在`man podman-system-migrate`里面有
详细的解释：

```
Rootless  Podman  uses  a  pause process to keep the unprivileged namespaces alive.
This prevents any change to the /etc/subuid and /etc/subgid files from being propagated
to the rootless containers while the pause process is running.
```

## 配置镜像源

基于国内糟糕的网络状态，从官网下载镜像比较吃力，这个时候，我们会想从国内的镜像源下载镜像，
在docker中，可以通过`registry-mirrors`来配置，而在podman中，
可以通过`/etc/containers/registries.conf`修改。registries.conf的格式有两个版本，
版本1不支持镜像，需要改用版本2的格式来配置，如下：

```
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
insecure = false
blocked = false
location = "docker.io"
[[registry.mirror]]
location = "hub-mirror.c.163.com"
[[registry.mirror]]
location = "registry.docker-cn.com"

```

使用这个配置，下载镜像时，会按照如下顺序查找下载：

1. hub-mirror.c.163.com
1. registry.docker-cn.com
1. docker.io

经过上述配置后，就可以通过国内镜像源拉取镜像了，可以通过以下命令测试：

```
$ podman pull alpine
```

## 使用proxy

有时候，想在家里拉取公司的镜像，但公司镜像是内部地址，没有对外暴露。
如果有sshd可以访问公司网络，可以通过ssh建立一个隧道，使用proxy来拉取：


1. 建立隧道：

```
$ ssh -Nfq -D 10800 company.ssh.address
```

2. 通过隧道下载镜像

```
$ https_proxy=socks5:127.0.0.1:10800 podman pull uri/image
```

## 参考

* [containers-registries.conf.5.md](https://github.com/containers/image/blob/master/docs/containers-registries.conf.5.md)

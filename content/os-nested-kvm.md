
+++
title = "kvm in kvm"
date = "2021-05-12"

[taxonomies]
categories = ["os"]
tags = ["libvirt", "kvm"]
+++

# Kvm in kvm

## 确定CPU是否已经开启嵌套虚拟化

从kernel 4.20开始，kvm默认启用`nested`选项。
检查以下文件的值，如果输出是1或Y，则说明已经嵌套虚拟化

* Intel: `/sys/module/kvm_intel/parameters/nested`
* AMD: `/sys/module/kvm_amd/parameters/nested`

也可以用以下命令检查kvm是否开启了嵌套虚拟化，在kvm已经加载的情况下，可以通过`systool`检查，这里以`kvm_amd`为例：

```
$ systool -v -m kvm_amd|grep nested
    nested              = "1"
```

如果已经开启，直接跳过下一章节。

## 开启内核模块的嵌套虚拟化

新建或编辑`etc/modprobe.d/kvm.conf`文件，增加以下内容，使系统启动模块时，开启嵌套虚拟化：

```
options kvm_intel nested=1
options kvm_amd nested=1
```

在增加这些信息后，并不会马上生效，需要重启操作系统。

如果不想重启操作系统，可以先停掉所有的正在运行的虚拟机，
然后卸载，再重新加载对应的模块。这里以`amd`为例：

```
$ sudo modprobe -r kvm_amd
$ sudo modprobe kvm_amd
```

## 在 virt-manager 中开启嵌套虚拟化

新建虚拟机时，一般默认已经是选用了`Copy host CPU configuration`，也就是支持嵌入虚拟化。

可以在 virt-manager 中给某个虚拟机开启嵌套虚拟化，
在配置详情页面，点击`CPUs`选项，在`Configuration` 章节中，勾选`Copy host CPU configuration`选项.

## 存在的问题

### 虚拟机已经设置了host-model，但是svm仍然没有生效

按照上面修改后，检查客户机的`cpuinfo`仍然没有`svm`标志，

在宿主机上执行`virsh dumpxml`，发现`svm`是处于禁用状态的

```
$ virsh dumpxml --domain centos7.0|grep svm
    <feature policy='disable' name='svm'/>
```

通过`virsh edit centos7.0`查看，发现当前已经是`host-model`

```
  <cpu mode='host-model' check='partial'/>
```

通过修改配置文件规避

```
$ virsh edit centos7.0
```

在`cpu`中增加`svm`的feature(如果是intel，则是增加`vmx`)

```xml
  <cpu mode='host-model' check='partial'>
    <feature policy='require' name='svm'/>
  </cpu>
```

## 参考

* [using-nested-virtualization-in-kvm](https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/)
* [running-nested-guests](https://www.kernel.org/doc/Documentation/virt/kvm/running-nested-guests.rst)

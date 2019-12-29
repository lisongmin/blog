
+++
title = "在linux下如何设置一个文件夹让群组可读写
date = 2019-12-29T20:03:00+08:00

[taxonomies]
tags = ["acl"]
categories = ["os", "linux"]
+++

# 在linux下如何设置一个文件夹让群组可读写

有时候，我们想共享一个目录给一个组使用，所有组内的成员都可以在这个目录下新建文件，新文件可以被组内的其他人读写。
这就需要对目录进行权限访问的控制。

首先，我们平时创建文件的时候，文件的数组是用户的主组，权限根据用户默认的umask进行设置。如果没有修改默认权限，我们创建新文件的权限是这样的：

```
$ ls -l a
Alias tip: ll a
-rw-r--r-- 1 lsm lsm 0 12月 29 20:10 a
```

* 文件所属的组是用户的主组
* 用户本身可以读写
* 组默认只有可读权限，没有写权限

当我们共享文件夹给一个组时，我们希望达到的效果是：

* 属组固定为指定的组，这样组内的所有成员都可以读写
* 组的权限是可读写，而不是只读

同时，我们不想改变用户的默认配置，导致用户在其他目录下的行为也会发生变化，我们只想改变这个目录下的行为。
如何达成这个效果呢？

首先，我们通过`chmod g+s`来固化在这个目录下建立新文件，目录时使用的组.

假设我们有一个`test`目录，共享给整个`family`组

```
$ ls -l
drwxr-xr-x 2 lsm  family       40 12月 29 20:24 test
```

在没有增加`s`属性时，我们尝试在目录下新建文件，可以看到，属组并不是`family`:

```
$ touch test/befare+s
$ ls -l test
-rw-r--r-- 1 lsm lsm 0 12月 29 20:32 befare+s
```

现在我们增加`s`属性，再测试一次新增文件

```
$ chmod g+s test
$ touch test/after+s
$ ls -l test
-rw-r--r-- 1 lsm family 0 12月 29 20:43 after+s
-rw-r--r-- 1 lsm lsm    0 12月 29 20:32 befare+s
```

可以看到，增加`s`属性后，新建文件的属组已经是family了，第一个目的达成。

接下来，我们需要保证新增的文件可以由组内的其他人修改，即新建文件的组权限需要是`rw`.这个事情可以通过`setfacl`命令来达成。

```
$ setfacl -d -m g::rwx test
```

我们再新建一个文件看看效果

```
$ touch test/after-setfacl
$ ls -l test
-rw-r--r-- 1 lsm family 0 12月 29 20:43 after+s
-rw-rw-r-- 1 lsm family 0 12月 29 20:47 after-setfacl
-rw-r--r-- 1 lsm lsm    0 12月 29 20:32 befare+s
```

可以看到，新建的文件属组已经有可写的权限了。

## 总结

通过`chmod g+s`和`setfacl -d -m g::rwx`两个指令，可以使得某个目录创建的新文件在组内共享读写权限，而不影响用户在其他目录下的行为。

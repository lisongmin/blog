
+++
title = "I Read"
path = "i-read"
template = "about.html"
+++

# k8s

* 2020-04-19 阅读来自 [宋静超](https://jimmysong.io) 的 [Kubernetes Handbook](https://jimmysong.io/kubernetes-handbook/)
* 2020-03-21 阅读了 [Role based access control (RBAC) policies in Kubernetes](https://www.youtube.com/watch?v=CnHTCTP8d48)
* 2020-03-15 阅读了来自 Grigory Ignatyev 的 [4 ways to bootstrap a Kubernetes cluster](https://medium.com/containerum/4-ways-to-bootstrap-a-kubernetes-cluster-de0d5150a1e4)
* 2020-03-15 阅读了来自 Kunal Kushwaha 的 [How Container Runtimes matter in Kubernetes](https://events19.linuxfoundation.org/wp-content/uploads/2017/11/How-Container-Runtime-Matters-in-Kubernetes_-OSS-Kunal-Kushwaha.pdf)
* 2020-03-15 阅读了来自 Antonio Murdaca 的 [container runtimes: clarity](https://medium.com/cri-o/container-runtimes-clarity-342b62172dc3)
* 2020-03-15 阅读了来自 Alex Pollitt 的 [Comparing kube-proxy modes: iptables or IPVS](https://www.projectcalico.org/comparing-kube-proxy-modes-iptables-or-ipvs/)

# linux

* 2020-03-01 阅读了 [libvirt手册中关于自定义NAT网络的部分](https://jamielinux.com/docs/libvirt-networking-handbook/custom-nat-based-network.html)
* 2020-02-14 阅读了来自 Leo 的[Linux 下的字体调校指南](https://szclsya.me/zh-cn/posts/fonts/linux-config-guide/)
    - 很简洁高效的 linux 字体配置方案，可以直接拿过来就用的版本。

# c++

* 2020-04-02 阅读了来自 Sutter’s Mill 的 [GotW #100: Compilation Firewalls](https://herbsutter.com/gotw/_100/)
* 2019-06-02 阅读了来自 Mark Isaacson 的 [memcpy, memmove, and memset are obsolete!](http://maintainablecode.logdown.com/posts/159916-memcpy-memmove-and-memset-are-deprecated)
* 2019-06-27 阅读了来自 Eli Bendersky 的 [SFINAE and enable_if](https://eli.thegreenplace.net/2014/sfinae-and-enable_if) 学会了`enable_if`的用法
    - `enable_if`可以用于模板参数中
        ```c++
        template <class T,
                 typename std::enable_if_t<std::is_integral<T>::value>* = nullptr>
        void do_stuff(T& t) {
            // an implementation for integral types (int, char, unsigned, etc.)
        }
        ```
    - 可以用于函数的返回类型中
        ```c++
        template <class T>
        typename std::enable_if<std::is_arithmetic<T>, bool>::type
        signbit(T x)
        {
            // implementation
        }
        ```
    - 还可以用于模板函数的入参中，这个之前没有见过
        ```c++
        template <class _InputIterator>
        vector(_InputIterator __first,
               typename enable_if<__is_input_iterator<_InputIterator>::value &&
                                  !__is_forward_iterator<_InputIterator>::value &&
                                  ... more conditions ...
                                  _InputIterator>::type __last);
        ```

# security

* 2019-07-07 阅读了来自 Rammesh Lingappa 的 [What is session hijacking and how you can stop it](https://www.freecodecamp.org/news/session-hijacking-and-how-to-stop-it-711e3683d1ac/)
* 2019-07-07 阅读了来自 David Gilbertson [I’m harvesting credit card numbers and passwords from your site. Here’s how](https://hackernoon.com/im-harvesting-credit-card-numbers-and-passwords-from-your-site-here-s-how-9a8cb347c5b5)
    - 介绍了如何通过js注入, npm依赖包等方式窃取用户的信用卡信息的过程，以及如何设计web登录功能来避免这种攻击。
    独立的登录页面，以及无第三方js库是登录信息不被窃取的保证。
* 待阅读: [OAuth 2.0](https://ldapwiki.com/wiki/OAuth%202.0)

# python

* 2020-01-23 [sans I/O](https://sans-io.readthedocs.io/)
    - 理解无io网络协议的优点，开阔视野

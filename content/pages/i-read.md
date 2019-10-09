
+++
title = "I Read"
path = "i-read"
template = "about.html"
+++

# c++

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

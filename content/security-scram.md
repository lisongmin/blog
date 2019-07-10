
+++
title = "登录安全之scram"
date = 2019-07-11T22:30:00+08:00
draft = true

[taxonomies]
tags = ["sasl", "scram", "login"]
categories = ["security"]
+++


写这篇文章，主要是正在构建一个项目，需要实现web的登录模块。之前以为在https下，数据都是加密的，
所以已经可以保证不会泄密，可以在其中传递密码这种隐秘信息。但后来刷推的时候，看到一个观点，
任何时候，都不能在网络上传输密码信息，并对都9012了，还有直接在网络上传输密码的行为进行了diss.

作为明文传密码思想的一员，我很是汗颜，决定学习如何在不传输密码的情景下，完成用户验证的工作。

# 密码安全的风险点

密码在前端(web)输入，传输过程，后端存储等阶段都可能出现泄漏，在考虑密码安全时，需要先理解在各个阶段
存在哪些风险，如果在这个阶段泄漏，会造成什么样的后果。

## 前端(web)输入风险

前端输入风险主要存在于输入被劫持，并发送到攻击者的服务器，从而导致用户名，密码等信息泄漏。

David Gilbertson 的 [I’m harvesting credit card numbers and passwords from your site. Here’s how](https://hackernoon.com/im-harvesting-credit-card-numbers-and-passwords-from-your-site-here-s-how-9a8cb347c5b5)
详细介绍了前端攻击是怎么完成的，很精彩，推荐阅读。

攻击方式包括：

* 输入劫持
* 精心构建底层js依赖包，并推广给其他js包使用，一旦有js包使用这个依赖包，则相当于引入了特洛伊木马
* session id窃取， 参考Rammesh Lingappa 的 [What is session hijacking and how you can stop it](https://www.freecodecamp.org/news/session-hijacking-and-how-to-stop-it-711e3683d1ac/)

### 前端输入的防范措施

1. 开启CSP
1. 登录窗口不使用第三方js库，避免引入有问题的js包，确保输入安全
1. session id 需要开启http only以及secure选项，保证cookie不会被js读取

## 传输过程风险

在传输过程中，可能会遭到中间人攻击(man in the middle)，简称MITM，它的形式多种多样，这里介绍一些常见的：

* 如果是http协议，在局域网内通过tcpdump, wireshark等工具就可以将传输的内容抓取过来并解析。
* 如果是https，可以伪造一个服务器，这个服务器作为代理，从而截取到发送的数据，以及真正服务器返回的数据。
    * 需要伪造dns服务器，使得对某个网址的访问解析到伪造的代理服务器上
    * 主要针对自签名证书，这类证书浏览器都会弹出警告，用户会习惯性的忽略

在这个阶段，我们总是假定攻击者有手段获取到传输的数据。在这种情况下，如何保证密码等敏感信息不会被泄漏，
是我们需要考虑的问题。

首先，明文传输密码是不可取的，一旦受到攻击，立马就泄漏了。如果用户在其他网站使用的都是相同的用户名，密码，
这个危害还会扩散到其他网站上。

![login with plaintext](../assets/login-with-plaintext.svg)

在明文不可取的情况下，考虑使用散列来进行不可逆加密，只传递散列后的值，这样可以保护密码不会泄漏。这里不考虑
可逆加密算法，可逆意味着可能被破解，存在风险。但是只是使用散列的话，还是存在风险，攻击者获取到散列后，
通过散列，也可以直接登录服务器。在这种方案下，其他网站如果采用同样的算法，
攻击者也可以通过同样的散列登录。所以直接使用散列还是存在问题。

![login with hash](../assets/login-with-hash.svg)

如果是客户端自己生成盐值，加盐后再加密，由于盐值有客户端提供，并不能防范攻击者利用登录数据再次登录服务器。
所以这种方式并不能增强安全。

![login with salted hash](../assets/login-with-salted-hash.svg)

业界通用做法是通过服务端提供nonce，客户端使用nonce作为盐值进行加密，因为nonce是由服务端提供的一次性校验使用的值，
这个值在不同请求中会不断变化，所以攻击者在截取到登录信息后，并不能用于下一次客户端的登录，
从而实现在传输过程中不暴露密码，并且保证了登录数据不能用于下一次服务器登录。

![login with server nonce](../assets/login-with-server-nonce.svg)

从这里可以看到通过使用服务端提供的nonce来加密，可以规避中间人攻击导致的登录凭证泄露问题。


## 后端存储风险

我们首先要明确的是，服务端存储的登录凭证，需要保证即使泄漏了，攻击者也不能使用这个信息用于登录。

在服务器端，明文存储登录凭证是不可取的，直接跳过，而可逆加密需要将加密的凭证也保存在服务端，
所以攻击者总是有办法从服务端获取到足够的信息将加密的凭证解密出来。所以这种方式和明文存储
相差不到，不推荐使用。

那么剩下的就只有不可逆加密算法了。现在一般推荐使用的是Scrypt和较新的argon2。由于openssl不支持argon2，
如果是使用openssl，可以考虑采用Scrypt加密。

那么问题来了，加密后的凭证如何用来验证客户端加盐后的hash呢？我们存储的并不是密码，
所以并不能像客户端那样一步步生成hash然后比对。


![](../assets/scram-key-gen.svg)

![](../assets/scram-data-exchange.svg)

# 参考

* [Salted Challenge Response Authentication Mechanism](https://en.wikipedia.org/wiki/Salted_Challenge_Response_Authentication_Mechanism)
* [RFC-5802](https://tools.ietf.org/html/rfc5802)
* [MongoDB中使用的SCRAM-SHA1认证机制](https://yq.aliyun.com/articles/16919)
* [I’m harvesting credit card numbers and passwords from your site. Here’s how](https://hackernoon.com/im-harvesting-credit-card-numbers-and-passwords-from-your-site-here-s-how-9a8cb347c5b5)
* [What is session hijacking and how you can stop it](https://www.freecodecamp.org/news/session-hijacking-and-how-to-stop-it-711e3683d1ac/)


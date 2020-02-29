
+++
title = "nginx proxy_pass用法记录"
date = 2020-02-18T21:56:00+08:00

[taxonomies]
tags = ["nginx"]
categories = ["tools"]
+++

# nginx proxy_pass用法记录

proxy_pass 的语法为

```
proxy_pass URL
```

其中URL由以下几部分组成：

```
https://localhost:8000/uri/
|--1---|---2----|--3-|-4--|
```

1. 协议，https, http等
2. 域名
3. 端口（如果是标准端口，可以省略)
4. uri 部分，这部分可是可以省略的，根据实际情况填写。

在proxy_pass的用法中，是否填写uri，nginx的行为是不一样的：

* 如果填写了uri，location里面匹配的部分会被新的uri替代

    如，下面例子中，如果访问`/name/a.html`，这里location匹配到`/name/`,
    进入proxy_pass时，会把`/name/` 替换成`/`，所以就变成了访问`http://127.0.0.1/a.html`.

    ```
    location /name/ {
        proxy_pass http://127.0.0.1/;
    }
    ```

* 如果没有uri，会使用 location 传入的 request_uri (相当于透明传递？)

    同样的地址，如果配置成没有uri的形式，proxy_pass 访问的将是`http://127.0.0.1/name/a.html`

    ```
    location /name/ {
        proxy_pass http://127.0.0.1;
    }
    ```

## 参考

* [nginx proxy_pass](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass)

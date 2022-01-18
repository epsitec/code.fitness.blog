+++
categories = ["git"]
date = "2022-01-18T17:06:00+01:00"
title = "git detecting host provider for ..."
+++

If ever you see a message such as:

```sh
"info: detecting host provider for 'https://git.xxx.ch/'..."
```

you can tell `git` to use the generic provider when accessing your repository (in my example `git.xxx.ch`), so that it no longer has to probe it every time:

```sh
git config --global credential.git.xxx.ch.provider generic
```

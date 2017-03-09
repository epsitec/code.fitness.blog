+++
categories = ["ci", "docker", "javascript", "tools"]
date = "2017-03-08T12:16:36+01:00"
title = "Travis CI issue: local docker to the rescue"
+++

I am using Travis to run CI tests for our `electrum` packages.
Two weeks ago, my tests started to fail with a mysterious error
and I was unable to reproduce the problem on my machine:

> No such file or directory

## Running Travis CI in a local docker container

I decided to troubleshoot Travis locally in a Docker image as 
[explained on the Travis site](https://docs.travis-ci.com/user/common-build-problems/#Troubleshooting-Locally-in-a-Docker-Image).
For this, I first insalled the latest version of [Docker for Windows](https://docs.docker.com/docker-for-windows/install)
on my Windows 10 laptop.
Then, I got down to the command line in order to pull a pre-configured
Travis docker image and make sure that it was using the expected `node`
and `npm` versions:

* `docker run --name travis -dit quay.io/travisci/travis-ruby /sbin/init`
* `docker exec -it travis bash -l`
* `nvm install 5.10`
* `nvm use 5.10`
* `node --version` &rarr; `v5.10.1`
* `npm --version` &rarr; `3.8.3`

After that, I cloned and tried to install my project:

* `git clone https://github.com/epsitec-sa/electrum.git`
* `cd electrum`
* `npm install`

At that point, I had the same error message on my machine than what I
was [getting from Travis](https://travis-ci.org/epsitec-sa/electrum-arc/builds/205685786):

> No such file or directory

Great.

## Investigating locally, just like a Unix guru

I searched the web and found several mentions of people
having trouble to get `node` to work properly when `sudo` was used
in an `nvm` environment.

In my case, doing the `nvm install` and `nvm use` would not allow
me to do `sudo node --version` either. So I suspected that I would
have to [solve that issue](http://stackoverflow.com/questions/21215059/cant-use-nvm-from-root-or-sudo)
in order to get my Travis CI scripts to complete the tests.

## My hash-bang fails!

In my case, the package `electrum-require-components` could not be
executed. The definition of its `package.json` file pointed to a `*.js`
file as its binary:

```json
{
  ...
  "main": "lib/index.js",
  "bin": {
    "electrum-require-components": "./bin/bin.js"
  },
  ...
}
```

and `bin.js` was a very simple file starting with a hash-bang:

```js
#!/usr/bin/env node

require ('../lib/index.js');
```

By applying the `nvm` hack found on
[stack overflow](http://stackoverflow.com/questions/21215059/cant-use-nvm-from-root-or-sudo),
I was able to get my tests to run. But I did not find this solution to be
really satisfying, as I have other packages which also rely on JavaScript
node scripts, and which work without the hack.

## When following the naming conventions helps

I finally solved my problem by _renaming_ `bin.js`
to `electrum-require-components`.

So, did I trip on some weird behaviour
in `npm`? Probably, but this no longer matters, since I have a functional
CI again, and a lot of real work to do.

+++
categories = ["JavaScript"]
date = "2016-02-11T09:57:40+01:00"
title = "Require self and Wallaby.js"
+++

This post talks about how Wallaby.js can be integrated with
`require-self` while transpiling the module from ES2015 to
ES5 for npm distribution.

## Wallaby.js

[Wallaby.js](http://wallabyjs.com/) is a real-time test runner.
I am using it in my editor to get instant feed-back while typing
JavaScript code. It is amazing to have these questions answered
in real-time :

* Is the syntax correct?
* Does this compile and run?
* What are the values of my variables?
* Are my tests still all green?
* What is my code coverage?

See Scott Hanselman's [blog on Wallaby.js](http://www.hanselman.com/blog/WallabyJSIsASlickAndPowerfulTestRunnerForJavaScriptInYourIDEOrEditor.aspx)
who instantenously fell in love with it.

## Require self

I blogged about [require-self](http://code.fitness/post/2015/11/npm-require-self.html)
which allows me to write, inside module `foo`:

```javascript
import Foo from `foo`;
```

just as if `foo` were an external module. This is really
useful when working in deeply nested source trees, where
getting back to the root is clumsy, at best, with `../../..`
(or maybe `../../../..`).

# Get Wallaby to work with require-self

I badly wanted to make Wallaby work with `require-self`. My
first attempt in December 2015 did not get me anywhere
(see [this issue](https://github.com/wallabyjs/public/issues/367)).

I decided to follow another route.

I modified the `node_modules/foo.js` produced by `require-self`,
so that it would point at `../src/index.js` (thus matching my
`package.json` main entry point), then subitted a
[pull request](https://github.com/yortus/require-self/pull/4).
_yortus_ pointed out that it should work with a plain `..`
reference and that I should rather look for a solution with
Wallaby.js.

My [issue](https://github.com/wallabyjs/public/issues/449) was
quickly resolved by Artem Govorov:

```json
    files: [
      ...
      {pattern: 'node_modules/foo.js'},
      {pattern: 'package.json', instrument: false}
    ],
```

At last, I had a running solution with `require-self`. Great!

# But I can't publish to npm!

Artem's solution worked, but when I decided to use it in a module
where I need to transpile `./src/index.js` to `./lib/index.js` using
Babel, I was faced with this dilemma:

* Make Wallaby.js work and use `"main": "src/index.js"` in
  the `package.json` file. But this does not allow me to
  publish the npm package.
* Make NPM work and use  `"main": "src/index.js"` in
  the `package.json` file. But this confuses Wallaby.js,
  since it is no longer looking at my _live_ source code.

Hence this [issue](https://github.com/wallabyjs/public/issues/453).

Once again, Artem came to the rescue: patch `require()` (as he
already [suggested in December 2015](https://github.com/wallabyjs/public/issues/449))
and forget about the previous solution. But this time, he included
a full snippet of how to do it.

Here is the final version of my `bootstrap(wallaby)` function
found in `wallaby.conf.js`:

```javascript
    bootstrap: function (wallaby) {
      // See http://wallabyjs.com/docs/config/bootstrap.html
      var path = require ('path');

      // Ensure that we can require self (just like what module 'require-self'
      // does), but remapping by default the path to './src' rather than './lib'
      // as specified by package "main".
      var packageConfig = require (path.join (wallaby.localProjectDir, 'package.json'));      var packageName = packageConfig.name;
      var modulePrototype = require ('module').Module.prototype;
      if (!modulePrototype._originalRequire) {
        modulePrototype._originalRequire = modulePrototype.require;
        modulePrototype.require = function (filePath) {
          if (filePath === packageName) {
            return modulePrototype._originalRequire.call (this, path.join (wallaby.projectCacheDir, 'src'));
          } else {
            return modulePrototype._originalRequire.call (this, filePath);
          }
        };
      }
      ...
    }
```

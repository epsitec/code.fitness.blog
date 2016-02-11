+++
categories = ["JavaScript"]
date = "2016-02-11T10:44:13+01:00"
title = "Mocha tests and require self"
+++

In my [last post](npm-require-self-with-wallaby.html) I showed
how to make `require-self` work smoothly with Wallaby.js.

But if you are like me, you also want to continue to run your
`mocha` tests on a regular basis, for instance on a **CI**
server. In this case, some additional work is required to get
`require-self` to work smoothly with `mocha` too.

I have a `test/mocha.opts` file which contains the basic
settings for running `mocha` with Babel. Add a `--require`
option to inject `test-require-patch.js`:

```
--require ./test/test-require-patch.js
```

And here is the `test/test-require-patch.js` source file:

```javascript
/*globals __dirname */
'use strict';

var path = require ('path');
var root = path.join (__dirname, '..');
var packageConfig = require (path.join (root, 'package.json'));
var packageName = packageConfig.name;
var modulePrototype = require ('module').Module.prototype;

if (!modulePrototype._originalRequire) {
  modulePrototype._originalRequire = modulePrototype.require;
  modulePrototype.require = function (filePath) {
    if (filePath === packageName) {
      filePath = path.join (root, 'src');
    }
    return modulePrototype._originalRequire.call (this, filePath);
  };
}
```

It will redirect any reference to the module using `require('foo')`
to `src/index.js`.

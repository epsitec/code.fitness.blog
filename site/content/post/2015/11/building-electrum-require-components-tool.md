+++
categories = ["JavaScript"]
date = "2015-11-26T15:35:26+01:00"
title = "Building a JavaScript command line tool"
+++

As I explained in an [earlier post](javascript-es2015-dynamic-import.html),
I decided to create a command line tool which would be invoked by
an `npm run` command.

The source code of `electrum-require-components` is
[on GitHub](https://github.com/epsitec-sa/electrum-require-components).

## What does it do?

The tool will be invoked like this:

```cmd
electrum-require-components --wrap ./src components .component.js auto.js
```

It starts in `./src` where it walks recursively through the subdirectories,
starting with `components`. In every subdirectory, it looks for all files
which end with `.comp.js`. Then, it outputs a series of imports and exports
into source file `auto.js`:

```javascript
'use strict';
import {E} from 'electrum';
import Overlay from './components/extras/Overlay.component.js';
import Footer from './components/footers/Footer.component.js';
import Link from './components/links/Link.component.js';
module.exports.Overlay = E.wrapComponent ('Overlay', Overlay);
module.exports.Footer = E.wrapComponent ('Footer', Footer);
module.exports.Link = E.wrapComponent ('Link', Link);
```

The `--wrap` options adds the calls to `E.wrapComponent()`.

## Walking the directories

It is the first project I wrote for **node.js** and I wanted to
be a good citizen. So I decided to go _asynchrounous_ all the way
down.

To explain how this works, I'll take the example of the `traverse()`
function which given a `root` directory and an array `dirs` of
intermediate directories calls the `collect` callback on every
file entry, and when it is done, it calls the last provided callback.

```javascript
let result = [];

function collect (dirs, file) {
  const filePath = [...dirs, file].join ('/');
  result.push ([name, filePath]);
}

traverse ('./src', ['components'], collect, err => {
  if (err) {
    next (err);
  } else {
    next (err, result);
  }
});
```

And here comes the code for the `traverse` function:

```javascript
function traverse (root, dirs, collect, next) {
  const rootPath = path.join (root, ...dirs);
  fs.lstat (rootPath, (err, stats) => {
    if (err) {
      next (err);
    } else {
      // ...
    }
  });
}
```

The first asynchronous operation is the call to `fs.lstat()`
which is used to find out if the root path is a directory.
It calls the `(err, stats) => {}` callback asynchronously,
when the file system has done its work. We first check for
an error, which would stop further processing and notify
the caller by the way of `next(err)`. If everything is OK,
then the following code gets executed:

```javascript
fs.readdir (rootPath, (err, files) => {
  for (let file of files) {
    const filePath = path.join (root, ...dirs, file);
    fs.lstat (filePath, (err, stats) => {
      if (err) {
        next (err);
      } else {
        // ...
      }
    });
  }
});
```

We read the directory (asynchronously), for every entry
we check (asynchronously) we get its `stats` to decide
what to do: it might be a file or a directory.

```javascript
if (stats.isDirectory ()) {
  traverse (root, [...dirs, file], collect, err => {
    if (err) {
      next (err);
    } else {
      // ...
    }
  });
} else {
  if (stats.isFile ()) {
    collect (dirs, file);
    // ...
  }
}
```

If it is a directory, we recursively walk the rest of the
tree (also asynchronously), handling potential errors which
could happen there. If it is a file, we notify the `collect()`
callback with the current array of subdirectories `dirs`
and the `file`.

## But... where are my results?

Running this code will not produce any result, as we did not
call the `next()` callback from within `traverse()` in case
of success.

But when do we know that we are done? We have to add some
bookkeeping code in our `traverse()` function (basically a
counter called `pending` which must reach zero when iterating
over the files in the `for .. of` loop).

## The real implementation

```javascript
function traverse (root, dirs, collect, next) {
  const rootPath = path.join (root, ...dirs);
  fs.lstat (rootPath, (err, stats) => {
    if (err) {
      next (err);
    } else {
      fs.readdir (rootPath, (err, files) => {
        let pending = files.length;
        for (let file of files) {
          const filePath = path.join (root, ...dirs, file);
          fs.lstat (filePath, (err, stats) => {
            if (err) {
              next (err);
            } else {
              if (stats.isDirectory ()) {
                traverse (root, [...dirs, file], collect, err => {
                  if (err) {
                    next (err);
                  } else {
                    if (--pending === 0) {
                      next ();
                    }
                  }
                });
              } else {
                if (stats.isFile ()) {
                  collect (dirs, file);
                  if (--pending === 0) {
                    next ();
                  }
                }
              }
            }
          });
        }
      });
    }
  });
}
```

A little bit of refactoring would bring the indentation
level down. Or going `async` and `await`...

# Creating the command line tool

Once the traversal and source code generation were in place,
I wrote the code to parse the command line (basically looking
at `process.argv` after skipping the two first arguments).

To make it work as an npm package, there is some more work
to do.

## Add a `"bin"` section in the `package.json` file.

```json
"bin": {
  "electrum-require-components": "./bin/bin.js"
}
```

## Add a source file `./bin/bin.js` with a UNIX header

The source header is required so that node gets picked up
to execute the file, and not `scriptjs` on Microsoft Windows.

```javascript
#!/usr/bin/env node
require ('../lib/index.js');
```

## Make sure we export ES5

In order to get the package compiled down to ES5, so that it
can be used without Babel once installed, don't forget to add
a `prepublish` action in `package.json`:

```json
"scripts": {
  "compile": "babel -d lib/ src/",
  "prepublish": "npm run compile",
  "test": "mocha src/test/**/*.js"
}
```

# Using the command line tool

Now it is time to use our new command line tool inside another project.
To use it, add the package to the `devDependencies` section of your
`package.json`:

```cmd
npm install electrum-require-components --save-dev
```

Then edit `package.json` to call the script when compiling. Change this:

```json
"scripts": {
  "compile": "babel -d lib/ src/",
  "prepublish": "npm run compile"
}
```

into this:

```json
"scripts": {
  "compile": "npm run regen && babel -d lib src",
  "prepublish": "npm run compile",
  "regen": "electrum-require-components --wrap ./src components .component.js all-components.js"
}
```

> Note: I added the `regen` action to make it more convenient to use,
but you could invoke `electrum-require-components` directly instead of
using `npm run regen`.

From now on, I can simply add a new `Foo.component.js` file somewhere in
a folder below `./src/components` and it will be picked available through
`all-components.js`, like this:

```javascript
import {Foo} from './all-components.js';
```

# References

* [Building a simple command line tool with npm](http://blog.npmjs.org/post/118810260230/building-a-simple-command-line-tool-with-npm).
* [Executing a project-specific Node/npm package à la "bundle exec"](https://lostechies.com/derickbailey/2012/04/24/executing-a-project-specific-nodenpm-package-a-la-bundle-exec/).

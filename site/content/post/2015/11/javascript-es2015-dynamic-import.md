+++
categories = ["JavaScript"]
date = "2015-11-25T13:52:53+01:00"
title = "Dynamic import with ES2015"
+++

In the code base I am currently working on, we have a deep tree of folders,
each of which contains one or more _React web components_. Rather than having
to maintain manually a long list of `require`s or `import`s, my colleague
[Samuel Loup](https://github.com/samlebarbare) came up with this piece of
code:

```javascript
var components = {};
var instances  = {};
var req        = require.context ('./components/', true, /\.component\.js$/);
var files      = req.keys ();

files.forEach (function (file) {
  var componentId   = req.resolve (file);
  var component     = __webpack_require__ (componentId);
  var matches       = file.match (/([^\/\\]+)\.component\.js$/);
  var componentType = matches[1];
  components[componentType] = component;
});
```

Here is what it does:

* It dynamically requires a list of all source files found in the `components`
  folder, matching `*.component.js` (e.g. `components/forms/fields/IconField/IconField.component.js`).
* For each file, it extracts the component name, derived directly from the
  file path (e.g. `IconField`).
* It builds a collection of components, indexed by the component name.

With this in place, accessing a component is as simple as:

```javascript
const {IconField} = components;
```

## No dynamic import in ES2015

This solution works only if the source code is fed through WebPack, since
the `require.context` dynamic import is a feature provided by WebPack.
How can we get the same behaviour with pure ES2015 code? _Dynamic imports_ are
**not supported** by the language, so this looks like a dead end.

So we have to build the list of `require`s at compile time, with an external
tool.

I started down two roads:

* Building a **WebPack loader**. The loader would produce a list of requires
  and inject them into my source code. With my limited knowledge of how
  WebPack works, it proved to be too difficult to implement in a short time
  span. And I'd like to get rid of WebPack, as it does not play well with
  my current continuous testing setup (Wallaby.js inside the Atom editor).

* Building a **Babel 6 plug-in**. The plug-in would work like the _loader_
  and inject source code on the fly. With the current lack of documentation
  after the switch from Babel 5 to Babel 6, I gave up after scratching the
  surface of Babel's plug-in architecture and transform pipeline.

The simple replacement of Samuel's code was turning into a big pile of
work. And that is not where I want to spend my time right now.

## A simple solution

After playing a bit with the `prepublish` step of npm, I finally decided
to write a
[tiny tool](https://github.com/epsitec-sa/electrum-require-components)
which would produce the list of requires on demand, just before invoking `babel -d lib/ src/`.

[Read more about how the tool was built](building-electrum-require-components-tool.html).

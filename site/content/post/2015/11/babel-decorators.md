+++
categories = ["JavaScript"]
date = "2015-11-15T11:47:11+01:00"
title = "WTF? My decorators don't do anything"
+++

With Babel 5.x it was possible to use the
[`@decorator`](https://github.com/wycats/javascript-decorators)
syntax by just enabling the `state-0` language features.

Here is a simple class decorator:

```js
@annotation
class Foo {}

function annotation(target) {
  // Add a property on target
  target.annotated = true;
}
```

Adding the `babel-preset-stage-0` module and configuring Babel
accordingly in the `.babelrc` to include `"stage-0"` before `"es2015"`
makes Babel consume the source code without complaining. But that's
all, nothing happens.

After digging around I finally discovered that I had to include a
specific plugin for this to work.

Install module `babel-plugin-transform-decorators` and change the
`.babelrc` configuration to this:

```json
{
  "presets": ["stage-0", "es2015", "react"],
  "plugins": ["transform-decorators"]
}
```

And, tada...

> SyntaxError: foo.js: Decorators are not supported yet in 6.x pending proposal update.

For now, Babel 6.x has **removed support** for decorators.

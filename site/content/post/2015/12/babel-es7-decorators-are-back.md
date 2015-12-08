+++
categories = ["JavaScript"]
date = "2015-12-08T15:59:00+01:00"
title = "ES7 decorators are back in Babel 6.x"
+++

In November 2015, I was [writing](../11/babel-decorators.html)
that decorators had been ripped out of Babel 6.

Now, they are back.
Install [`babel-plugin-transform-decorators-legacy`](https://www.npmjs.com/package/babel-plugin-transform-decorators-legacy)
and update `.babelrc` to include the _legacy decorators transform_:

```javascript
{
  "presets": ["stage-0", "es2015", "react"],
  "plugins": ["transform-react-display-name", "transform-decorators-legacy"]
}
```

I can now use an `@foo` decorator to wrap a class and add
a `bar()` method to it:

```javascript
// The @foo decorator is just a function
function foo (x) {
  return class Bar extends x {
    name () {
      return 'bar';
    }
  };
}


// Apply the decorator to class Foo...
@foo
class Foo {
  name () {
    return 'foo';
  }
}

const foo = new Foo ();

// Foo is in fact Bar
expect (foo.name ()).to.equal ('bar');
```

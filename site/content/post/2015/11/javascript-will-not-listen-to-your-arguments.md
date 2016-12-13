+++
categories = ["js"]
date = "2015-11-23T05:30:22+01:00"
title = "I will not listen to your arguments"
+++

To reach into the arguments of a function, I [explained here](javascript-function-arguments-do-not-slice.html) that you should
write:

```javascript
function () {
  const args = new Array (arguments.length);
  for (var i = 0; i < args.length; ++i) {
    args[i] = arguments[i];
  }
  // do whatever you want with the args array
}
```

## Arguments belong to the past

As Kyle Simpson explains in his book [You Don't Know JS: ES6 & Beyond](https://www.safaribooksonline.com/library/view/you-dont-know/9781491905241/ch02.html), ES2015 comes with a feature called [rest parameters](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions/rest_parameters), which uses the same `...` syntax as spreads.

```javascript
function(...args) {
  // do whatever you want with the args array
}
```

This is the preferred way of reaching into a function's `arguments`. So
rather than resorting to the optimization presented in [this post](javascript-function-arguments-do-not-slice.html), simply use the
**rest parameters**.

## Rest parameters or `arguments`?

There are a few differences, though:

* Rest parameters only contain the _remaining parameters_ whereas `arguments`
  contains all parameters. The difference would be visible in `function foo(a, b, ...args)` where `a` and `b` would not show up in `args`, but would be
  present in `arguments`.

* The rest parameters are a real `Array`, whereas `arguments` is not.

* The rest parameters does not have additional properties, whereas the
  `arguments` object contains properties `callee` and `length`, and in
  some cases also `caller` (which has been deprecated).

## What is Babel doing?

The current version of Babel (6.2.1) transpiles this ES2015 code:

```javascript
function join (...args) {
  console.log (args);
}
```

to this plain ES5 source:

```javascript
function join() {
  for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
    args[_key] = arguments[_key];
  }
  console.log (args);
}
```

There is no surprise in this code. It is about the same as I [would have done
manually](javascript-function-arguments-do-not-slice.html).

+++
categories = ["JavaScript"]
date = "2015-11-14T11:55:11+01:00"
title = "JSHint is complaining about my ES7 code"
+++

ES2015 source code is identified correctly by current versions of JSHint
(as of this writing, Atom `jshint` package has version 1.8.3). However,
trying to use experimental (`stage-0`) language features like _decorators_
produces error messages:

```javascript
@bar
class Foo {
}
```

JSHint displays:

> JSHint 1:1 Unexpected token ILLEGAL

**This is by design**. You can't do anything about it. Don't spend hours
trying to find a setting which would enable support for the `stage-0`
language features – you won't find any.

The JSHint Team [explains how new language features
will get added to JSHint](http://jshint.com/blog/new-lang-features/) and
why `stage-0` and `stage-1` won't be included, even in the foreseeable
future.

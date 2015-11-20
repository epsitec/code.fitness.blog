+++
categories = ["JavaScript"]
date = "2015-11-20T05:43:46+01:00"
title = "Don't call my constructor!"
+++

I have implemented a `Store` class which comes with a static factory
method `Store.create()`, and I don't want users to call the store's
constructor directly:

```javascript
'use strict';

class Store {
  constructor (id) {
    this._id = id;
  }

  static create (id) {
    return new Store (id);
  }
}

module.exports = Store;
```

Ideally, I'd like to make `constructor()` private, but this concept
does not exist in ES2015. So if I can't hide the constructor, I want
to forbid any direct calls. And tell the user what to do instead, if
she does indeed mistakenly call `new Store()`.

## Check who's calling

Here is the solution I have come up with:

```javascript
'use strict';

const secret = {};

class Store {
  constructor (id, key) {
    if (key !== secret) {
      throw new Error ('Do not use new Store(): call Store.create() instead')
    }
    this._id = id;
  }

  static create (id) {
    return new Store (id, secret);
  }
}

module.exports = Store;
```

The constructor will only work if the caller passes in the expected
`secret`. And since the object is only visible from inside the module,
it cannot be passed in accidentally (`{}` is not equal to `secret` in
the `!==` comparison).

+++
categories = ["javascript"]
date = "2016-04-20T07:02:22+02:00"
title = "Store immutability and the freezer"
+++

I've already blogged about `Electrum`
(see [electrum on GitHub](https://github.com/epsitec-sa/electrum))
a few times in the past. The
project is maturing and getting larger, with colleagues starting to
actively contributing.

One of the sub-projects (`electrum-store`) implements an immutable
store. The store can be pictured as a tree of nodes (the state
objects). Every node can contain values and is itself a tiny immutable
key/value store.

Here is a simple example:

```javascript
let store = Store.create ();
let state;

state = store.select ('a.b.c');
state = state.set ('x', 10);
state = state.set ('y', {foo: 'bar'}); 
```

With this in place, we can read back the state:

* `state.get ('x')` &rarr; `10`
* `state.get ('y')` &rarr; `{foo: 'bar'}`

## An immutable store storing mutable data

When setting an object like `{foo: 'bar'}` in previous example,
the store itself can be considered immutable, but nothing prevents
anyone to mutate the stored item:

```javascript
state.get ('y').foo = 'bozo';
```

I don't like the idea of users mistakenly altering the state,
because this might introduce hard to locate bugs. In our case,
the store is used to speed up checking for changes: components
can check whether the state changed by simply doing a reference
comparison and provides a very efficient implementation of React's
`shouldComponentUpdate()` method.  

However, if a user mutates an object stored in the state, this
will not be detected, and the UI won't be refreshed.

## Freezing the mutable values

In `electrum-store` v2.0.0, I decided to address this issue and
`set()` now freezes the values stored in the state object. Code
like this will throw an exception:

```javascript
state.get ('y').foo = 'bozo'; // throw exception, object is frozen
```

Ideally, I'd love to have only fully immutable values (i.e. with
a deep freeze, walking recursively through the property graph),
but this might not be practical, because it would mean that we
can no longer store complex objects in the state, without freezing
the world.

So for now, `set('y', {foo: zzz})` only freezes `{foo: zzz}` at
the top level and `zzz` will stay unfrozen.

## Freezing arrays deeply

The state may also store arrays. Setting an array on a state object
will freeze the array recursively, until objects are reached.

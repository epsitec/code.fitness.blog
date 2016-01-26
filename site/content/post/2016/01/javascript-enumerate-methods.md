+++
categories = [""]
date = "2016-01-26T18:07:06+01:00"
title = "Enumerating methods on a JavaScript class instance"
+++

I thought that enumerating methods on a class instance would be
as easy as just looping over the property names, checking whether
they are of type `function`, and voilà.

But it is not.

Let's build `getInstanceMethodNames(obj)` together.

## First attempt

My first attempt simply retrieves the _prototype_ of the object
being passed to my method, then lists all property names and 
finally checks their types:

```javascript
function getInstanceMethodNames (obj) {
  const proto = Object.getPrototypeOf (obj);
  const names = Object.getOwnPropertyNames (proto);
  return names.filter (name => typeof obj[name] === 'function');
}
```

There are several issues with this implementation:

1. It returns the `constructor` which I do not consider as a
   standard method; filtering this out is easy with a condition
   on the _name_.
2. It does not return inherited methods (up the protoype chain).
   If you are not familiar with how inheritance works in JavaScript,
   I suggest you spend some time reading [Inheritance and the
   prototype chain](https://developer.mozilla.org/en/docs/Web/JavaScript/Inheritance_and_the_prototype_chain)
   on MDN.
3. It crashes mysteriously in some cases.

## Second attempt, let's walk the prototypes

Here is my second version, which loops over the prototypes until
it reaches the end (which is identified by `Object.getProrotypeOf`
returning `null`):

```javascript
function getInstanceMethodNames (obj) {
  let array = [];
  let proto = Object.getPrototypeOf (obj);
  while (proto) {
    const names = Object.getOwnPropertyNames (proto);
    names.forEach (name => {
        if (name !== 'constructor' && typeof obj[name] === 'function') {
          array.push (name);
        }
      });
    proto = Object.getPrototypeOf (proto);
  }
  return array;
}
```

This works well... until you feed it an instance of this class:

```javascript
class X {
  foo () {}
  get bar () { return whatever (); }
}
```

Do you see what might be going wrong here?

## Dereferencing can be treacherous

You have probably guessed by now what might go wrong, do you?

When getting the names, the _for each_ loop will check `foo` and
`bar` and verify if `obj['foo']` and `obj['bar']` are functions.

* `obj['foo']` &rarr; returns the function `foo`.
* `obj['bar']` &rarr; executes the _getter_, just like `obj.bar`
  would... and the result of `whatever ()` might cause some
  surprises.

What might go wrong?

* The getter might have a side effect; enumerating the methods of
  a class instance should not produce side effects.
* The getter might be slow.
* The getter might return a function; if so, the code would then
  be mistaken and classify the getter as a method.
* The getter might **throw an exception**.

While testing my code, I became aware of the issue because I was
getting an exception on a property somewhere up the inheritance
chain, while looking for methods. It took some time for me to
understand what was going on.

## Final version 

In order to have a robust version of `getInstanceMethodNames(obj)`
we must avoid dereferencing the properties. So we need another
way to inspect the prototypes.

```javascript
function hasMethod (obj, name) {
  const desc = Object.getOwnPropertyDescriptor (obj, name);
  return !!desc && typeof desc.value === 'function';
}
```

`Object.getOwnPropertyDescriptor` returns a _property descriptor_
which can then be inspected. See the [documentation on MDN](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyDescriptor).
The descriptor is a record with one essential attribute, the
`value`. We can peek at the value and check if it is a function.
If the property is a getter or a setter, `value` is not defined
(but `get` or `set` are). This avoids any confusions between
real functions (methods) and other data types.

Here is the final version of  `getInstanceMethodNames(obj)`:
 
```javascript
function getInstanceMethodNames (obj, stop) {
  let array = [];
  let proto = Object.getPrototypeOf (obj);
  while (proto && proto !== stop) {
    Object.getOwnPropertyNames (proto)
      .forEach (name => {
        if (name !== 'constructor') {
          if (hasMethod (proto, name)) {
            array.push (name);
          }
        }
      });
    proto = Object.getPrototypeOf (proto);
  }
  return array;
}
```

The `stop` argument is optional and can be used to stop looking
for methods at some point in the prototype chain. When working
with React components, I pass `React.Component.prototype` as the
_stop_ value, so that only my own component's methods get listed.

Note: this code was taken from [Electrum](https://github.com/epsitec-sa/electrum).

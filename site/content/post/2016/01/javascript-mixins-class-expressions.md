+++
categories = [""]
date = "2016-01-12T20:43:59+01:00"
title = "Mixins through class expressions"
+++

I've just came across [Justin's Fagnani blog post](http://justinfagnani.com/2015/12/21/real-mixins-with-javascript-classes/).
The basic idea is simple. Use `class` as an _expression which returns a new class_
while also using an _expression_ for the `extends` clause:

```javascript
let Mixin = (base) => class extends base {
  hello () {
    console.log ('Mixin saying hello...');
  }
};

class BaseClass { /* ... */ }

class ClassWithMixin extends Mixin (BaseClass) { /* ... */ }
```

I've been using this pattern in Electrum to extend a component
by creating an (anonymous) class which extends the provided
input class:

```javascript
export default function extendComponent (component /* ... */) { 
  /* ... */ 
  return class extends component { 
    constructor (props) { 
      super (props); 
      /* ... */; 
    }
  }
}
```

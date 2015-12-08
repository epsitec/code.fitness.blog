+++
categories = ["JavaScript"]
date = "2015-12-08T15:48:25+01:00"
title = "ES6 export with wildcard, Babel 6.x bug"
+++

ES6 comes with a handy `export * from '...';`
[statement](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export)
which can be used to export everything that is exported
by a given module. I was trying to get this to work with
Babel 6.x:

```javascript
export * from './all.js';
```

I don't know what's inside `all.js`, so exporting with
a _wildcard_ makes perfect sense, as I cannot enumerate
the symbols I'd like to get exported from the import.
 
However, with the version of Babel 6.x I am using, I consistently
get this error message:

> Invariant Violation: To get a node path the parent needs to exist

There is an [issue](https://phabricator.babeljs.io/T2763) on
Babel's bug tracker and also a [PR](https://github.com/babel/babel/pull/3137)
for an upcoming release of Babel.

In the meantime, the cleanest workaround I have come up with is
to first import everything, then export with the wildcard:

```javascript
import * as all from './all.js';
export * from './all.js';
```

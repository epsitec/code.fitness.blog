+++
categories = ["js"]
date = "2017-01-09T06:36:12+01:00"
title = "Measuring performance in JavaScript"
+++

In order to measure the time taken to execute a piece of JavaScript,
one of the solutions provided by both the browsers and node is to use
`console.time(label)` and `console.timeEnd(label)`, as explained on
[MDN](https://developer.mozilla.org/en-US/docs/Web/API/Console/time).

```js
console.time ('perf');
// ...do whatever takes time...
console.timeEnd ('perf');
```

This will display a message to the console:

> perf: 114.660ms

## How can we get the time back?

The `console` API is great for just printing out the time taken by
a piece of code, but it does not return the total elapsed time. In
the browser, the `Window.performance` API provides a solution, but
it is not available when executing tests inside node or Wallaby.js.

So let's use [`process.hrtime`](https://nodejs.org/api/process.html#process_process_hrtime_time)
in these cases:

```js
function clock (start) {
  if (start) {
    const end = process.hrtime (start);
    return (end[0] * 1000) + (end[1] / 1000000);
  } else {
    return process.hrtime ();
  }
}
```

And here is how you'd use it:

```js
const perf = clock ();
// ...
const ms = clock (perf); // elapsed milliseconds
```

## Asserting execution time with mai-chai

When using `mai-chai`, I can assert on the execution time by
writing:

```js
import {clock} from 'mai-chai';

const perf = clock ();
// ...
expect (clock (perf)).to.be.at.most (150);
```

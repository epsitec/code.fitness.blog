+++
categories = ["html", "javascript"]
date = "2016-06-12T14:36:37+02:00"
title = "Smoothly scroll to some absolute vertical position (HTML)"
+++

I was working on [camt.li](http://camt.li) and wanted to make the page scroll
a bit to display the results of a file analysis, when they became available.

I Googled around quite a bit, found lots of implementations based on jQuery,
and a few which would work in plain JavaScript.

Here is the final ES2015 version I've finally decided to use:

```javascript
function scrollTo (to, duration) {
  const doc       = document.documentElement;
  const body      = document.body;
  const start     = doc.scrollTop;
  const change    = to - start;
  const increment = 20;

  function easeInOutQuad (t, b, c, d) {
    t = t / (d / 2);
    if (t < 1) {
      return c / 2 * t * t + b;
    } else {
      t--;
      return -c / 2 * (t * (t - 2) - 1) + b;
    }
  }

  let currentTime = 0;

  function animateScroll () {
    currentTime += increment;
    const val = easeInOutQuad (currentTime, start, change, duration);
    doc.scrollTop  = val; // for IE
    body.scrollTop = val; // for Chrome
    if (currentTime < duration) {
      setTimeout (animateScroll, increment);
    }
  }
  animateScroll ();
}
```

Nothing really fancy here, really. And no need for jQuery.

Just call `scrollTo (400, 1000)` to have the page scroll smoothly to the
absolute position of `600px` in `1000` milliseconds (this will result in
50 scrolls, since the increment is set to 20).

The code for `easeInOutQuad` was adapted from [Easing Equations from Robert Penner](http://gizma.com/easing/)
and basically provides two quadratic curves (one where the time goes from zero
to half the duration, another for the rest of the time).

Note however that IE and Chrome require to set `scrollTop` on different DOM
objects; I don't detect the browser, but rather just set the position on
both the document object and on the DOM body.

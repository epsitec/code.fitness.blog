+++
categories = ["electrum"]
date = "2016-01-05T08:50:26+01:00"
title = "Electrum Style Functions"
+++

I blogged about the [style function](/post/2015/12/electrum-themes-and-components.html)
a two weeks ago. Its goal is to produce a _style object_ based on
an input _theme_. While discussing the topic with my colleagues, the idea of
using a **class** rather than a function to produce the style object emerged.

At first, I found the idea attractive: using classes naturally allows inheritance
of styles, mirroring the same inheritance tree as the components they belong to.

Then I remembered Dan Abramov's [tweet](https://twitter.com/dan_abramov/status/645271668378705920):

> Stateless pure function components in React 0.14 is one of the reasons you
> **don't want to use inheritance** for your component wrappers.

## Think functional

Using a JavaScript `class` does not really give us any advantages over functions.

In React, stateless components can be defined directly by a function. No need to
use a class. So why should we use classes to replace the _style function_ while
at the same time trying to replace component classes by functions? It does not
make sense.

We should think of **composition** rather than **inheritance** when dealing with
the style functions.

## Composing the style of a derived component

Say we have a style function for a container component:

```javascript
// container.styles.js
export default function (theme) {
  return {
    base: {
      includes: ['resetList'],
      display: 'flex',
      flexDirection: 'column',
      flexWrap: 'nowrap',
      backgroundColor: theme.colors.lightBlue50
    }
  };
}
```

For a specialized component which organizes its content horizontally, we should
not have to duplicate the above style function. Instead, we should build on it
and specify a different [flex direction](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)
while keeping everything else unchanged:

```javascript
// flow-container.styles.js
import containerStyle from 'container.styles.js';

export default function (theme) {
  const style = containerStyle (theme);
  style.base.flexDirection = 'row';
  style.base.flexWrap = 'wrap';
  return style;
}
```

We could also be more explicit about it:

```javascript
// flow-container.styles.js
import containerStyle from 'container.styles.js';

export default function (theme) {
  const {base} = containerStyle (theme);
  return {
    base: {
      ...base,
      flexDirection: 'row',
      flexWrap: 'wrap'
    }
  };
}
```

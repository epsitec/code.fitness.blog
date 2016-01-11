+++
categories = [""]
date = "2016-01-05T11:09:53+01:00"
title = "What should a Style Function operate on?"
+++

The first implementation of the [style function](/post/2015/12/electrum-themes-and-components.html)
expects the _theme_ as its only argument. The theme defines a straightforward
API:

```javascript
class Theme {
  get name () { /***/ }
  get colors () { /***/ }
  get palette () { /***/ }
  get shapes () { /***/ }
  get spacing () { /***/ }
  get styles () { /***/ }
  get timing () { /***/ }
  get transitions () { /***/ }
  get typo () { /***/ }
}
```

Based on the definitions found in the theme object, a style function can build
its style object. But sometimes, this might not be enough. A component might
want to style itself according to a property.

## Styling with kind

In order to let the consumer of a component apply some predefined sub-styles,
Electrum supports the `kind` property:

```javascript
<Button kind='accept' ... />
```

The style function returns not only the `base` style, but also a set of additional
CSS properties for `accept` (here simply setting the font to bold):

```javascript
export default function (theme) {
  return {
    base: {
      display: 'inline-block',
      cursor: 'pointer',
      /***/
    },
    accept: {
      fontWeight: 'bold',
    }
  };
};
```

## Styling without dragons

After reading through [Monica Dinculescu](https://speakerdeck.com/notwaldorf/)'s
slides [How to Style Elements without Dragons](https://speakerdeck.com/notwaldorf/styling-the-shadow-dom-without-dragons)
and [watching her video](https://www.youtube.com/watch?v=IbOaJwqLgog) multiple
times, I finally decided to let the style function have access to more context,
but not let the user of the component hijack the styles inside of the castle
(that is, the component).

Rather than opening the styling mechanism to external style injection, it is
preferable to let the style author decide what she allows to customize, and
what not.

Style injection using `style={{...}}` should therefore be avoided:

```javascript
<Foo theme={theme} value='hello' kind='nice' styles={{fontWeight: 200}} />
```

Instead, if the component author of `<Foo>` wants to let the user override
the font weight, then she should ask the user to do so explicitly:

```javascript
<Foo theme={theme} value='hello' kind='nice' customFontWeight=200 />
```

This means that the style function also needs to get access to the `props`
of the component being rendered:

```javascript
export default function (theme, props) {
  return {
    base: {
      display: 'inline-block',
      fontWeight: props.customFontWeight || theme.typo.fontWeight,
      /***/
    },
  };
};
```

The result of the style function therefore needs to be computed again, not
only when the theme changes, but also when any of the properties change...

## Caching versus flexibilty

Most style functions won't need to produce custom output based on the
component's properties. We should therefore cache the result of calling
the style function if we detect that it only takes a dependency on the
theme.

* The function _theme_ &rArr; _style_ should be cached and can be reused
  independently of the component instance, until the theme gets modified.
* The function _theme_, _props_ &rArr; _style_ should not be cached. It might
  produce a different result for every component instance and will have to
  be evaluated when `render()` gets called.

I don't know if it is a good idea to open up all the `props` to the style
function, or if we should rather filter them and only pass it a known
subset.

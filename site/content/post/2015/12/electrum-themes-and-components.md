+++
categories = [""]
date = "2015-12-16T10:18:00+01:00"
title = "Electrum, themes and components"
+++

Electrum provides support for styles and themes at the React component
level. The current architecture is not yet fully finalized, but it is
time for me to share some ideas.

# What's in a theme

An Electrum theme is basically a collection of various sets of
properties:

* Palette &rarr; `theme.palette.accent1`.
* Shapes &rarr; `theme.shapes.defaultBorderRadius`.
* Styles &rarr; `theme.styles.resetLayout`.
* Transitions &rarr; `theme.transitions.slid`.
* Typo &rarr; `theme.typo.font`.

which are derived from more basic sets of properties:

* Colors &rarr; `theme.colors.purple600`.
* Spacing &rarr; `theme.spacing.iconSize`.
* Timing &rarr; `theme.timing.timeBase`.

The theme is used by the _styling engine_ to derive the real `styles`
object which will be handed over to [Radium](http://stack.formidable.com/radium/)
in order to produce a set of inline styles on the React element.

# Customizing components

An Electrum component is implemented as a _pure_ React component
and as a _style function_. The _style function_ of a component
`<Foo>` looks like this:

```javascript
export default function (theme) {
  return {
    base: {
      includes: ['resetLayout', 'defaultTypo'],
      width: '100%',
      backgroundColor: theme.palette.background,
      color: theme.palette.text,
    },
    important: {
      color: theme.palette.textAccent1
    }
  };
}
```

> Note: the `includes: [...]` property tells the theme styling engine
> to inject partial styles taken from `theme.styles`. 

The style function takes a _theme_ as its input and produces a style
collection which defines a `base` style and possible multiple sub-styles
(such as `important` in the example above).

Component `<Foo>` can be used as is, by just using `<Foo .../>` in any
other component's `render()` method. This will render the component with
its base style (`base`).

The component can be customized by adding a `kind='important'` property,
which will append to the base tyle the sub-style named `important`, thus
resulting in the `color` to be `theme.palette.textAccent1` rather than
the default `theme.palette.text`.

Global theme styles (found in the `theme.styles` object) can be added
to component `<Foo>` by just listing them `styles={[foo,bar]}`.

Furthermore, local styles may be added using `styles={{fontWeight: 200}}`
or mixed with global theme styles by listing the local styles in the
array, such as  `styles={['foo', {fontWeight: 200}]}`.

```javascript
<Foo id='123' theme={theme} value='hello'
     kind='important'
     styles={
       ['foo', {fontWeight: 200}]
     } />
```

# Too customizable?

I am not too happy with all this flexibility, though. Letting the
consumer of `<Foo>` inject any style into the component could lead
to broken designs or unexpected behaviours. The same conclusion was
reached by the people at [Polymer](https://www.polymer-project.org/1.0/docs/devguide/styling.html):


> One solution the Shadow DOM spec authors provided to address the theming
> problem are the `/deep/` and `::shadow` combinators, which allow writing
> rules that pierce through the Shadow DOM encapsulation boundary. Although
> Polymer 0.5 promoted this mechanism for theming, it was ultimately unsatisfying
> for several reasons:
> 
> - Using `/deep/` and `::shadow` for theming leaks details of an otherwise
>   encapsulated element to the user [...]
> 
> [...]
>
> For the reasons above, the Polymer team is currently exploring other
> options for theming that address the shortcomings above and provide
> a possible path to obsolescence of `/deep/` and `::shadow` altogether

I am currently toying with the following idea: Let the user of a component
specify a _configuration_ property which could be fed to the component's
_style function_. This would ensure that only customizable areas would
indeed get customized.

And another track to explore is parent-children style injection, e.g.
to manage complex layouts without having to patch the children in the
`render()` function.

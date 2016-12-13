+++
categories = ["js"]
date = "2015-11-14T11:47:11+01:00"
title = "Set up .babelrc for Babel 6"
+++

Since Babel 6, running `babel` won't automatically transform ES2016 to
ES5. It won't recognize React JSX syntax (e.g. `return <div/>;`) either.
For this to work, you have to **configure** Babel and tell it exactly
what language features you need. This configuration is best done directly
in a `.babelrc` file stored at the root of your project.

James K Nelson's [The Six Things You Need to Know About Babel 6](http://jamesknelson.com/the-six-things-you-need-to-know-about-babel-6/)
provides an excellent starting point and explains what npm packages
need to be installed, how transforms are now implemented in
[plugins](https://babeljs.io/docs/plugins/), and that Babel comes
with [presets](https://babeljs.io/docs/plugins/#presets) in order
to simplify the configuration of typical environments.

## Using ES6/ES2015

What was formerly called ES6 (ECMAScript 6) now belongs to the final
ECMAScript 2015 language specification, or just **ES2015**. In order
to get Babel 6 to support ES2015, you have to first install the
`babel-preset-es2015` module in your project.

Create a basic `.babelrc` with just the following content:

```json
{
  "presets": ["es2015"]
}
```

## Also using React JSX

You probably also want to use `React`, so you should include the
`babel-preset-react` module, and update the `.babelrc` file
accordingly:

```json
{
  "presets": ["es2015", "react"]
}
```

Or you could also have written:

```json
{
  "presets": ["react", "es2015"]
}
```

The order of the presets does not really matter:

* `["react", "es2015"]` &rArr; JSX &rarr; ES2015 &rarr; ES5
* `["es2015", "react"]` &rArr; ES2015 &rarr; JSX &rarr; ES5

and both will be OK.

## And what about ES7?

In order to get access to newer language features (the ones which
are not yet part of a final ECMAScript standard), Babel provides
various presets.

You get the most _bleeding edge_ language features by installing
the `babel-preset-stage-0` module.

Now, ordering the presets in the `.babelrc` file becomes important:

```json
{
  "presets": ["stage-0", "es2015", "react"]
}
```

Trying to put `stage-0` at a later point in the transformation
pipeline will result in Babel failing to compile the code. For
instance using a decorator with `"presets": ["react", "es2015",
"stage-0"]` currently produces this error:

> SyntaxError: Decorators are not supported yet in 6.x pending proposal update.

So you should really stick to:

* `["stage-0", "es2015", "react"]` &rArr; stage-0 &rarr; ES2015 &rarr; JSX &rarr; ES5

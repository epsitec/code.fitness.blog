+++
categories = ["js"]
date = "2015-11-15T11:56:11+01:00"
title = "React and Stateless Function Components"
+++

In React, components can be defined in various ways:

* `const Foo = React.createComponent({...})` &rarr; component `Foo`.
* `class Foo extends React.Component {...}` &rarr; component `Foo`.
* `function Foo(props) {...}` &rarr; stateless function component `Foo`.

The [stateless function component](https://facebook.github.io/react/docs/reusable-components.html#stateless-functions)
can be used to produce very easily create stateless components which
only implement a (pure) `render()` function:

```javascript
const Hello = props => <div>Hello {props.name}</div>;
ReactDOM.render (<Hello name='world' />, mountNode);
```

Since such components are **intrinsically pure** I was expecting that
React would handle them as such, and that it would only call the function
once when repeatedly calling `ReactDOM.render` with the same properties.

For now, this **is not the case**. Every rendering goes through the (implicit)
render method call defined by the stateless function component. To test
this, I've written this small piece of code:

```javascript
const Hello = function (props) {
  Hello.renderCount++;
  return <div>Hello {props.name}</div>;
};

describe ('React', () => {
  describe ('Stateless function component', () => {
    it ('calls render() even if props do not change', () => {
      Hello.renderCount = 0;
      ReactDOM.render (<Hello name='world' />, mountNode);
      expect (Hello.renderCount).to.equal (1);
      ReactDOM.render (<Hello name='world' />, mountNode);
      expect (StatelessHello.renderCount).to.equal (2);
    });
  });
});
```

The full source code for the test can be found on [epsitec-sa/react-usage](https://github.com/epsitec-sa/react-usage/blob/v0.0.1/src/test/react.component.stateless-updating.js).

See [pull request](https://github.com/facebook/react/pull/4587#issuecomment-156719929)
and
[relevant discussion](https://github.com/facebook/react/pull/3995#issuecomment-123353574)
on GitHub.

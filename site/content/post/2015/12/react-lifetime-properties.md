+++
categories = ["react"]
date = "2015-12-10T09:37:14+01:00"
title = "The lifetime of React properties"
+++

Did you ever wonder what happens to a component's `props` when
React instantiates the component class? And then, what happens
to `props` if the parent re-renders the component with different
properties?

## The spy component

Let's create a _spy_ so that we can check what's going on.

```javascript
import React from 'react';
import shallowCompare from 'react-addons-shallow-compare';

let spyConstructors = [];
let spyRenders = [];

export default class Spy extends React.Component {
  constructor (props) {
    super (props);
    spyConstructors.push ({obj: this, props: this.props});
  }
  shouldComponentUpdate (nextProps, nextState) {
    return shallowCompare (this, nextProps, nextState);
  }
  getText () {
    return 'Text:' + this.props.text;
  }
  render () {
    spyRenders.push ({obj: this, props: this.props});
    return <div id={this.props.id}>{this.props.text}</div>;
  }

  static clear () {
    spyConstructors = [];
    spyRenders = [];
  }

  static getConstructorLog () {
    return spyConstructors;
  }

  static getRenderLog () {
    return spyRenders;
  }
}

```

## The test code

We'll use the `<Spy>` like so:

```javascript
Spy.clear ();
ReactDOM.render (<Spy text='a'/>, mountNode);
ReactDOM.render (<Spy text='b'/>, mountNode);
const constr = Spy.getConstructorLog ();
const render = Sky.getRenderLog ();
```

and observe what happens to the `props` which get passed into
the constructor, and then used by the `render()` method.

## Results

In my test code, there will be only one component instanciation.
React is smart enough to reuse the same `<Spy>` element. We can
check this with:

```javascript
expect (constr).to.have.length (1);
```

And naturally, there will be two calls to `render()`, since
`shouldComponentUpdate` will return `true` when switching
from `text='a'` to `text='b'`:

```javascript
expect (render).to.have.length (2);
```

We can verify that the same component instance was used:

```javascript
expect (constr[0].obj).to.equal (render[0].obj);
expect (constr[0].obj).to.equal (render[1].obj);
```

## And what about the props?

Well, the `props` change between the first and the second
call to `ReactDOM.render`, so the element's `props` will
be replaced:

```javascript
expect (constr[0].props).to.equal (render[0].props);
expect (constr[0].props).to.not.equal (render[1].props);
```

That's about what we should expect. Changing the properties 
should indeed inject other `props` into the `<Spy>`, and this
is what happens.

React provides a lifecycle method called `componentWillReceiveProps()`
which gets called before the `props` change. See [React component specs](https://facebook.github.io/react/docs/component-specs.html)
for further the details.

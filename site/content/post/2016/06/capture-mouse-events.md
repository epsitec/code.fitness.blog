+++
categories = ["html", "javascript"]
date = "2016-06-14T15:49:19+02:00"
title = "Capture all mouse events after a mouse down"
+++

Once again, it took me several hours to figure out how to implement
a seemingly simple feature with electrum, React and electron (or for
the matter, Chrome).

Here is my scenario:

1. The user presses the mouse button on a `<div>` element.
2. As a result, I want to set the focus on an `<input>` element.
3. I want to capture all mouse events from that point in time
   until the users releases the mouse button as I don't want
   any other element seeing them.
4. I want to be able to press a second time on the `<div>` and
   have everything work exactly as the first time.
5. I don't want the browser to display _hover_ effects on items
   such as buttons or `<a>` links while the mouse button is down,
   even if the mouse gets over an otherwise live element.

## Setting the capture

I was expecting to find an API to capture mouse events, like
[`SetCapture()`](https://msdn.microsoft.com/en-us/library/windows/desktop/ms646262(v=vs.85).aspx)
I had been using on Win32. And indeed, MDN had an explanation
of `Element.setCapture()` which looked exactly like what I was
looking for.

The first surprise was the lack of such a `setCapture()` function
in Chrome.

I digged around, found a lot of old and outdated information which
stated that Chrome had no `setCapture()`. I guessed that this would
have been addressed since 2009. But no, see [Stack Overflow](http://stackoverflow.com/questions/37810642/replacement-for-element-setcapture-in-chrome)
and a workaround [here](http://stackoverflow.com/questions/30231880/setcapture-and-releasecapture-in-chrome).
See also [Example 19-2 in JavaScript, The Definitive Guide, 4th ed.](http://docstore.mik.ua/orelly/webprog/jscript/ch19_02.htm).

## First attempt

I tried the workaround in my component:

```javascript
render() {
  return <div onMouseDown={e => this.handleMouseDown (e)}>Hi</div>;
}
handleMouseDown(e) {
  inputElement.focus ();
  captureMouseEvents ();
  e.preventDefault ();
  e.stopPropagation ();
}
```

and wrote a `captureMouseEvents()` function which would add an
event listener on `document` for both `mouseup` and `mousemove`,
while removing them when the `mouseup` event is received:

```javascript

function mousemoveListener (e) {
  e.preventDefault ();
}

function mouseupListener (e) {
  document.removeEventListener ('mouseup', mouseupListener, true);
  document.removeEventListener ('mousemove', mousemoveListener, true);
  e.preventDefault ();
}

function captureMouseEvents () {
  document.addEventListener ('mouseup', mouseupListener, true);
  document.addEventListener ('mousemove', mousemoveListener, true);
}
```

It should work, shouldn't it?

My component did indeed call `captureMouseEvents()`, it would get the
mouse movements and the final mouse up. It would properly unregister
its event listeners from the document.

However **clicking a second time** on the component would not call
`handleMouseDown`. It just did not react any more!

## React events and focus

See that line:

```javascript
  inputElement.focus ();
```

It was responsible for this misbehaviour. Commenting it out would
fix the issue.

As soon as I set the focus on another element while capturing the events,
React gets confused. It would no longer route the `mousedown` events to
the correct component, until I changed the focus by clicking on another
item.

So I decided to get rid of `onMouseDown` and React synthetic events,
and manually add an event listener on my component's DOM node. This
is easily done in the component's `componentDidMount()` life-cycle
method:

```javascript
componentDidMount () {
  const dom = ReactDOM.findDOMNode (this);
  dom.addEventListener ('mousedown', e => this.handleMouseDown (e));
}
```

With that in place, I got a working implementation for points 1-4.

## But wait, I don't want items reacting to hover!

What I did not realize, however, was that even with this _mouse event capture_
in place, the browser would continue to apply the hover effect on
items below the mouse pointer, and change the shape of the cursor
based on the underlying component.

> Try to select some text in an electron-based editor such as **atom**
or **Visual Studio Code** and you will see that they suffer from
the same strange behavior. While selecting, you'll get the double
ended arrow as soon as you cross a splitter, or a hand when you
get over an icon.

Huh? This does not make sense: I am selecting
text and the visual feed-back I get is plain wrong.

In **atom**
I even see a pop-up appear while I am selecting text if I move
the cursor to the _update indicator_ in the lower right corner
of the window.

## Radical measures

There is a little known CSS style which can be applied on any
element to _disable all pointer events_. Setting the `pointer-events`
style to `none` on the _body_ of the DOM completely disables
all pointer events. No hovers. No cursors. No nothing.

```css
body {
  pointer-events: none;
}
```

If I set this style dynamically when the user presses the mouse
button, I completely disable the unwanted reactions to hovering
elements. Fortunately enough, the component which has _captured_
the mouse will still get the events, which allows me to restore
a normal behaviour as soon as the user releases the button.

Here is the final piece of code:

```javascript
const EventListenerMode = {capture: true};

function preventGlobalMouseEvents () {
  document.body.style['pointer-events'] = 'none';
}

function restoreGlobalMouseEvents () {
  document.body.style['pointer-events'] = 'auto';
}

function mousemoveListener (e) {
  e.stopPropagation ();
  // do whatever is needed while the user is moving the cursor around
}

function mouseupListener (e) {
  restoreGlobalMouseEvents ();
  document.removeEventListener ('mouseup',   mouseupListener,   EventListenerMode);
  document.removeEventListener ('mousemove', mousemoveListener, EventListenerMode);
  e.stopPropagation ();
}

function captureMouseEvents (e) {
  preventGlobalMouseEvents ();
  document.addEventListener ('mouseup',   mouseupListener,   EventListenerMode);
  document.addEventListener ('mousemove', mousemoveListener, EventListenerMode);
  e.preventDefault ();
  e.stopPropagation ();
}
```

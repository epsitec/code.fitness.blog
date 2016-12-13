+++
categories = ["js"]
date = "2016-05-12T11:05:12+02:00"
title = "Is Caps Lock on?"
+++

While working on `electrum` and its bus, I needed to handle keyboard
events and send them back from the browser (more specifically, from
Electron) to the presentation layer written in C#.

Electrum components fire React [synthetic events](https://facebook.github.io/react/docs/events.html#syntheticevent)
and on every _key down_ event, the bus gets the opportunity to send
some information to the presentation layer over SignalR, based on
data found in said `SyntheticEvent`.

I decided to categorize the keyboard events:

* Vertical navigation (up/down arrows, page up/down).
* Line navigation (left/right arrows, home/end).
* Selection (enter/escape).
* Function keys (<kbd>F1</kbd>...<kbd>F12</kbd>).

The `SyntheticEvent` also exposes properties of the underlying DOM
event, which give an indication of the state of the various modifier
keys, such as <kbd>Alt</kbd>, <kbd>Ctrl</kbd>, etc.

I wanted to know if I could also easily find out if **Caps Lock**
is turned on, so that we could do some smart feed-back while
typing text into a password field.

Looking for solutions on the web pointed to lots of _outdated
solutions_ which required some smart event listening, checking
if the character produced would be upper case while no shift
is pressed, or lower case while shift is pressed.

Digging into [MDN's documentation](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/getModifierState)
for `KeyboardEvent`, I stumbled on `getModifierState()` which
does exactly what I need:

```javascript
const hasAlt = ev.getModifierState ('Alt');
const hasScrollLock = ev.getModifierState ('ScrollLock');
// ...
```

> Alas, trying this out in Electrum shell does never return
> `true` for `hasScrollLock`.
> 
> The feature seems to [have been implemented recently on
> chromium](https://bugs.chromium.org/p/chromium/issues/detail?id=265458)
> (marked as fixed on February 23 2016), so there is hope that
> it will also find its way into my Electron instance in the
> near future.

**EDIT** in Electron 1.0.2 `getModifierState()` works just fine.
Thank you Mathieu Schroeter for updating our code base! However,
the Chromium engine does not distinguish between Ctrl+Alt and
AltGr.

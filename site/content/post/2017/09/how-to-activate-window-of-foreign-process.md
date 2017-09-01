+++
categories = ["win32"]
date = "2017-09-01T13:38:33+02:00"
title = "Activate the window and set the focus to another process"
+++

Windows is trying hard to ensure that nobody is trying to
steal the keyboard focus while a user is working. Apart
from Windows Update, which is known for stealing the
focus at the most annoying time, modern versions of
Windows effectively don't do anything when calling
`SetActiveWindow()` on an window which does not belong
to the already active application.

## But my use case is legitimate

In my case, I was trying to find a solution, where two
applications (a *main* app and a *companion* app) have
to switch back and forth between their windows.

The main app has a button which brings up a window of
the companion app, and should change the focus so that
the user can directly type into the companion app.

The solution found on StackOverflow [Is there a reliable way to activate / set focus to a window using C#?](https://stackoverflow.com/questions/2671669/is-there-a-reliable-way-to-activate-set-focus-to-a-window-using-c) did not work out for me.

## A clean solution - if you can modify both apps

I've come up with the following solution:

* The main app starts the companion app and retrieves
  the window handle of the companion window.
* The main app sends the companion app its main window
  handle.
* The companion app sets the _owner window_ to the main
  window of the main app, using the native Win32 API,
  `SetWindowLong(hwnd, GWLP_HWNDPARENT, other)`.
* Now, the main app can effectively activate the companion
  app's window by calling `SetActiveWindow()`.

When the companion app gets minimized, I have to reset
its _owner window_, and restore it when the window gets
restored, or else the main app seems not to be able to
use `ShowWindow()` to restore the minimized window.

I've put up a [C# demo on GitHub](https://github.com/epsitec/window-focus) which shows
how this can be solved with .NET.

## What if my Companion App is an electron instance?

Apparently, the same kind of magic can be done thanks
to `node-ffi` with **electron**. See [this StackOverflow question](https://stackoverflow.com/questions/39421074/setting-focus-to-a-windows-application-from-node-js) for inspiration.

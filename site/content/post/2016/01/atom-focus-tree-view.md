+++
categories = ["vs", "atom"]
date = "2016-01-27T10:11:29+01:00"
title = "Focus the tree view in atom editor"
+++

As a long time Visual Studio developer I had become accustomed
to pressing `Ctrl`-`Alt`-`L` to set the focus on the **Solution Explorer**,
and then using up/down arrows to move around.

I am spending a lot of time in the atom editor these days and my muscle
memory still itches to press `Ctrl`-`Alt`-`L` in order to focus atom's
**Tree View**. So I decided to customize atom.

## Customizing atom keymap

To customize the keyboard shortcuts, proceed like this:

* Use menu File &rarr; Open Your Keymap.
* Paste following snippet at the end of the file.
* Save.

```
'.platform-win32':
  'ctrl-alt-l': 'tree-view:toggle-focus'
```


+++
categories = ["tips","edge","windows","productivity"]
date = "2025-04-26T09:05:00+01:00"
title = "Microsoft Edge Blank New Tab"
+++

I use Microsoft Edge daily and appreciate features like
vertical tabs, collections, device sharing via Drop, and workspaces.

However, I've been frustrated by one of the _improvements_ in Microsoft Edge:
opening a new tab (<kbd>Ctrl+T</kbd>) leads to a Microsoft Bing search page,
which I find both intrusive and distracting.

## Using `about:blank` instead

Edge provides extended configuration options. You can disable most of the
extra features that appear when opening a new tab, but the Bing search
stubbornly remains.

Fortunately, you can configure a registry key under software policies to
navigate to `about:blank` instead when creating a new tab:

```txt
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge\Recommended]
"NewTabPageLocation"="about:blank"
```

This tweak makes Edge feel less bloated and more focused, ideal for
productivity.

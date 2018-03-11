+++
categories = ["tools"]
date = "2018-03-11T15:21:53+01:00"
title = "Clear ClickOnce leftovers"

+++
I've been struggling with recent versions of Visual Studio 2017
and ClickOnce for several months, without being able to resolve
all my issues (impossible code signing with an external tool,
broken automatic update, broken file associations after manual
update, etc.) so I decided to give up ClickOnce completely.

## Getting rid of failed ClickOnce installs

In order to remove _all ClickOnce_ applications, I followed
these steps:

* Uninstall what can be uninstalled from _Add and Remove_
  Control Panel applet.
* Execute `rundll32 C:\Windows\system32\dfshim.dll CleanOnlineAppCache`
* Execute `mage.exe -cc`
* Delete all content from `%LocalAppData%\Apps\2.0`.
* Delete shortcuts still found in the _Start Menu_, by
  opening `%AppData%\Microsoft\Windows\Start Menu\Programs\...`

`mage.exe` can be found in one of the Microsoft SDKs subfolders.
In my case, I found it at `C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools`. Just in case,
here is a [copy of _mage_](mage.exe).

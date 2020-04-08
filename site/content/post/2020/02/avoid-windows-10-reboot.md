+++
categories = ["tools", "windows"]
date = "2020-02-23T08:40:00+01:00"
title = "Prevent Windows Update to reboot your computer, really"
+++

I am running multiple computers on Windows 10, and I don't want them
to reboot automatically as a result of an automatic update; some are
running VMs and having the host restart without me properly stopping
the VMs is asking for trouble.

I tried to postpone reboots as far as I could, but sometimes, Windows
seems to know better and just reboots my computer outside of the
configured _active hours_...

## Reboot Blocker to the rescue

I've come across [this little tool](https://udse.de/reboot-blocker/)
written by Ulrich Decker:

[RebootBlockerSetup.zip](https://www.udse.de/download/RebootBlockerSetup.zip)

The way this tool works, is by permanently adjusting the _active hours_
so that Windows never gets a chance to reboot outside of them. Simple,
but effective!

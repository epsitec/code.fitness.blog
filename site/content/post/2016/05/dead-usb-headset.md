+++
categories = ["windows"]
date = "2016-05-13T16:37:24+02:00"
title = "Logitech USB Headset not working?"
+++

I've been using Logitech gear for decades (I used my first Logitech
mouse with a [Smaky](http://smaky.ch) computer back in the early
1990). I am using a G9 mouse on my workstation and a USB headset,
which ceased to work a few days ago.

I thought this was a hardware problem (the headset must have been
manufactured over 5 years ago), so I ordered a replacement, the
Logitech H820e. I received it today, plugged it in and expected
to see the driver installation succeed.

It did not. **Windows did not find a suitable driver**. And
obviously, Logitech is not providing any driver for the H820e,
as it adheres to the USB standard, and the operating system
should provide support for it out of the box.   

> Yes, I know, I am still using Windows 7 x64 on my main
> workstation, but why bother upgrading it?

# Fix it!

I have no idea what happened to my computer, but it had neither
`usb.inf` nor `usb.pnf` in the `C:\Windows\inf` folder. These
files seem to be needed to identify _standard_ USB devices.

So I started an other Windows 7 x64 computer and copied both
files over, went to the device manager, uninstalled the _H820e_
under the _Other devices_ node, unplugged the device, plugged
it back in and ... tada ... it was immediately picked up by
my computer.

So in case anyone is looking for these files, [here they are](usb.zip).
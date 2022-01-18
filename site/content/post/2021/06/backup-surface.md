+++
categories = ["windows", "tools"]
date = "2021-06-15T06:00:00+02:00"
title = "Backing up and restoring a Surface Laptop 4"
+++

I did not expect the task to be so difficult, and in the end, I spent about 20 frustrating hours trying to get things to work.

Here is what I needed to do:

1. Back up a working Surface 4 laptop.
2. Restore its content on a new Surface 4 laptop with twice the RAM.

I had just finished reading a great series of articles in Heise's
c't about a backup/restore tool based on WIM (see [c't-WIMage](https://www.heise.de/news/Windows-Sicherung-Neue-Version-von-c-t-WIMage-6027304.html)).
I wanted to give it a try.

## Giving up on c't-WIMage

I followed the instructions and successfully backed up the source
laptop, built a recovery media using the Windows suite of tools
and was even able to boot and restore everything on the 2nd laptop.
However, neither internal keyboard, touchpad, touch display, network... worked. Attaching external devices helped, but I was somehow locked out of the computer.

I had not realized that the restore environment built on the first laptop did not include any of the drivers for the Laptop 4 hardware.
Much later, I came across [this article](https://support.microsoft.com/en-us/surface/creating-and-using-a-usb-recovery-drive-for-surface-677852e2-ed34-45cb-40ef-398fc7d62c07) which provides detailed steps on downloading the missing pieces and applying them to a recovery environment. Alas, this broke the scripts used by c't-WIMage.

I did not figure out if the problem was caused by my system being in French (c't-WIMage has been tested extensively only on German systems), or if messing around with the recovery environment's WIM subtly changed the layout.

I gave up...

## Acronis True Image to the rescue

I purchased the latest version of Acronis True Image and gave it a try. I was disappointed. The tool used to produce a recovery environment failed to produce a bootable USB stick for my Surface. It worked on other computers, but not on the Surface Laptop 4.

Using the integrated recovery tool, directly in the main product, helped (a bit) as I was able to build Linux and Windows-PE/RE-based recovery systems.

- The Linux environment did not boot (apparently the hardware was not supported).
- The Windows-based environment did boot, allowed me to back up the source laptop, but crashed painfully when trying to restore the media on the destination laptop.

I opened a support case, and a week later, I got instructions and hints about what I could do to try to get things to work (one of them being to wait for release 2022 which is planned for late August). But I had already moved on...

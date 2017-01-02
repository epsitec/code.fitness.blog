+++
categories = ["hardware"]
date = "2017-01-02T17:14:37+01:00"
title = "Reinstalling an old Mac Pro with Boot Camp"
+++

A good old trusty Mac Pro needed repaving (about my Mac says it is a
_Mac Pro (early 2009)_ with 2.66 GHz Quad-Core Intel Xeon, NVIDIA GeForce
GT 120 512 MB, 8 GB 1066 MHz DDR3 ECC).

I decided to replace the book disk with a 1TB Samsung SSD (850PRO) before
reinstalling OS X and Windows 10. Swapping out the disk labeled (1) and
installing the 2.5" SSD in an ICY DOCK EZConvert case (ref. MB882SP-1S-2B)
was easy.

## Reinstalling macOS

I expected the reinstall to be painless. I turned the Mac Pro on
while holding down Option-Command-R to trigger the web-based recovery
process. All I got was a black screen with the `No bootable device --
insert boot disk and press any key` message.

To get over that, I needed to reset the PRAM where the incorrect boot
configuration was stored. For that, I pressed Option-Command-R-P while
turning on the Mac Pro. It then rebooted and showed a folder icon with
a question mark. Obviously, it was now trying to boot from the empty
SSD and not finding the recovery console.

The Mac Pro appears to be too old to support web-based recovery, so
the next step was to install macOS Sierra on the SSD from the outside.

## Target mode reinstall

I happen to have a Mac laptop on which I downloaded the _macOS Sierra
installer_, so I decided to give it a try.

I pressed `T` on the Mac Pro while turning it on in order to start it
in _target mode_. Then, I connected the Mac Pro to the laptop using a
FireWire cable (attached to a lightning connector over an adapter).
The SSD appeared on the laptop. I could initialize it and mount it.
Then I selected that disk as the target in the Sierra installer.

A few minutes later, the installer had finished its job and was ready
to reboot the laptop. Instead, I decided to unplug the Mac Pro and
reboot it. That was, alas, a dead end: the installer booted, but only
to tell me that my Mac Pro was not supported by this macOS installer.
Great.

## Old fashioned DVD reinstall

I had fortunately a Mac OS X DVD Install DVD in my archives (2007)
and I decided to give it a try. Rebooting the Mac Pro while holding
down Alt, I could then open the DVD tray (use a real Apple keyboard),
insert the DVD and boot from it. Alas, my Mac OS X v10.5 DVD would
only boot up to the Apple logo, and get stuck there.

I suspected that the newer file system on my SSD drive was somehow
confusing the 10.5 installer. I wiped the SSD (using once more the
target mode) and rebooted.

The installer finished to load, only to inform me that my Mac model
was not supported.

I then digged into my stack of installation DVDs and found one which
was bundled with a Mac mini (version 10.6.4). It booted, but refused
to install, since the hardware did not match. Sigh.

## Back to target mode reinstall (this time with success)

I decided to try an older version of OS X (as Sierra is documented
to no longer support old Mac Pro models), so I picked _Mac OS X El
Capitan_ which I downloaded through the App Store on my laptop.

Back to _target mode_. I once again installed the OS on the Mac Pro
over FireWire, running the installer on my laptop. But this time,
I let the laptop reboot and finish the install, then turned it off.

I restarted the Mac Pro and -- lo and behold -- it happily booted
to the desktop. Mission accomplished. I then checked to see if the
installation did somehow affect the laptop. Thankfully, all changes
were done on the Mac Pro SSD and the laptop disk was left unmodified.

## Installing Boot Camp

I used the Boot Camp Assistant to download the additional drivers
needed by Windows (they get saved to an external USB key) and a
physical DVD containing Windows 10. The install went smoothly and
without surprises, even if the drivers are designed for Windows 7.

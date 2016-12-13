+++
categories = ["hardware"]
date = "2016-01-11T20:45:02+01:00"
title = "Replacing an iMac hard disk with an SSD"
+++

A colleague had an iMac (about 4 years old, I guess) which was suffering
from some transient problems with the graphic card. My first checks showed
me that the Windows 7 x64 which was running on it had no _Boot Camp_ drivers
installed. Fortunately, the iMac still had its original OS X partition.

So I went on, booted into OS X, upgraded the OS to the latest version and
downloaded the drivers using the Boot Camp tool. I then switched back to
Windows, installed the drivers, and voilà.

While doing so, I decided to upgrade the hardware a bit. Adding memory
was easy: there is a small cover at the lower side of the screen, secured
by three screws. Unscrew, take cover off, firmly push two 4GB SO-DIMMs
into place, put cover and screws back. Done.

Upgrading the HDD to an SSD proved to be ... interesting.

I had ordered a 512GB SDD before Christmas, and so I was expecting to be
able to just swap out the old hard disk and insert the SSD in its place.
Boy, was I wrong.

## Challenge 1: Open the iMac

Have you ever wondered how you get access to the internals of an
iMac? You need two suction cups to remove the glass protecting
the display, which has a magnetic attachment.

Fortunately, [ifixit](https://www.ifixit.com/Guide/iMac+Intel+21.5-Inch+EMC+2308+Hard+Drive+Replacement/1766)
has a great step by step description of what needs to be done to
get the iMac open. Several cables need to be disconnected so that
the display itself can be moved aside enough to reach the screws
which are securing the HDD.

## Challenge 2: Copy the data

I was expecting the copy of the data from the internal HDD to the
SSD to be as easy as on a laptop PC. Nope. The tools I had used to
migrate laptop HDDs to SSDs were not meant to migrate an OS X
partition.

Here is, after lots of trial and error, what worked for me:

1. Attach SSD to an external USB adapter.
2. Boot the iMac into recovery mode (easiest is to press Alt
   on power on, then select the 10.10 recovery partition).
3. Use the Disk Utility to partition the SSD and copy the
   OS X partitions over. This is supported natively. Attach
   an additional disk and copy an image of the boot camp
   partition to it.
4. Reboot into the OS X installed on the external SSD.
5. Use Boot Camp to partition the SSD and start installing
   Windows 7 on it. As soon as the Mac reboots, turn it off.
6. Disconnect the HDD power and data cables, and connect them
   to the SSD. Since the HDD is a giant 3.5 inch device, just
   hide the tiny SSD under the HDD. There is enough room for
   it.
7. Boot back into recovery mode, on the SSD.
8. Disable System Integrated Protection (SIP) with `csrutil disable`
   so that the MBR and partition info can be modified.
   See [stackexchange](http://apple.stackexchange.com/questions/208478/how-do-i-disable-system-integrity-protection-sip-aka-rootless-on-os-x-10-11).
9. Boot back into OS X on the SSD.
10. Purchase [WinClone Standard](http://twocanoes.com/products/mac/winclone).
11. Mount the boot camp image created previously on the
   additional disk.
12. Use WinClone to copy the mounted boot camp image
   over to the empty boot camp partition on the SSD.

## Challenge 3: Replace the HDD

There is one last challenge: getting rid of the original HDD.
It happens to have three cables attached to it:

1. The SATA (data) cable.
2. The power cable.
3. The thermal sensor cable.

Yay, the thermal sensor is **mounted onto the HDD PCB**! Disconnecting
it would produce incorrect temperature reports, which would in turn
trigger maximum fan speed, and make a noisy iMac.

I could have ordered a sensor from a spare parts vendor, or installed
a [tool](http://exirion.net/ssdfanctrl/) to control the fan speed (only
available for OS X). I chose to be lazy and simply keep the old HDD in
the iMac, continuing to use its thermal sensor. And as I said earlier,
the SSD can be tucked under the HDD without trouble.

## Happy end

The iMac works fine now. Windows 7 x64 boots nicely thanks to WinClone
doing some magic with the partition table (all my attempts to do it
manually with the Disk Utility were unsuccessful and the time I lost
in my attempts does not justify the savings I'd have made by not
purchasing WinClone).

And it was really worth it. The iMac feels snappy and fast, even when
its antivirus is turned on. I did not measure the speed difference,
but it is about an order of magnitude better than before (i.e. some
programs start in under 2 seconds, whereas on the HDD it took about
25 seconds for them to start).
 
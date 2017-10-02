+++
categories = ["tools"]
date = "2017-10-02T05:33:05+02:00"
title = "Restoring my MacPro Windows 7 backup to VMware"
+++

My MacPro (late 2011) is showing signs of age. I've been running Windows 7 x64
on it happily for years, never upgrading it to Windows 8, 8.1 nor 10. But now,
as it started to bluescreen about once a day, I expect it to fail completely
in th few next days.

I decided to grab my StorageCraft backups and try to run a _restore_ scenario
on a VM, so that I could continue to work while waiting for my replacement
workstation, in case the hardware would stop working:

* I created a VM in VMware with a large enough hard disk, so that I can
  safely restore the whole boot volume.
* I mounted the `RE-CrossPlatform-64bit-2.1.1.3054.iso` image of my (old)
  StorageCraft recovery environment CD.
* I booted into the VM, attached my external media where I store the backup
  files, formatted the C: drive, installed everything and to be sure, ran
  also the HIR repair tool (Hardware Independent Restore).

The restore took quite a while, as my external media is on a _slow_ USB 2
connection. After that, I shut down the VM, detached the USB drive and the
CD image, and rebooted the virtual machine.

All I got at this stage was a VM trying to boot over the network. Diagnostic:
the restored hard disk drive was not detected as containing a bootable OS.

## Windows 7 Install disk to the rescue

I booted from a Windows 7 (x64) install disk in order to repair the boot.
The installer kindly told me that the machine contained no repairable
version of Windows! Going further with the installer, it told me that I
could not install Windows 7 on my disk, as it was using GPT partitions,
and that this was not supported.

## The fix is in the BIOS

The issue was with my VM: by default, its BIOS did not support UEFI, so
it would not know how to boot from my restored disk. Remember, it was a
disk image of a MacPro Windows installation. And a MacPro uses UEFI.

In order to have the VM boot from my restored disk image, all I need to
do, is tell VMware that it has to use an UEFI BIOS. Edit the `*.vmx` file
and add this:

```
firmware="efi"
```

Done. Now, the VM detects Windows, tells me that it has not been shut
down properly and it has started running a complete `CHKDSK`. As there
are over 25 millions of file records, this will take some time...

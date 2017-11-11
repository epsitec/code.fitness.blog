+++
categories = ["mac","repair","tools"]
date = "2017-11-11T11:09:22+01:00"
title = "Cloning a Mac mini"
+++

I needed to create a copy of a Mac mini (which runs usually Windows 10, but also has a macOS partition on it) to a spare machine, so that I could easily replace one by the other in case of an emergency.

I decided to use a block-level copy of the SSD from my source Mac to the target Mac, by using `dd` from the Terminal available when running the Mac in _Recovery Mode_.

## Terminal work from macOS in Recovery Mode

By getting down to _Recovery Mode_ I can unmount the system disk and create a copy of it, without having to worry about the OS using it, or restricting my access...

### Prepare the Target Mac

* Press <kbd>Alt</Kbd> and power on the **target** Mac mini.
* When the boot menu is displayed, press <kbd>Cmd-T</kbd>.
* The Mac displays the _Target Mode_ logo (lightning bolt).
* Attach the target Mac to the source Mac using a thunderbolt cable.

### Prepare the Source Mac

* Press <kbd>Alt</Kbd> and power on the source Mac mini.
* When the boot menu is displayed, press <kbd>Cmd-R</kbd>.
* After macOS booted into _Recovery Mode_, use the _Tools_ menu and open a **Terminal**.

### Copy the disk

This is the scary part. Make sure you don't accidentally swap the source and the target of the copy!

* At the command prompt, execute `diskutil list`.
* In the list, identify the internal, physical disk (usually `/dev/disk0`).
* In the list, identify the external disk (in my case, this was `dev/disk4`).
* Use `dd if=/dev/rdisk0 of=/dev/rdisk4 bs=1m conv=noerror,sync` to copy from disk 0 to disk 4. Note the use of `rdisk` (raw disk) instead of `disk` when used with `dd` (you'll get [better performance](https://superuser.com/a/892768/6826) with the raw disk device).

In case `dd` reports _resource busy_ on one of the disks, you'll have to unmount it, for instance with `diskutil unmountDisk /dev/disk4`.

## How does is do?

`dd` is not very chatty. After pressing <kbd>Return</kbd> the command executes without any visual feed-back. In my setup, with two Mac mini (Model No. A1347 with 1TB SSD and 16GB RAM), I get a throughput of roughly 130MB/s. Copying 1TB block by block requires more than 2 hours.

The main thing: it gets the job done without any additional tool.

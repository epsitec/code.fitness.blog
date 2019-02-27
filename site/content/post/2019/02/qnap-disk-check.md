+++
categories = ["tools", "qnap"]
date = "2019-02-27T07:07:23+01:00"
title = "QNAP and failed disk check"
+++

If your QNAP for some reason has a dirty RAID volume and you cannot
run the disk check from the UI, because it cannot unmount the volume,
drop down to SSH and try this instead:

```bash
/etc/init.d/services.sh stop
/etc/init.d/opentftp.sh stop
/etc/init.d/Qthttpd.sh stop
umount /dev/mapper/cachedev1
e2fsck_64 -f -v -C 0 /dev/mapper/cachedev1
reboot
```

Stopping all the services takes some time, just be patient... and then
you'll be able to unmount, `e2fsck` and reboot your NAS to get it up
and running again.

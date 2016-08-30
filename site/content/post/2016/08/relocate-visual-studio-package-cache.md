+++
categories = ["vs"]
date = "2016-08-30T08:42:10+02:00"
title = "Relocate Visual Studio Package Cache"
+++

Visual Studio stores lots of data into `%ProgramData%\Package Cache` (in my case
over 10GB worth of data). Fortunately, Heath Stewart provides a [step-by-step
procedure](https://blogs.msdn.microsoft.com/heaths/2014/02/11/how-to-relocate-the-package-cache/)
of how to move the contents of the folder into a VHD.

## Update procedure for my Windows 7 machine

The following is an update procedure taken from Heath's blog post. I've
added the missing `\` and updated the paths to match my configuration:

1. Open an elevated command prompt.
2. Run `diskpart.exe` to start the disk partitioning utility:

    `diskpart`

3. Create a large (ex: 1TB), expandable VHD on whatever secondary
   disk (for instance on `Q:\Disks`) you prefer with security matching
   the source directory's security:

    `create vdisk file="Q:\Disks\Cache.vhd" type=expandable maximum=1048576 sd="O:BAG:BAD:PAI(A;OICIID;FA;;;BA)(A;OICIID;FA;;;SY)(A;OICIID;FRFX;;;BU)(A;OICIID;FRFX;;;WD)"`

4. Select the VHD and create a partition using all available space:

    `select vdisk file="Q:\Disks\Cache.vhd"`  
    `attach vdisk`  
    `create partition primary`

5. Format the volume that was created automatically and temporarily assign a
   drive letter (for instance `T`):

    `format fs=ntfs label="Package Cache" quick`  
    `assign letter=T`  
    `exit`

6. After exiting `diskpart.exe`, move any existing per-machine payloads from the
   _Package Cache_ with security: 

    `robocopy "%ProgramData%\Package Cache" T:\ /e /copyall /move /zb`

7. Recreate the _Package Cache_ directory and set up the ACL and owner as before: 

    `mkdir "%ProgramData%\Package Cache"`  
    `echo y | cacls "%ProgramData%\Package Cache" /s:"O:BAG:DUD:PAI(A;OICIID;FA;;;BA)(A;OICIID;FA;;;SY)(A;OICIID;FRFX;;;BU)(A;OICIID;FRFX;;;WD)"`

8. Run `mountvol.exe` without any parameters first and look for the volume name
   that has the drive letter you assigned to the VHD, then use that with `mountvol.exe`
   again to mount that volume into the empty _Package Cache_ directory.

    `mountvol`   
    `mountvol "%ProgramData%\Package Cache" "mountvol "%ProgramData%\Package Cache" \\?\Volume{0e930327-6da7-11e6-8211-d8a25e8438ad}`

9. Run `diskpart.exe` again and remove the drive letter assignment from the volume
   (should be in partition 1 of the VHD):

    `select vdisk file="Q:\Disks\Cache.vhd"`  
    `select partition 1` 
    `remove letter=T`  
    `exit`

10. Non-boot VHDs are not automatically mounted, so before you reboot you need to make
    sure the VHD is mounted again whenever the machine is started. Write a simple script
    for `diskpart.exe` to execute on startup. If you're doing this on a laptop, you
    should edit the scheduled task afterward to allow it to run on batteries.

    `echo select vdisk file=Q:\Disks\Cache.vhd > Q:\Disks\Cache.txt`   
    `echo attach vdisk >> Q:\Disks\Cache.txt`   
    `schtasks /create /ru system /sc onstart /rl highest /tn "Attach Package Cache" /tr "%SystemRoot%\System32\diskpart.exe /s Q:\Disks\Cache.txt"`

## Additional notes

To detach a VHD using `diskpart.exe`:

```
select vdisk file="Q:\Disks\Cache.vhd"
detach vdisk
```

To attach a VHD using `diskpart.exe`:

```
select vdisk file="Q:\Disks\Cache.vhd"
attach vdisk
```

To unlink the _Package Cache_ folder from the VHD:

```
mountvol "%ProgramData%\Package Cache" /D
```

To link the _Package Cache_ folder with the VHD:

```
mountvol "%ProgramData%\Package Cache" \\?\Volume{0e930327-6da7-11e6-8211-d8a25e8438ad}
```

## Caveats

The volume ID will be different from the one mentioned in my examples, as
it gets assigned when the volume gets first created by `diskpart.exe`.

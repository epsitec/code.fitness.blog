+++
categories = ["win10", "vm"]
date = "2020-01-17T08:00:00+01:00"
title = "Windows 10 and VMware Workstation are not compatible"
+++

My PC applied the latest Windows Update (10.0.19041) last week, and then I deployed
WSL2 and played a little bit with it. Today, as I wanted to start one of my VMware
virtual machines, it greeted me with this message:

> VMware Workstation and Device/Credential Guard are not compatible.  
> VMware Workstation can be run after disabling Device/Credential Guard.

There is a [VMware Knowledge Base article](https://kb.vmware.com/s/article/2146361)
on the topic, but it did not help me a lot. I tried disabling Device Guard and
Credential Guard, but somehow, every setting was already conigured to disable both
services.

## Disabling Virtualisation-Based Security (VBS)

Running `msinfo32` as an administrator revealed that _Virtualisation-based security_
was enabled. I found
[this Microsoft article](https://docs.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage)
which explains how to disable it. It requires mounting the boot disk as drive `X:`
and then running a bunch of `bcdedit` commands:

```cmd
mountvol X: /s
copy %WINDIR%\System32\SecConfig.efi X:\EFI\Microsoft\Boot\SecConfig.efi /Y
bcdedit /create {0cb3b571-2f2e-4343-a879-d86a476d7215} /d "DebugTool" /application osloader
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} path "\EFI\Microsoft\Boot\SecConfig.efi"
bcdedit /set {bootmgr} bootsequence {0cb3b571-2f2e-4343-a879-d86a476d7215}
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO,DISABLE-VBS
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} device partition=X:
bcdedit /set vsmlaunchtype off
mountvol X: /d
```

I rebooted, Windows asked me to confirm that I wanted to disable the features at the
very start of the boot sequence. I pressed **F3** and voilà, or at least, that's what
I thought.

## Disabling Hyper-V

I confirmed that VBS was indeed desactivated, then I tried again to start VMware. But
this time, it complained that I had Hyper-V interfering, yet I had checked in the
_Turn on or off Windows features_ settings that Hyper-V was not enabled.

[HyperVSwitch.exe](https://unclassified.software/files/apps/hypervswitch/HyperVSwitch.exe)
showed that Hyper-V was indeed activated. I deactivated it and once again, rebooted my
PC.

## WTF?

When I attempted to launch VMware again, I was greeted with my initial error message,
again:

> VMware Workstation and Device/Credential Guard are not compatible.  
> VMware Workstation can be run after disabling Device/Credential Guard.

What was going on? Somehow, everything had been reverted back to the initial state.
After some digging around, I decided to **disable secure boot** in the BIOS settings
of my PC, then re-ran the scripts above and rebooted.

I've been able to successfully start my VM and I am back to normal. However, as I
expected, WSL2 is no longer working, as it [requires Hyper-V](https://docs.microsoft.com/en-us/windows/wsl/wsl2-faq).

> Please enable the Virtual Machine Platform Windows feature and ensure virtualization
> is enabled in the BIOS.  
> For information please visit https://aka.ms/wsl2-install

Yay.

There have been rumors that VMware is working on a Hyper-V compatible VMware Workstation
version, so for now, I'll wait, and restrain from using WSL2 on my main development
machine.

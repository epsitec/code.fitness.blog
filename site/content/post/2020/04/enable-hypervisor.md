+++
categories = ["windows"]
date =  "2020-04-08T07:00:00+01:00"
title = "Enable Hypervisor"
+++


Now that [VMware 20H1 Tech Preview](https://blogs.vmware.com/workstation/2020/01/vmware-workstation-tech-preview-20h1.html)
with Hyper-V support is available, I decided to upgrade my
[Worstation](https://pcsupport.lenovo.com/us/en/products/workstations/thinkstation-p-series-workstations/thinkstation-p910/30b9/30b9cto1ww/s4dj4570/downloads/DS112675)
in order to use [**WSL 2**](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install)
and [**Docker**](https://docs.docker.com/docker-for-windows/troubleshoot/#virtualization-must-be-enabled)
on top of Hyper-V.

I have however been struggling for hours to get Hyper-V to run. I consistently
got an error message, asking me to enable _Hardware assisted virtualization_
and _Hardware assisted data-execution protection_ in the BIOS.

1. I did not find any related setting in my BIOS, so I decided to reflash my
   in the hope this would help. I did not see any new options pop up.
   The [ThinkStation P910 User Guide](https://download.lenovo.com/pccbbs/thinkcentre_pdf/p910_ug_en.pdf?linkTrack=PSP:ProductInfo:UserGuide)
   was of no help either.
2. I made sure the Hyper-V role was installed.
3. I made sure that every option pertaining to Hyper-V was enabled by running
   `systeminfo` from the command prompt.

I vaguely remembered [disabling something related to Hyper-V](https://code.fitness/post/2020/01/vmware-windows-10-incompatible.html)
a few months ago (yes, I even [blogged](https://code.fitness/post/2020/01/vmware-windows-10-incompatible.html) about it),
and I finally realized that I had disabled the the hypervisor at boot time,
using `bcdedit`.

Here is how to turn the hypervisor back on:

```cmd
bcdedit /set hypervisorlaunchtype auto
```

Now I have:

- Hyper-V running.
- VMware running on top of Hyper-V.
- WSL 2 running on top of Hyper-V.
- Docker running on top of Hyper-V.

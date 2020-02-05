+++
categories = ["tools"]
date = "2020-02-05T17:00:00+01:00"
title = "Windows 10 and telnet (client)"
+++

I needed to install `telnet` on my new Windows 10 machine. Just in
case you are looking for a quick and easy one-liner to do the job,
here is the command, which has to be run from an elevated prompt:

```bat
dism /online /Enable-Feature /FeatureName:TelnetClient
```

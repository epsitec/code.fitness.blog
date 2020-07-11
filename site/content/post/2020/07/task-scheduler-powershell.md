+++
categories = ["windows", "tools"]
date =  "2020-07-11T06:00:00+01:00"
title = "Scheduling the recurring execution of a powershell script"
+++

The Windows **Task Scheduler** can be used to run tasks at predefined intervals,
e.g. once a day, and is very much like _cron jobs_ found on other systems.

Running Powershell scripts requires some attention, or nothing will happen when the
task scheduler launches it.

## Powershell script

I wanted to fetch the contents of a web page every morning, in order to have the
data handy without having to do the work manually. So I decided _not to use_ `wget`
for Windows, but instead rely on Powershell's ability to call directly into .NET:

```cmd
(new-object System.Net.WebClient).DownloadFile('https://foo.com/bar','D:\Data\bar.txt')
```

Running this shell script manually will prompt for the execution policy, in order
to make sure that I intend to execute the (possibly malicious) script. So scheduling
the execution of the script with the Task Scheduler will hang, as I won't be there
to press `[Y]` to allow for the script to be run.

## Starting a Powershell script, bypassing Execution Policy

The solution is to start `powershell.exe` instead of the `*.ps1` script, and
provide the `-ExecutionPolicy` argument in order to configure it to `Bypass`:

```cmd
powershell.exe -ExecutionPolicy Bypass C:\scripts\download-foo-bar.ps1
```

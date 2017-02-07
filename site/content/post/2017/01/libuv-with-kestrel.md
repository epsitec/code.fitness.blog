+++
categories = ["c#", "kestrel"]
date = "2017-01-18T11:07:27+01:00"
title = "Unable to load libuv"
+++

I've been using the _Kestrel_ server from `Microsoft.AspNetCore.Server.Kestrel`
in a Visual Studio 2015 `*.csproj` project with `project.json` file (i.e. a
portable class library targeting .NET Standard).

If I then try to start Kestrel from my main project (a .NET Framework 4.6.x
executable), I receive this error message at run time:

> System.InvalidOperationException: Unable to load libuv.

While searching for a solution to this issue, I have come across
[Kestrel issue 216](https://github.com/aspnet/KestrelHttpServer/issues/216)
which reports the same kind of behaviour. To summarize, this is a known
problem with Visual Studio 2015 and the _old projects_ which should be
solved in Visual Studio 2017.

## Temporary solution while waiting for Visual Studio 2017

For now, the easiest solution is to dig into the NuGet `packages` folder
and copy `libuv.dll` from _runtimes_ &rarr; _win7-x86_ &rarr; _native_ to
the main project, mark the DLL as _Content_ and configure the properties
so that it gets copied to the output path. Also make sure that the program
gets compiled as an x86 assembly.

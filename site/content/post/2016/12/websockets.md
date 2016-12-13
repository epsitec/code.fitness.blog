+++
categories = ["dotnet"]
date = "2016-12-13T16:22:27+01:00"
title = "WebSockets and .NET Core"
+++

The project I am working on, Lydia, has several layers which exchange information
using SignalR, on top of Nancy. I wanted to move away from the current mix of PCL
and .NET 4.5 Framework-targeting assemblies and unify the whole solution behind
the new **.NET Standard**.

## Switching to Nancy and SignalR for .NET Standard

A prerelease version of Nancy can be added to a .NET Standard 1.6 project. I got
it to run on top of Kestrel thanks to OWIN, after
[battling with the tools](http://code.fitness/post/2016/12/target-netstandard16.html).

SignalR is currently (December 2016) being rewritten in order to run on top of
Kestrel too, as a server component using the NuGet package `Microsoft.AspNetCore.SignalR.Server`.
However, I've not been able to find the _client counterpart_ to SignalR Server.
The current samples rely on a WebSockets client to talk to the server.

## Current WebSockets support

.NET Core comes with a clean asynchronous WebSockets client API, found in the
NuGet package `System.Net.WebSockets.Client`, available on multiple platforms
(apparently Windows, macOS and Linux). However, my first tests broke down with
a `PlatformNotSupportedException`.

[Windows 7 is not supported](http://stackoverflow.com/questions/12073455/net-4-5-websocket-server-running-on-windows-7)
by `System.Net.WebSockets.Client` for now. Minimum requirement is Windows 8.
However, my workstation is still running Windows 7 and I have no plans to replace
it in the near future.

So, what are my options? There are several client implementations of the
WebSocket protocol. I explored:

* [WebSocketSharp](https://github.com/sta/websocket-sharp)  
  Can be built as a single assembly, however not for .NET core. So I cannot
  use it from class libraries targeting .NET Standard 1.3. However, there is a
  [pull request](https://github.com/sta/websocket-sharp/pull/299) by galister
  who has a [fork for .NET Core](https://github.com/galister/websocket-sharp),
  which I discovered after having spent about two hours of coding to make my
  own port.
* [WebSocket4Net](https://github.com/kerryjiang/WebSocket4Net)  
  Available as a NuGet package, compatible with .NET Standard 1.3.

Both project expose WebSockets in a similar way, yet neither has true _async_
support (i.e. `Task` based). I found WebSocketSharp to have a richer API
(with _asynchronous methods_ based on callbacks) and WebSocket4Net to use
more .NET-friendly naming conventions.

But for now, I really just need the most basic support to get things rolling.
So I'll start with WebSocket4Net and wrap it in such a way that I can easily
replace it once WebSocketSharp is ripe.

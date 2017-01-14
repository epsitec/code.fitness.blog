+++
categories = ["debugging"]
date = "2016-12-06T16:12:14+01:00"
title = "Resolving assembly version mismatches"
+++

While migrating our Lydia solution from PCL to .NET Standard and upgrading
the various projects, my tests started to fail with the following exception:

> Could not load file or assembly 'System.Reactive.Interfaces, Version=3.0.0.0, Culture=neutral, PublicKeyToken=94bc3704cddfc263' or one of its dependencies. The located assembly's manifest definition does not match the assembly reference. (Exception from HRESULT: 0x80131040)

My test assembly `Tests.Epsitec.Extensions` targets .NET 4.6.2 and references
`System.Reactive`. It also references project `Epsitec.Extensions` which builds
an assembly adhering to .NET Standard 1.3, and which also references the NuGet
package for `System.Reactive`.

After installing `System.Reactive` v3.1.1, Visual Studio 2015 adds following
assemblies to both projects:

* System.Reactive.Core, v3.1.1
* System.Reactive.Interfaces, v3.1.1
* ...

## Broken test

When the test is executed, .NET tries to load assembly `Epsitec.Extensions`,
but this fails. Here is the detailed information (edited for clarity):

* DisplayName: System.Reactive.Interfaces, Version=3.0.0.0, PublicKeyToken=94bc3704cddfc263
* Appbase: file:///S:/git/rnd/lydia-dev/lydia/Tests.Epsitec.Extensions/bin/Debug
* Calling assembly: Epsitec.Extensions, Version=1.0.0.0, PublicKeyToken=...
* ...
* Using application configuration file: Tests.Epsitec.Extensions.dll.config
* Post-policy reference: System.Reactive.Interfaces, Version=3.0.0.0 ...
* ...
* Comparing the assembly name resulted in the **mismatch**: _Build Number_
* Failed to complete setup of assembly (hr = 0x80131040). Probing terminated.

So what's going on here?

When the test project starts, it loads `System.Reactive.Interfaces` (version
3.0.1000.0) found in _packages/System.Reactive.Interfaces.3.1.1/lib/net45_.

When .NET tries to load `Epsitec.Extensions`, no matching `System.Reactive.Interfaces`
can be located. Indeed, the assembly was compiled as .NET Standard 1.3 and thus refers
to another version (3.0.0.0) found in _packages/System.Reactive.Interfaces.3.1.1/lib/netstandard1.0_. 

This is a [known issue](https://github.com/Reactive-Extensions/Rx.NET/issues/299) and this
is [by design](https://github.com/Reactive-Extensions/Rx.NET/issues/205), as
Oren Novotny explains.

## Configure an assembly binding redirection

The solution is to add this `<dependentAssembly>` entry in the test project's _app.config_
file:

```xml
<dependentAssembly>
  <assemblyIdentity name="System.Reactive.Interfaces" publicKeyToken="94bc3704cddfc263" culture="neutral" />
  <bindingRedirect oldVersion="0.0.0.0-3.0.3000.0" newVersion="3.0.1000.0" />
</dependentAssembly>
```

This tells the loader to map all versions up to 3.0.3000.0 to the one which
gets loaded with the test project (3.0.1000.0). With this in place, everything
works fine again.
See [MSDN](https://msdn.microsoft.com/en-us/library/7wd6ex19.aspx) for
a detailed explanation.

## Root cause

Somehow, `System.Reactive.Interfaces` was not included in the redirects when
I added the NuGet package _System.Reactive_. Yet, there was a redirect for the
core assembly, `System.Reactive.Core`.

I don't know the reason for this. But with the current version of Visual Studio
2015 Update 3, the error is systematic.


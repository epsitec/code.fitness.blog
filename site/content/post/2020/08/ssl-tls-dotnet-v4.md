+++
categories = ["tools", "windows"]
date = "2020-08-22T06:00:00+01:00"
title = "Enable TLS 1.2 for legacy .NET 4.0 applications"
+++

Servers should not longer serve HTTPS over the [deprecated protocols TLS 1.0 and TLS 1.1](https://scotthelme.co.uk/legacy-tls-is-on-the-way-out/).
Modern web browsers are enforcing the move to TLS 1.2 by showing warnings about the HTTPS
connection not beeing secure if the server still accepts the older cryptographic suites.
Google led the way with the [deprecation of TLS 1.0 and 1.1 in Chrome 72](https://www.zdnet.com/article/google-chrome-72-removes-hpkp-deprecates-tls-1-0-and-tls-1-1/).
Firefox [disabled TLS 1.0 and 1.1 by default in January 2020](https://www.fxsitecompat.dev/en-CA/docs/2020/tls-1-0-1-1-support-has-been-disabled-by-default/).

## Hey, my tools can't talk TLS 1.2!

We switched off the old TLS versions on our servers in 2019. Immediately, some customers
started complaining that their tools could no longer talk to our servers, as they were
still using older Windows versions.

We kept a server around, accepting old TLS versions, and asked out customers to configure
their DNS to continue to use the legacy server.

## .NET 4.0 can't talk TLS 1.2

After several months, I came across a similar issue on perfectly up-to-date Windows 10
computers: some tool failed to connect over HTTPS to our public server using TLS 1.2.

After investigation, it appeared that the tool was based on .NET 4.0, which obviously
does not support TLS 1.2 out of the box.

Updating the tool to .NET 4.8 would certainly solve the issue, but it would be quite
time consuming (we cannot simply recompile it: the tool was being deployed using
technologies which are, alas, no longer supported by current Visual Studio versions).

## .NET 4.0 can be configured to talk TLS 1.2

Fortunately, Microsoft provides a way to [enable TLS 1.2 on .NET 4.0](https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/security/enable-tls-1-2-client#configure-for-strong-cryptography).

For this, open `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319` in
**regedit** as an administrator and add two `DWORD` values:

- `SchUseStrongCrypto` &rarr; 1
- `SystemDefaultTlsVersions` &rarr; 1

For 32-bit applications running on 64-bit systems, do the same on the matching WOW6432Node  
(`HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319`).

The same [configuration](https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/security/enable-tls-1-2-client#configure-for-strong-cryptography)
can also be applied to .NET 2.0.

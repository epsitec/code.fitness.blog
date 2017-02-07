+++
categories = ["dotnet"]
date = "2017-01-14T12:02:24+01:00"
title = "Finding .NET APIs"
+++

When searching for the implementation of a specific .NET API,
the [apisof.net](https://apisof.net/) has proven to be an invaluable
resource.

Want to know where `IEnumerator` is defined?

[Here](https://apisof.net/catalog/System.Collections.IEnumerator) is
an excerpt the reply:

* .NET Core 1.0 &rarr; System.Runtime, Version=4.1.0.0, PublicKeyToken=b03f5f7f11d50a3a
* .NET Framework 4.5 &rarr; mscorlib, Version=4.0.0.0, PublicKeyToken=b77a5c561934e089
* .NET Standard 1.3 &rarr; System.Runtime, Version=4.0.20.0, PublicKeyToken=b03f5f7f11d50a3a

This is really useful information when trying to make various projects
based on different technologies work together with the help of `app.config`
binding redirection.

+++
categories = ["c#"]
date = "2016-08-25T09:07:35+02:00"
title = "Get the folder of a .NET executable"
+++

In order to locate where a .NET executable has been loaded from,
you can simply write:

```csharp
var assembly = System.Reflection.Assembly.GetExecutingAssembly ();
var dir      = System.IO.Path.GetDirectoryName (assembly.Location);
```

This will return the path of the containing folder, not a `file://`
URI as you would get back by using `.CodeBase` instead of `.Location`
(see [this Stack Overflow question](http://stackoverflow.com/questions/837488/how-can-i-get-the-applications-path-in-a-net-console-application)
on the topic).

+++
categories = ["c#"]
date =  "2020-04-08T07:00:00+01:00"
title = "Cannot find reference assembly 'Microsoft.AspNetCore.Antiforgery.dll' file for package Microsoft.AspNetCore.Antiforgery"
+++

It happened again. I was trying to deploy a web service which uses `RazorLight` after updating
the code base. My service would not start, throwing this exception:

```
Cannot find reference assembly 'Microsoft.AspNetCore.Antiforgery.dll' file for package Microsoft.AspNetCore.Antiforgery
```

Just add following settings to your `*.csproj` file:

```xml
<PropertyGroup>
    <PreserveCompilationReferences>true</PreserveCompilationReferences>
    <PreserveCompilationContext>true</PreserveCompilationContext>
</PropertyGroup>
```

and this will solve the [issue](https://github.com/toddams/RazorLight/issues/294).

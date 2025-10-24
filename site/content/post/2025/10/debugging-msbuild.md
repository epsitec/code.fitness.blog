+++
categories = ["tools", "msbuild"]
date = "2025-10-24T06:02:00+02:00"
title = "Debugging MSBuild properties"
+++

I was working on a .NET 10 project called `Views.Blazor` and I did not understand why my Blazor Assets were packaged as `_content/Epsitec.Views.Blazor/...` and not just `_content/Views.Blazor/...`.

The documentation explains that for CSS isolation, the CSS files are bundled as `{PACKAGE ID/ASSEMBLY NAME}.styles.css`. The `{PACKAGE ID/ASSEMBLY NAME}` is derived from the `<PackageId>` MSBuild property [see CSS Isolation bundling](https://learn.microsoft.com/en-us/aspnet/core/blazor/components/css-isolation?view=aspnetcore-9.0#css-isolation-bundling).

### Add diagnostics to the .csproj

I added following `<Target>` to my .csproj file, in order to verify what was going on:

```xml
<Target Name="DisplayPackageId" BeforeTargets="Build">
  <Message Text="PackageId: $(PackageId)" Importance="high" />
  <Message Text="AssemblyName: $(AssemblyName)" Importance="high" />
  <Message Text="RootNamespace: $(RootNamespace)" Importance="high" />
</Target>
```

The build output was as expected:

```
------ Build started: Project: Views.Blazor, Configuration: Debug Any CPU ------
  Views.Blazor -> S:\git\solution\ui\Views.Blazor\bin\Debug\net10.0\Views.Blazor.dll
  PackageId: Epsitec.Views.Blazor
  AssemblyName: Views.Blazor
  RootNamespace: Epsitec.Views
```

The `<PackageId>` was indeed coherent with the names used for my Blazor Assets. But how did this `<PackageId>` get this name? The documentation was clear: in the absence of a `<PackageId>` definition in the project file, the fall-back is `$(AssemblyName)`, which is the same as the _project name_ (i.e. `Views.Blazor` in my case).

I asked different LLMs. Some explained that this was the result of some smart combination of the _root namespace_ and the _assembly name_ (nice try, but that was plain wrong). Finally, I tried Claude with extended thinking. After 5 minutes, I got back a [detailed explanation of how `<PackageId>` is initialized](https://claude.ai/public/artifacts/52dc266f-6ad0-4935-bb22-f1a8ab345ab1).

> The key insight is that **RootNamespace is not part of this chain** &ndash; it's an independent property. The project filename influences PackageId only indirectly through AssemblyName, and setting AssemblyName explicitly breaks that connection.
> For Razor Class Libraries, this derivation is particularly important because PackageId determines static asset paths, making it a breaking change to modify after initial development.

### PackageId mystery solved

Everything was pointing at the fact that some `Directory.Build.props` or `Directory.Build.targets` was doing some additional magic behind the scenes. But how can I find out what's going on?

That's where the [`-preprocess` switch (aka `-pp`)](https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference#switches) comes in handy. It produces a **full dump** of all the MSBuild scripts, bits and pieces which contribute to the build:

```cmd
dotnet msbuild Views.Blazor.csproj -pp:evaluated.xml
```

Digging through the (huge) `evaluated.xml` file, I finally discovered what was going on. Our toolchain (`zou`) was executing additional logic:

```xml
<!--
S:\git\solution\zou\Directory.Build.Default.targets
============================================================================================================================================
-->
  ...
  <PropertyGroup Condition="'$(IsPackable)' != 'false'">
    <PackageId Condition="'$(PackageId)' == ''">$(ProjectName)</PackageId>
    <PackageId Condition="!$(PackageId.StartsWith('$(Company)')) And !$(Company.Contains(' '))">$(Company).$(PackageId)</PackageId>
  </PropertyGroup>
```

and that's where the `Epsitec` comes from &ndash; it's our _company name_.

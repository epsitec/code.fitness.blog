+++
title = "Visual Studio 2019 16.2.0 Preview 1, C# 8.0 and Nullable"
categories = ["c#"]
date = 2019-05-23T05:41:15+02:00
+++

I've been gradually switching my projects to use the new **nullable
reference types** feature of C# 8.0, which required me to add following
snippet to the `*.csproj` files:

```xml
<PropertyGroup>
  <LangVersion>preview</LangVersion>
  <NullableContextOption>enable</NullableContextOption>
</PropertyGroup>
```

Visual Studio 2019 16.2.0 Preview 1, installed on May 22 2019, stopped accepting the nullable reference types with these warnings:

> CS8632: The annotation for nullable reference types should only be used in code within a '#nullable' context.

and also:

> CS8627: A nullable type parameter must be known to be a value-type or non-nullable reference type. Consider adding a 'class', 'struct' or type constraint.

Multiple people reported [this issue on developercommunity.visualstudio.com](https://developercommunity.visualstudio.com/content/problem/576567/nullablecontextoptions-no-longer-works.html).

## Solution

This has been confirmed by Microsoft as being the expected behaviour. The `<NullableContextOption>` settings has been replaced with the shorted `<Nullable>`:

```xml
<PropertyGroup>
  <LangVersion>preview</LangVersion>
  <Nullable>enable</Nullable>
</PropertyGroup>
```

As in my case I am [configuring all projects through a central `Dîrectory.Build.props` file](https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build?view=vs-2019#directorybuildprops-and-directorybuildtargets), I had to close and reopen the solution for Visual Studio 2019 to pick up the change.

## Directory.Build.props

Here is the `Directory.Build.props` file I use:

```xml
<Project>
  <PropertyGroup>
    <!-- Enable nullable reference types for all C# projects -->
    <LangVersion>preview</LangVersion>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
```

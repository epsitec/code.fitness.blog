+++
categories = ["VS"]
date = "2016-12-09T05:00:57+01:00"
title = "How to target .NET Standard 1.6 with Visual Studio 2015"
+++

While converting Lydia projects to **.NET Standard** I came across a blocking
issue. I needed to reference an assembly (Nancy 2.0.0) which requires at least
_.NET Standard 1.6_. Trying to add the NuGet package would fail, unless I told
Visual Studio 2015 Update 3 that the `*.csproj` file should target `.NETStandard1.6`.

![Library Settings in Visual Studio 2015](targeting-netstandard16.png) 

However, doing so breaks the build:

> Your project is not referencing the ".NETPlatform,Version=v5.0" framework.
> Add a reference to ".NETPlatform,Version=v5.0" in the "frameworks" section
> of your project.json, and then re-run NuGet restore

At first, I thought that I did not have the proper tooling installed. I tried
installing various versions of the .NET Core SDK and tools for Visual Studio 2015.
I tried on another machine. I tried it from the command line, by invoking `msbuild`
directly. Nothing helped.

However, calling `dotnet restore` followed by `dotnet build` from the command
line would work.

## Making Visual Studio happy again

Apparently, this is a [known issue](https://github.com/dotnet/roslyn/issues/12918)
and [Kristian Hellang](https://github.com/khellang) kindly [pointed it to me](https://github.com/NancyFx/Nancy/issues/2647).

In order to build a .NET Standard 1.6 library from Visual Studio 2015, a
`<NugetTargetMoniker>` has to be added at the very end of the `*.csproj` file.
Here is the final result:

```xml
  <PropertyGroup>
    <NuGetTargetMoniker>.NETStandard,Version=v1.6</NuGetTargetMoniker>
  </PropertyGroup>
</Project>
```

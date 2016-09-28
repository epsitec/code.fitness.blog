+++
categories = ["tools"]
date = "2016-09-26T14:47:48+02:00"
title = "Build just one project in a solution using msbuild"
+++

I've got a huge solution containing about 50 projects, some of which
take loads of time to rebuild from scratch, because they require half
of the Internet to be downloaded on the development machine.

From time to time, I need to rebuild just one project which produces
a tool, which I then package into a VSIX (Visual Studio extension).
To do this, I've written a small piece of PowerShell which, among
other things, triggers a rebuild of the said solution:

```
$Configuration = "`"Release`""
$MsBuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"

$BuildArgs = @{
  FilePath = $MsBuild
  ArgumentList = $SlnFilePath, "/t:Clean,Build", ("/p:Configuration=" + $Configuration), "/v:minimal"
  Wait = $true
  NoNewWindow = $true
}

Start-Process @BuildArgs
```

When you execute `msbuild`, you tell it which are the targets. In
my example above, they are `Clean` and `Build` (see the `"/t:..."`
where they are specified).

You can also specify the name of a project. In my case, the project
is stored in a subfolder of the solution, called `Lydia.Toolchain`
and the project file is `Lydia.Toolchain.csproj`.

I was expecting `/t:Lydia.Toolchain` to work. But no...

> error MSB4057: The target "Lydia.Toolchain" does not exist in
> the project.

So maybe this has something to do with the fact that my project is
in a subfolder? I asked my colleague Roger, who has spent months
in the depth of msbuild and its intricacies, while managing to
remain sane.

## SET MSBuildEmitSolution=1

To make long a long explanation short: the trick is to find out
which name to use for the _target_. To do so, follow 
[this tip](http://stackoverflow.com/a/5237948/4597) shared by
Ritch Melton on StackOverflow:

```
SET MSBuildEmitSolution=1
```

Then run a plain build. Locate the file with the `.metaproj` ending
and dig into it, until you find something like this:

```xml
  <Target Name="Lydia_Toolchain" Outputs="@(Lydia_ToolchainBuildOutput)">
    <MSBuild Condition="'%(ProjectReference.Identity)' == 'S:\git\rnd\lydia\Lydia.Toolchain\Lydia.Toolchain.csproj'" Projects="@(ProjectReference)" BuildInParallel="True" ToolsVersion="$(ProjectToolsVersion)" Properties="Configuration=Release; Platform=AnyCPU;BuildingSolutionFile=true; CurrentSolutionConfigurationContents=$(CurrentSolutionConfigurationContents); SolutionDir=$(SolutionDir); SolutionExt=$(SolutionExt); SolutionFileName=$(SolutionFileName); SolutionName=$(SolutionName); SolutionPath=$(SolutionPath)">
      <Output TaskParameter="TargetOutputs" ItemName="Lydia_ToolchainBuildOutput" />
    </MSBuild>
  </Target>
  <Target Name="Lydia_Toolchain:Clean">
    <MSBuild Condition="'%(ProjectReference.Identity)' == 'S:\git\rnd\lydia\Lydia.Toolchain\Lydia.Toolchain.csproj'" Projects="@(ProjectReference)" Targets="Clean" BuildInParallel="True" ToolsVersion="$(ProjectToolsVersion)" Properties="Configuration=Release; Platform=AnyCPU;BuildingSolutionFile=true; CurrentSolutionConfigurationContents=$(CurrentSolutionConfigurationContents); SolutionDir=$(SolutionDir); SolutionExt=$(SolutionExt); SolutionFileName=$(SolutionFileName); SolutionName=$(SolutionName); SolutionPath=$(SolutionPath)" />
  </Target>
  <Target Name="Lydia_Toolchain:Rebuild" Outputs="@(Lydia_ToolchainBuildOutput)">
    <MSBuild Condition="'%(ProjectReference.Identity)' == 'S:\git\rnd\lydia\Lydia.Toolchain\Lydia.Toolchain.csproj'" Projects="@(ProjectReference)" Targets="Rebuild" BuildInParallel="True" ToolsVersion="$(ProjectToolsVersion)" Properties="Configuration=Release; Platform=AnyCPU;BuildingSolutionFile=true; CurrentSolutionConfigurationContents=$(CurrentSolutionConfigurationContents); SolutionDir=$(SolutionDir); SolutionExt=$(SolutionExt); SolutionFileName=$(SolutionFileName); SolutionName=$(SolutionName); SolutionPath=$(SolutionPath)">
      <Output TaskParameter="TargetOutputs" ItemName="Lydia_ToolchainBuildOutput" />
    </MSBuild>
  </Target>
```

So in my case, the target is named `Lydia_Toolchain`.

## Back to my PowerShell script

```
$Configuration = "`"Release`""
$MsBuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"

$BuildArgsClean = @{
  FilePath = $MsBuild
  ArgumentList = $SlnFilePath, "/t:Lydia_Toolchain:Clean", ("/p:Configuration=" + $Configuration), "/v:minimal"
  Wait = $true
  NoNewWindow = $true
}

$BuildArgs = @{
  FilePath = $MsBuild
  ArgumentList = $SlnFilePath, "/t:Lydia_Toolchain", ("/p:Configuration=" + $Configuration), "/v:minimal"
  Wait = $true
  NoNewWindow = $true
}

Start-Process @BuildArgsClean
Start-Process @BuildArgs
```

The first execution of `msbuild` cleans up any build artefacts
whereas the second just builds what I need.

Roger told me that I don't want to use a single `/t:Lydia_Toolchain:Clean,Lydia_Toolchain`
target because in some edge cases, it won't do what I want. I'll
take his word on that!
 

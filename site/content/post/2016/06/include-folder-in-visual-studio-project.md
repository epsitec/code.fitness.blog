+++
categories = ["vs"]
date = "2016-06-12T14:50:24+02:00"
title = "Automatically include a folder in Visual Studio 2015"
+++

I was getting tired of manually tracking all files in a folder and adding them
to the `*.csproj` file in Visual Studio 2015, when I remembered my colleague
Roger Vuistiner talking about using `foo\**` as an include pattern.

Rather than tracking all files found in some subfolder I want to include
as content in my C# project, I just edited the `*.csproj` file manually
and added this:

```xml
    <Content Include="Content\electron\chrome-extensions\**">
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </Content>
```

And from now one, whatever I drop on `Content/electron/chrome-extensions`
will be picked up by Visual Studio. And this also works for nested
subfolders.

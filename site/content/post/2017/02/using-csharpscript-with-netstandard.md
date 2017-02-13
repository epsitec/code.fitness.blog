+++
categories = ["c#"]
date = "2017-02-07T09:05:44+01:00"
title = "Using CSharpScript with .NET Standard"
+++

I expected `CSharpScript` found in `Microsoft.CodeAnalysis.CSharp.Scripting`
to work with .NET Standard out of the box. But this was not the case. Trying
to compile the simplest of code snippets (e.g. returning `x+42m`, where `x`
is defined in some global type structure) failed:

```csharp
var options = ScriptOptions.Default;
var script  = CSharpScript.Create<decimal> ("x+42m", options: options, globalsType: typeof (Globals));
var func    = script.CreateDelegate ();
```

This code resides in an assembly defined as a class library targeting
.NET Standard 1.3 and is called from a .NET 4.6.2 console application.
When executed, `CreateDelegate()` throws:

> (1,1): error CS0012: The type 'Decimal' is defined in an assembly
> that is not referenced. You must add a reference to assembly
> 'System.Runtime, Version=4.0.20.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'.

## Solution

For this code to work, the `ScriptOptions` need to be configured in
order to include references to some system assemblies:

* A reference to `mscorlib.dll`.
* A reference to the loaded `System.Runtime.dll`
* A reference to `System.Threading.Tasks.dll` if async code needs to be generated.

This is done by calling `AddReferences()` with the `MetadataReference` taken
from the file paths:

```csharp
var options = ScriptOptions.Default
    .AddReferences (
        MetadataReference.CreateFromFile (typeof (object).GetAssemblyLoadPath ()),
        MetadataReference.CreateFromFile (TypeExtensions.GetSystemAssemblyPathByName ("System.Threading.Tasks.dll")),
        MetadataReference.CreateFromFile (TypeExtensions.GetSystemAssemblyPathByName ("System.Runtime.dll")));
```

The `TypeExtensions` class is defined as:

```csharp
public static class TypeExtensions
{
    public static string GetAssemblyLoadPath(this System.Type type)
    {
        return ServiceLocator.AssemblyLoader.GetAssemblyLoadPath (type.GetTypeInfo ().Assembly);
    }

    public static string GetSystemAssemblyPathByName(string assemblyName)
    {
        var root = System.IO.Path.GetDirectoryName (typeof (object).GetAssemblyLoadPath ());
        return System.IO.Path.Combine (root, assemblyName);
    }
}
```

_Note: we need to specify the absolute path to the assemblies found on disk for this to work._

Edit 1: the `ServiceLocator.AssemblyLoader.GetAssemblyLoadPath()` function is basically
just returning `assembly.Location` and belongs to code implemented in an IoC container
implemented by our framework.

Edit 2: the root of the problem is with `Globals` being defined in a third assembly,
implemented as a .NET Framwork portable class library as my
[GitHub Code Sample](https://github.com/epsitec/rnd-csharpscript-netstandard) demonstrates.

## Related articles

* GitHub: Roslyn issue 12393, [Predefined type 'System.Object' is not defined or imported](https://github.com/dotnet/roslyn/issues/12393).
* StackOverflow: ['Object' is defined in an assembly that is not referenced](http://stackoverflow.com/questions/38943899/net-core-cs0012-object-is-defined-in-an-assembly-that-is-not-referenced).
* StackOverflow: [C# scripting API does not load assembly](http://stackoverflow.com/questions/41340226/c-sharp-scripting-api-does-not-load-assembly/41356621#41356621).
* GitHub: Sample code [which shows issue](https://github.com/epsitec/rnd-csharpscript-netstandard).

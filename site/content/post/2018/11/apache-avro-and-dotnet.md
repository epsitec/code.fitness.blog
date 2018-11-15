+++
categories = ["core", "vs2017"]
date = "2018-11-15T13:40:53+01:00"
title = "Apache Avro and .NET"
+++

I am currently working on an implementation of an internal event bus,
which will only accept typed messages. Having experimented lately with
[Apache Kafka](https://kafka.apache.org) I decided that I would use the
[Apache Avro](https://avro.apache.org) serialization system.

## Existing Apache Avro libraries for .NET

While looking into Avro, I came across a Microsoft implementation which
is available under GitHub (see [Microsoft.Hadoop.Avro](https://github.com/Azure/azure-sdk-for-net/tree/master/src/ServiceManagement/HDInsight/Microsoft.Hadoop.Avro)), however the latest commit dates back to 2015 as of this writing.

Apache published [.NET bindings for Apache Avro](https://github.com/apache/avro), yet not as a .NET Standard library.

Another active player in the market is [Confluent](https://www.confluent.io/).
The company maintains its own fork under [GitHub](https://github.com/confluentinc/avro), but with the same limitation as the original Apache Avro C# library, making it incompatible with .NET Standard.

## Forking and publishing Epsitec's own Apache Avro library

I decided to fork the original [apache/avro](https://github.com/apache/avro)
to [epsitec-sa/avro](https://github.com/epsitec-sa/avro) and apply the minor
changes required to build `avro.main` as a `netstandard2.0` library.

* Update the Solution file to Visual Studio 2017.
* Create a `Microsoft.NET.Sdk` project file (`Avro.main.std.csproj`).
* Remove unused reference to `log4net` and update package references.
* Add the metadata needed to produce a NuGet package.

## Creating a NuGet package

The reference material required to create a NuGet package is rich.

I referred to [Create and Publish a Package using Visual Studio](https://docs.microsoft.com/en-us/nuget/quickstart/create-and-publish-a-package-using-visual-studio)
and [Publishing a Package](https://docs.microsoft.com/en-us/nuget/create-packages/publish-a-package#package-validation-and-indexing) to build my first package and get it listed on [nuget.org](https://www.nuget.org/packages/Epsitec.Apache.Avro) as `Epsitec.Apache.Avro`.

Publishing succeeded using this command line:

```bat
dotnet nuget push Epsitec.Apache.Avro.0.9.0.5.nupkg \
  -k ...API-key... \
  -s https://api.nuget.org/v3/index.json
```

## Adding SourceLink

While listening to [Epsiode 122 of Frank and James's MergeConflict podcast](https://www.mergeconflict.fm/122), I discovered [SourceLink](https://github.com/dotnet/sourcelink/) and decided to give it a try.

The NuGet package was therefore built and published using SourceLink and it
should provide a _greate source debugging experience_ for users who simply
add the package `Epsitec.Apache.Avro` to their project.

## Opening the Schema API

I needed to access the internal version of `Avro.Schema.Parse()`, as I needed
to specify a list of already parsed types. The original Apache Avro library
does not make this readly available to consumers. Now that I am working on a
fork, I can add the missing APIs rather than having to play with reflection
to reach `internal` methods. Yay!
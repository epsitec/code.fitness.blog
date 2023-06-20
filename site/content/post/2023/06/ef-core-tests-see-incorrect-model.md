+++
categories = ["c#", "efcore"]
date = "2023-06-20T10:30:00+02:00"
title = "Help, my tests using EF Core see an incorrect model"
+++

I'm still a relatively new and inexperienced user of EF Core (v7).
I am working with multiple test projects, which all use a common
`DbContext` called `DataFridgeDbContext`. The **DataFridge** library
I am developing provides dynamic registration and discovery of
entities, which are produced by some code generator, which is
turning all `IDbXxx` interfaces into `DbXxxEntity` classes:

```cs
public interface IDbEmployee
{
    string FirstName { get; }
    string LastName { get; }
    DateOnly BirthDate { get; }
}
```

## Testing the library

The model attached to the `DbContext` can therefore be completely
different from one project to another; this is even the case
between multiple tests in a given test project.

## Wrong model: the entity type was not found

When running my tests manually, one after the other, I never see
any issues. But as soon as I run two tests using different EF Core
models, I get weird errors:

```
System.InvalidOperationException: The entity type 'DbEmployeeEntity' was not found. Ensure that the entity type has been added to the model.
```

The stack trace points to `StateManager.GetOrCreateEntry()` which
relies on its constructor for its various related services, in
particular the `IModel` which happens to be the same instance in
the first and in the second test methods!

## Caching is (usually) your friend

Digging deeper into `StateManagerDependencies` and into EF Core's
source code on GitHub, I finally realized that there was some weird
`static` caching going on under the hood in order to speed up service
resolution.

For the curious, have a
look at [ServiceProviderCache.Instance](https://github.com/dotnet/efcore/blob/b0b202671f7879070423e95776edc014885335ad/src/EFCore/Internal/ServiceProviderCache.cs#L26)
on GitHub.

This caching is an essential feature which allows EF Core to perform
reasonably well. Without it, EF Core would have to analyze the schemas
at runtime, over and over again, every time a new instance of a
`DbContext` gets created.

For my tests, however, this is really annoying since I cannot afford
to create different `DbContext` classes for my various models (indeed,
this would defeat the very idea of dynamic discovery provided by the
**DataFridge**).

## Disable Service Provider Caching for your tests

Microsoft thanfully provides a solution to disable the caching
behavior. You have to call `EnableServiceProviderCaching(false)`
on the `DbContextOptionsBuilder` when configuring the `DbContextFactory`
used by the tests.

In my case, the initialization code looks like this:

```cs
services.AddPooledDbContextFactory<DataFridgeDbContext> (
    (sp, optionsBuilder) =>
    {
        // ...
        optionsBuilder.UseSqlite (connectionString, /* ... */);
        optionsBuilder.EnableSensitiveDataLogging (true);
        optionsBuilder.EnableServiceProviderCaching (false);
    });
```

See [this article on learn.microsoft.com](https://learn.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.dbcontextoptionsbuilder.enableserviceprovidercaching?view=efcore-7.0) for the documentation
of this feature.

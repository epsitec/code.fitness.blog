+++
categories = ["c#"]
date = "2016-04-24T08:46:34+02:00"
title = "Generic Type Resolution in C# and IOptional<T>"
+++

A few years ago, I wanted to implement three methods where I could pass
in either a value type (e.g. `int`), a reference type (e.g. `string`)
or a nullable value type (e.g. `int?`), using the exact same signature.

Handling the value type and nullable value type is straightforward:

```csharp
public static class Optional
{
    public static IOptional<T> From<T>(T value)
        where T : struct
    {
        // ...
    }
    
    public static IOptional<T> From<T>(T? value)
        where T : struct
    {
        // ...
    }
}
```

however, adding support for reference types like this:

```csharp
    public static IOptional<T> From<T>(T value)
        where T : class
    {
        // ...
    }
```

does not compile. The compiler generates the same signatures for
both `From<T>(T value)` methods, since the constraint does not
participate in the naming resolution.

> Type 'Optional' already defines a member called 'From' with the
> same parameter types.

I [asked the question on StackOverflow](http://stackoverflow.com/questions/2974519/generic-constraints-where-t-struct-and-where-t-class)
back in June 2010, and nobody could come up with a satisfying answer.

## There is (always?) a solution

User [Alcaro](http://stackoverflow.com/users/5182731/alcaro) provided
an answer two days ago (April 2016).

The trick is to help the compiler disambiguate both colliding function
signatures, by adding an optional parameter. With this, I no longer have
the previous error message:

```csharp
public static class Optional
{
    public static IOptional<T> From<T>(T value, Foo missing = null)
        where T : struct
    {
        // ...
    }
    
    public static IOptional<T> From<T>(T value, Bar missing = null)
        where T : class
    {
        // ...
    }
}
public class Foo { }
public class Bar { }
```

However, trying to call `From<T>()` does not work: 

> The call is ambiguous between the following methods or properties:
> 'Optional.From<T>(T, Foo)' and 'Optional.From<T>(T, Bar)' 

We no longer have collisions, but the compiler still does not know
how to resolve to either function, since both signature would match
when the optional argument is not provided by the caller.

The trick is to make `Foo` and `Bar` generic, and add a constraint
on their type argument, too:

```csharp
public static class Optional
{
    public static IOptional<T> From<T>(T value, Foo<T> missing = null)
        where T : struct
    {
        // ...
    }
    
    public static IOptional<T> From<T>(T value, Bar<T> missing = null)
        where T : class
    {
        // ...
    }
}
public class Foo<T> where T : struct { }
public class Bar<T> where T : class { }
```

The compiler is happy. It can decide which method signature it should
try to resolve to if I call `From(1)` before applying the type constraints
on `Foo<T>`:

* Method From<int>(int value, Foo<int> missing = null) matches.
* Method From<int>(int value, Bar<int> missing = null) will be rejected,
  since `Bar<int>` is not an acceptable type.

## Solution

Here is the complete solution, with more meaningful type names than
just _foo_ and _bar_. Note that there is no need for the optional
argument for `From<T>(T? value)` since it is the only `From` method
taking a `T?` for its first argument:

```csharp
public static class Optional
{
    public static IOptional<T> From<T>(T? value)
        where T : struct
    {
        // ...
    }
    
    public static IOptional<T> From<T>(T value, RequireStruct<T> missing = null)
        where T : struct
    {
        // ...
    }
    
    public static IOptional<T> From<T>(T value, RequireClass<T> missing = null)
        where T : class
    {
        // ...
    }
}
public class RequireStruct<T> where T : struct { }
public class RequireClass<T> where T : class { }
```

**Update**: Jon Skeet pointed me to [this 2010 blog post](https://codeblog.jonskeet.uk/2010/11/02/evil-code-overload-resolution-workaround/)
which covers basically the same topic.

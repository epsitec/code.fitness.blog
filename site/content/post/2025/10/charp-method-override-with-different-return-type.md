+++
categories = ["c#"]
date = "2025-10-23T14:20:00+02:00"
title = "Why Can This C# Override Have a Different Return Type?"
+++

I stumbled upon a piece of C# code the other day that made me do a double-take. It looked something like this.

At a glance, it seems to defy a fundamental rule of C# inheritance.

### The "Problem" Code

Here’s a simplified version of what I saw:

```csharp
using System;
using System.Linq;
using System.Collections.Generic;

public class Program
{
    public static void Main()
    {
        var a = new Generic<FieldValue> ();
        var b = new Generic<TextFieldValue> ();
        
        var fa = a.GetFieldValue ();
        var fb = b.GetFieldValue ();
        
        Console.WriteLine ($"{fa} of type {fa.GetType ().Name}");
        Console.WriteLine ($"{fb} of type {fb.GetType ().Name}");
    }
}

/*****************************************************************************/

public interface IStaticCreate
{
    static abstract FieldValue Create();
}

/*****************************************************************************/

public record FieldValue(int Id)
    : IStaticCreate
{
    static FieldValue IStaticCreate.Create() => new FieldValue (1);
}

public record TextFieldValue(int Id, string Text)
    : FieldValue(Id), IStaticCreate
{
    static FieldValue IStaticCreate.Create() => new TextFieldValue (2, "bla");
}

/*****************************************************************************/

public abstract class AbstractBase
{
    public abstract FieldValue GetFieldValue();
}

public class Generic<T> : AbstractBase
    where T : FieldValue, IStaticCreate
{
    public override T GetFieldValue() // <-- This is the weird part
    {
        var result = T.Create();
        return (T)result;
    }
}
```

When you run this, the output is:

```text
FieldValue { Id = 1 } of type FieldValue
TextFieldValue { Id = 2, Text = bla } of type TextFieldValue
```

### So, What's Going On?

Look at the `Generic<T>` class. It inherits from `AbstractBase`, which has an abstract method:

```csharp
public abstract FieldValue GetFieldValue();
```

But the override in `Generic<T>` is:

```csharp
public override T GetFieldValue()
```

How is this allowed? I always thought an overriding method had to have the exact same signature as the method it's overriding, including the return type.

It turns out this is a feature called **Covariant Return Types**.

### The Answer: C# 9 Covariant Return Types

This feature was introduced in **C# 9.0** (which shipped with .NET 5 back in November 2020).

Covariant return types allow an overriding method to return a type that is _more derived_ than the return type of the base class method.

The magic that makes it all work is the generic constraint on `Generic<T>`:

```csharp
where T : FieldValue, IStaticCreate
```

This constraint guarantees to the compiler that whatever `T` is, it will _always_ be a `FieldValue` or a class that inherits from `FieldValue` (like `TextFieldValue`).

Because the compiler has this guarantee, it knows that any `T` returned by the override is assignable to the `FieldValue` required by the base method. The rule is satisfied.

### Why Is This Useful?

This isn't just a neat trick; it's incredibly useful for type safety.

Look at the `Main` method again:

```csharp
var b = new Generic<TextFieldValue> ();
var fb = b.GetFieldValue ();
```

The compiler knows that `b.GetFieldValue()` returns a `TextFieldValue`, not just a `FieldValue`. The variable `fb` is correctly inferred as `TextFieldValue`. This means we can immediately access its `Text` property (`fb.Text`) without having to do an ugly and potentially unsafe cast.

Before C# 9.0, this code wouldn't have compiled. You would have been forced to write the override like this:

```csharp
// The "old" way
public override FieldValue GetFieldValue()
{
    var result = T.Create();
    return result;
}
```

...and then the caller would have to cast the result:

```csharp
// The "old" way at the call site
var b = new Generic<TextFieldValue> ();
var fb_base = b.GetFieldValue (); // fb_base is FieldValue
var fb = (TextFieldValue)fb_base; // Nasty cast needed
```

So, if you see an override returning a more specific type than its base, don't panic. It's not a bug, it's C# 9.0 making our lives just a little bit better.

### Reference

- [Covariant returns](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/proposals/csharp-9.0/covariant-returns)

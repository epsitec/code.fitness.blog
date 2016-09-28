+++
categories = ["c#"]
date = "2016-09-28T17:07:27+02:00"
title = "LINQ and OrderBy"
+++

I needed to order a collection of properties in C# and I immediately
grabbed for LINQ:

```
var result = items.OrderBy (x => x.Name);
```

I was surprised to see that the default comparer used by `OrderBy`,
when applied to _strings_, is **case insensitive**:
given `a`, `B`, `c` the code produces `a`, `B`, `c` as the sorted
result.

In my case, I needed to apply an **ordinal sort**.
What I really want is `B`, `a`, `c` (`B` has ASCII code 66 and `a`
has ASCII code 97). 

## IComparer&lt;string&gt;

`OrderBy()` comes with an overload, which takes an `IComparer<T>`
as its second argument. However, having to implement a comparer
like this one is overkill:

```
internal sealed class NameComparer : IComparer<string>
{
    public static readonly NameComparer Instance = new NameComparer();

    public int Compare(string x, string y)
    {
        int length = Math.Min (x.Length, y.Length);
        for (int i = 0; i < length; ++i) {
            if (x[i] == y[i]) continue;
            return x[i].CompareTo (y[i]);
        }

        return x.Length - y.Length;
    }
}
```

There are already multiple comparers in `System.StringComparer`:

* `Ordinal`, `OrdinalIgnoreCase` &rarr; ordinal comparisons.
* `CurrentCulture`, `CurrentCultureIgnoreCase` &rarr; comparisons
  based on the current culture.

So finally, my code looks like this:

```
var result = items.OrderBy (x => x.Name, System.StringComparer.Ordinal);
```

Thanks to Brian Gerspacher who [pointed me to this solution](http://stackoverflow.com/a/37285959/4597).
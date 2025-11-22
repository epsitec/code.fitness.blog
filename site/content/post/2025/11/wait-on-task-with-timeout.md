+++
categories = ["c#"]
date = "2025-11-22T11:37:00+02:00"
title = "Wait on a Task with a timeout"
+++

I've lost count of how many times I wrote code like this to implement a timeout on an asynchronous operation that doesn't support cancellation.

```csharp
var task  = ...
var delay = Task.Delay(timeout);
var finalTask = await Task.WhenAny(task, delay);

if (finalTask == task)
{
    await task;
}
```

## A built-in solution in .NET

The `Task` class provides **since .NET 6** a method which does exactly what I need:

```csharp
var task = ...
await task.WaitAsync(TimeSpan.FromMilliseconds(timeout));
```

Much cleaner, and there a [several overloads available](https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.task.waitasync):

- `WaitAsync(CancellationToken)`
- `WaitAsync(TimeSpan)`
- `WaitAsync(TimeSpan, CancellationToken)`
- ...

There are even variants accepting a `TimeProvider`, which makes testing easier.  
Combined with [`FakeTimeProvider`](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.time.testing.faketimeprovider), you can test timeouts without relying on real delays.

> Note: If you already have a `CancellationToken` for the operation, prefer the overload that combines timeout + token to avoid layering multiple cancellation paths.

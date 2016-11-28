+++
categories = [".net", "rx"]
date = "2016-11-28T09:25:36+01:00"
title = "Deep dive into rx SelectMany"
+++

Let's say we have an observable source of events (`obs1`). Every time an event
gets fired, some asynchronous method (`SomeAsyncMethod()`) must be applied to it.
The result of the asynchronous operation must be observable too (`obs2`).

`SelectMany()` provides exactly what is needed to do the job:

```c#
var obs1 = ...
var obs2 = obs1.SelectMany (x => SomeAsyncMethod (x));
```

with `SomeAsyncMethod()` returning a `Task<T>`.

# Where does this pattern come from?

Paul Betts [published this advice](http://log.paulbetts.org/rx-and-await-some-notes/)
back in January 2014, which I've been applying ever since:

> ## Async SelectMany
> 
> SelectMany has a super useful overload where you can write an awaitable method as a selector:
> ```c#
> var listOfUrls = new[] {  
>     "http://foo",
>     "http://foo",
>     "http://foo",
> };
> 
> listOfUrls.ToObservable()  
>     .SelectMany(async x => {
>         var wc = new WebClient();
>         return await wc.DownloadStringTaskAsync(x);
>     })
>     .Subscribe(Console.WriteLine);
> ```

But what's going on behind the scenes?

# Let's try an experiment

I was wondering what was going on as the observable source pushes an event
down the observer chain, calling into `SelectMany`'s provided `OnNext()`
implementation, tunneling into `SomeAsyncMethod()`... Would the original
producer of the event remain blocked until the asynchronous operation
completes?

## Building rx from source

The source code for `SelectMany` can be found on [GitHub](https://github.com/Reactive-Extensions/Rx.NET/tree/master/Rx.NET/Source).
I cloned the full rx repository and built just enough of it to be able
to step through the code:

```
git clone https://github.com/Reactive-Extensions/Rx.NET.git
cd Rx.NET
cd Rx.NET
cd Source
.\build-new.ps1
```

## Setting up a test bed

I then created a small console application which would allow me to
experiment with `SelectMany`. In order to control exactly what is going
on, I used a custom event producer (the `Pump` class) to push two values
and then complete the observable sequence. I added references to the rx
assemblies built from the source.

```c#
var pump = new Pump ();
var obs1 = pump as System.IObservable<int>;
var obs2 = obs1.SelectMany (x => Program.AsyncWork (x));

using (var subs = obs2.Subscribe (
    x => System.Console.WriteLine ($"Observer.OnNext({x})"),
    () => System.Console.WriteLine ("Observer.OnCompleted()")))
{
    pump.Push (1);
    pump.Push (2);
    pump.Done ();
    System.Console.WriteLine ("Press RETURN when done");
    System.Console.ReadLine ();
}
```

And here is the asynchronous method:

```c#
static async Task<int> AsyncWork(int value)
{
    System.Console.WriteLine ($"AsyncWork({value}): begin");
    await Task.Delay (100*value);
    System.Console.WriteLine ($"AsyncWork({value}): done");
    return value * 2;
}
```

Running this code prints this sequence of messages (without pressing
any key):

> AsyncWork(1): begin  
> AsyncWork(2): begin  
> Press RETURN when done  
> AsyncWork(1): done  
> Observer.OnNext(2)  
> AsyncWork(2): done  
> Observer.OnNext(4)  
> Observer.OnCompleted()  

## Stepping through the code

Stepping into `SelectMany` leads us quickly into the internals of the
`System.Reactive.Linq`, into class `QueryLanguage` which simply returns
an observable:

```c#
return new SelectMany<TSource, TResult>(source, (x, token) => selector(x));
```

The _source_ references my event pump and the _selector_ maps to my
asynchronous method. Nothing else of interest is going on here.

Next, let's step into `Subscribe()`. We finally reach the implementation
of the `SelectMany<TSource, TResult>` class:

```c#
var sink = new SelectManyImpl(this, observer, cancel);
setSink(sink);
return sink.Run();
```

`sink.Run()` sets up a composite disposable which will be used both
to manage the potential cancellation of the operation and the disposal
of the chained subscription, as my `Pump.Subscribe()` method gets invoked.
An internal counter (`_count`) gets set to `1`.

Next, we'll push an event. This will trigger `SelectMany.OnNext()`:

* It increments `_count`.
* It executes the selector (i.e. starts my async method) and stores
  the returned task for further processing.
* It checks if the task executed synchronously. If so, it calls its
  internal `OnCompleted()` method. If not, it queues the completion
  with `task.ContinueWith(OnCompletedTask)`.

Method `OnNext()` returns while the asynchronous method is still
running. And thus, the second call to `Push()` will get executed,
as will my call to `Pump.Done()` which notifies the observer that
the sequence has completed.

Stepping into `Pump.Done()` will eventually reach `SelectMany.OnCompleted()`
which decrements `_count` and verifies if it has reached zero. As this
is not the case (it started as `1` and was incremented twice by the
calls to `OnNext()`, and got decremented by `OnCompleted()`, its value
is now `2`), the method returns without any further work.

## After the await

As soon as the asynchronous method returns a value, the configured
continuation gets triggered (`SelectMany.OnCompletedTask()`). It
then calls the next observer (`OnNext()`) and calls its own `OnCompleted()`
in order to decrement `_count`.

When the 2nd asynchronous method returns its result, we finally get
`_count` back to zero again in `OnCompleted()`, which will trigger
the call to the next observer's `OnCompleted()` method, followed
by the disposal of the ressources.

# Observations (about the experiment)

So, what did I learn?

`SelectMany()` is a smart beast. It effectively decouples the event
producer (the input stream), the asynchronous projection method and
the production of new events in the output stream.

* The output stream is **decoupled** from the input stream.  
  Many events can happen on the input stream before anything appears
  on the output stream.
* The input stream can be **completed** without having any direct and
  immediate effect on the output stream. Pending asynchronous
  operations will have to be completed first.
* **Ordering** of events is **not preserved**.  
  The events appear
  sequentially on the output stream (i.e. the observer's `OnNext()`
  implementation will be called without any overlapping), but not
  necessarily in the same order as the input events.

To mitigate the ordering issue, `SelectMany()` has an overload which
takes a selector with signature `Func<TSource, int, Task<TResult>>`.

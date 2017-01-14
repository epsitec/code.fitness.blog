+++
categories = ["c#", "vs"]
date = "2017-01-14T10:55:47+01:00"
title = "Resolving Assembly Reference conflicts (2)"
+++

In [a previous blog post](http://code.fitness/post/2016/12/msbuild-assembly-conflict.html)
I explored the solution recommended by Microsoft to resolve
MSB3247 warnings, but it proved to be a little bit too tedious.

While converting the Lydia solution to .NET Standard instead of the
plain old PCLs, I came again across the annoying compilation warning:

> No Way to Resolve Conflict Between "Foo.Bar, Version=1.0.0.0" and
> "Foo.Bar, Version=1.2.0.0"...

My project was referencing version 1.2.0.0, but somehow one of the
other references required version 1.0.0.0. I was clueless.

I considered inspecting manually every referenced assembly with
Reflector to identify the culprit, but since I have several dozens
of references, I decided that I needed a tool...

## AsmSpy to the rescue

Once more, StackOverflow provided [a solution](http://stackoverflow.com/questions/1871073/resolving-msb3247-found-conflicts-between-different-versions-of-the-same-depen)
(note that this is the same question as the one I referred to in
[my previous post](http://code.fitness/post/2016/12/msbuild-assembly-conflict.html)).
Reading again the replies, I discovered **AsmSpy**, a tool written
by Mike Hadlow which does exactly what I needed: analyze all
assemblies found in a folder (such as `bin/Debug`) and dump the
list of all references.

You'll find [AsmSpy on GitHub](https://github.com/mikehadlow/AsmSpy)
and some details in [Mike's blog](http://mikehadlow.blogspot.ch/2011/02/asmspy-little-tool-to-help-fix-assembly.html).

Here is a typical dump from `AsmSpy bin\Debug` command:

    Reference: Foo.Bar
        1.0.0.0 by Shared.Blah
        1.2.0.0 by Foo.Consumer

So the culprit was `Shared.Blah` which was still referencing an old
version of `Foo.Bar`. Since I was the author of `Shared.Blah`, I
could simply update it.

Otherwise, I would have had to define a
`<bindingRedirect>` as [explained here](http://code.fitness/post/2016/12/assembly-binding-redirect.html).

+++
categories = [""]
date = "2019-02-12T06:14:10+01:00"
title = "Remote Desktop and High DPI"
+++

Thanks to [Chris K.'s blog post](https://poweruser.blog/remote-desktop-client-on-hidpi-retina-displays-work-around-pixel-scaling-issues-1529f142ca93)
I finally found a nice solution to open an RDP connection
to a remote host from my HiDPI laptop. Basically, the solution
is to copy `mstsc.exe` and set its `AppCompatFlag` to make it
_DPI unaware_:

```cmd
cd C:\Windows\System32
copy mstsc.exe mstsc2.exe
copy en-us\mstsc.exe.mui en-us\mstsc2.exe.mui
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /t REG_SZ /v "C:\Windows\System32\mstsc2.exe" /d "~ DPIUNAWARE" /f
```

## Interesting side-effects

When running the modified instance of the remote desktop client
`mstsc2.exe` with one of my servers, I could no longer execute
one of my .NET command line applications. It crashed mysteriously
very early in its startup code.

After investigating, I found that setting the width of the console
could indeed throw an exception:

```csharp
// Can throw ArgumentOutOfRangeException
System.Console.SetWindowSize (width, System.Console.WindowHeight);
```

## Hack, works only when using an English locale

In order to solve this issue, I added a hack in order to limit the
width of the console to what the exception reports; in its error
message, it says _maximum window size of 160_ (for instance). It's
a hack, but it works in my environment.

```csharp
try
{
    System.Console.SetWindowSize (width, System.Console.WindowHeight);
}
catch (System.ArgumentOutOfRangeException ex)
{
    var find = "maximum window size of ";
    var message = ex.Message;
    var pos = message.IndexOf (find);

    if (pos < 0) throw;

    message = message.Substring (pos + find.Length);
    pos = message.IndexOf (' ');

    if (pos < 0) throw;

    message = message.Substring (0, pos);

    width = int.Parse (message, System.Globalization.CultureInfo.InvariantCulture);
    System.Console.SetWindowSize (width, System.Console.WindowHeight);
}
```

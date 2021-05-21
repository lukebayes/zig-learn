![](assets/ziglander.png)

# Zig Questions
First of all, even though I've hit some stumbling blocks, I'm really enjoying the language and looking forward to getting productive with it.

Huge thanks to all the folks who have worked so hard on it, especially [Andy](https://github.com/andrewrk/). Please don't let the bastards (or the bugs) get you down! You've all made something exceptional here.

Here's some introductory info:

I'm building and running on `Ubuntu 20.04.2 LTS` and `zig version 0.8.0-dev.2275+8467373bb`.

Build and run for Linux with: `zig build run`

Build and run for Windows with: `zig build -Dtarget=x86_64-windows-gnu && wine64 dist/console.exe`

## Building and Loading Windows DLLs

When building for Windows, I get the following linker error:
```zig
zig build -Dtarget=x86_64-windows-gnu
current os tag: Tag.windows
Builder is_windows: true
lld-link: error: undefined symbol: CoCreateInstance
>>> referenced by /home/lukebayes/Projects/learning/zig/win-link/lib_win.zig:27
>>>               /home/lukebayes/Projects/learning/zig/win-link/zig-cache/o/a124fe49b6327e6a5d3725e63ec92408/console.o:(lib_win.getDefaultDevice)

lld-link: error: undefined symbol: CLSID_MMDeviceEnumerator
>>> referenced by /home/lukebayes/Projects/learning/zig/win-link/zig-cache/o/a124fe49b6327e6a5d3725e63ec92408/console.o:(.refptr.CLSID_MMDeviceEnumerator)

lld-link: error: undefined symbol: IID_IMMDeviceEnumerator
>>> referenced by /home/lukebayes/Projects/learning/zig/win-link/zig-cache/o/a124fe49b6327e6a5d3725e63ec92408/console.o:(.refptr.IID_IMMDeviceEnumerator)
error: LLDReportedFailure
console...The following command exited with error code 1:
/home/lukebayes/src/zig-linux-x86_64-0.8.0-dev.2275+8467373bb/zig build-exe /home/lukebayes/Projects/learning/zig/win-link/main.zig -lc --cache-dir /home/lukebayes/Projects/learning/zig/win-link/zig-cache --global-cache-dir /home/lukebayes/.cache/zig --name console -target x86_64-windows-gnu --pkg-begin sdk /home/lukebayes/Projects/learning/zig/win-link/lib.zig --pkg-end --enable-cache 
error: the following build command failed with exit code 1:
/home/lukebayes/Projects/learning/zig/win-link/zig-cache/o/ef988d19f9b3df84910ba28c7b165b94/build /home/lukebayes/src/zig-linux-x86_64-0.8.0-dev.2275+8467373bb/zig /home/lukebayes/Projects/learning/zig/win-link /home/lukebayes/Projects/learning/zig/win-link/zig-cache /home/lukebayes/.cache/zig -Dtarget=x86_64-windows-gnu
```

Some things I've tried:

1) Build it with zig version 0.7, same problem (I think), but v0.8x has much more helpful error messages

2) Check out the `zig-cache/o/[hash]/cimport.zig` file. These 3 definitions are clearly declared and externed in that file. I'm assuming this is irrelevant as these declarations are like C headers, and probably only helpful before the link phase?

3) Even if I null out the two CLSID_MMDeviceEnumerator and IID_IMMDeviceEnumerator, I still get the same failure on CoCreateInstance

4) Remove the mm namespace prefix from CoCreateInstance so that the `usingnamespace std.os.windows` is used (same result)

5) Comment (and uncomment) a bunch of Windows DLLs from the library build definition. Pretty sure `CoCreateInstance` is in the `ole32` dll, but I'm not 100% certain, just trying some shotgun ideas to get unblocked...
```zig
    if (is_windows) {
        // Uncommenting the following, still leaves me with three errors
        // "error: undefined symbol: CoCreateInstance"
        // "error: undefined symbol: CLSID_MMDeviceEnumerator"
        // "error: undefined symbol: IID_IMMDeviceEnumerator"
        lib.linkSystemLibrary("advapi32");
        lib.linkSystemLibrary("comdlg32");
        lib.linkSystemLibrary("gdi32");
        lib.linkSystemLibrary("kernel32");
        lib.linkSystemLibrary("ole32");
        lib.linkSystemLibrary("oleaut32");
        lib.linkSystemLibrary("user32");
        lib.linkSystemLibrary("uuid");
    }
```

6) Verified that I can talk to **some** windows APIs, by loading and showing a MessageBox from [this example](https://www.reddit.com/r/Zig/comments/cf7ggv/is_there_an_example_windows_message_box_hello/).

7) Comment and uncomment other cInclude statements in the lib_win.zig file.

```zig
const mm = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
    @cInclude("mmdeviceapi.h");
    @cInclude("audioclient.h");
    @cInclude("combaseapi.h");
});

// also swap the using statement and mm. prefixes elsewhere.
```

Any tips would be appreciated!

## Building a general library that loads and brings native libraries on host platforms

Are there better ways to do what I'm trying to do here?

Some things I'm not sure about are:

1) Because the entire interface is defined in each platform file, it's too easy to modify it for one platform which breaks it for another.
2) There's quite a bit of duplication across the platform definitions
3) I was trying to do something [like this](https://www.nmichaels.org/zig/interfaces.html) with a more functional approach, but I couldn't get the type system to play nice with my concrete type(s). It felt like I needed to either (a) create circular dependencies to bring shared definitions into the native modules or (b) push platform-specific comptime types all over the application.

I've got that nagging feeling that I've just missed something simple somewhere.

## Platform-specific build artifacts
I'd prefer to have an "all" task that builds all of the artifacts I expect and then to be able to limit that with specific task names.

For example, I would like `zig build` create the following artifacts, without regard for the host OS.

* Linux static library
* Linux dynamic library
* Windows static library
* Windows dynamic library
* Linux executable
* Windows executable

Tips appreciated!


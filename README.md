# Zig Questions
This project is being built on Ubuntu 20.10 and zig version 0.8.0-dev.2275+8467373bb.

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

## Building a library with native links across platforms
As a sanity check, does this structure look like idiomatic zig?

Are there better ways to do what I'm trying to do here?

Essentially, I want to have a single interface with concrete implementations across a variety of supported platforms.

Some things I don't like about this approach:

1) Because the entire interface is defined in each platform file, it's too easy to modify it for one platform and break it for another.
2) There's quite a bit of duplication across the platform definitions
3) I was trying to do something [like this](https://www.nmichaels.org/zig/interfaces.html) with a more functional approach, but I couldn't get the type system to play nice with my concrete type(s).

## Platform builds
I'd prefer to have an "all" task that builds all of the artifacts I expect and then to be able to limit that with specific task names.

For example, I would like `zig build` create the following artifacts, without regard for the host OS.

* Linux static library
* Linux dynamic library
* Windows static library
* Windows dynamic library
* Linux executable
* Windows executable


const std = @import("std");

const mm = @cImport({
    // @cDefine("WIN32_LEAN_AND_MEAN", "1");
    // @cInclude("windows.h");
    @cInclude("mmdeviceapi.h");
    @cInclude("audioclient.h");
    @cInclude("combaseapi.h");
});

usingnamespace std.os.windows;
// usingnamespace mm;

const DEFAULT_DEVICE_NAME = "[unknown]";

pub const AudioDevice = struct {
    name: []const u8 = DEFAULT_DEVICE_NAME,
};

pub fn info() []const u8 {
    return "WINDOWS";
}

pub fn getDefaultDevice() AudioDevice {
    std.debug.print("getDefaultDevice\n", .{});

    // Comment the following 2 lines to get a working Windows build.
    var ptr: ?*c_void = null;
    var status: HRESULT = mm.CoCreateInstance(&mm.CLSID_MMDeviceEnumerator, null, mm.CLSCTX_ALL, &mm.IID_IMMDeviceEnumerator, &ptr);
    return AudioDevice{};
}

// Confirmed that process attach and detach are actually called from a simple C# application.
pub export fn DllMain(hInstance: std.os.windows.HINSTANCE, ul_reason_for_call: DWORD, lpReserved: LPVOID) BOOL {
    switch (ul_reason_for_call) {
        mm.DLL_PROCESS_ATTACH => {
            std.debug.print("win32.dll PROCESS ATTACH\n", .{});
        },
        mm.DLL_THREAD_ATTACH => {},
        mm.DLL_THREAD_DETACH => {},
        mm.DLL_PROCESS_DETACH => {
            std.debug.print("win32.dll PROCESS DETACH\n", .{});
        },
        else => {},
    }
    return 1;
}

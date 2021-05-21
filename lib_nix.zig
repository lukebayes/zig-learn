const std = @import("std");

const DEFAULT_DEVICE_NAME = "[unknown]";

pub const AudioDevice = struct {
    name: []const u8 = DEFAULT_DEVICE_NAME,
};

pub fn info() []const u8 {
    return "LINUX";
}

pub fn getDefaultDevice() AudioDevice {
    std.debug.print("lib_nix.getDefaultDevice\n", .{});
    return AudioDevice{};
}

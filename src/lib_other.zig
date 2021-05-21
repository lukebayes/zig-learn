const std = @import("std");

const DEFAULT_DEVICE_NAME = "[unknown]";

pub const AudioDevice = struct {
    name: []const u8 = DEFAULT_DEVICE_NAME,
};

pub fn info() []const u8 {
    return "OTHER";
}

pub fn getDefaultDevice() AudioDevice {
    std.debug.print("lib_other.getDefaultDevice\n", .{});
    return AudioDevice{};
}

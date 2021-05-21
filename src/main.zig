const std = @import("std");
const lib = @import("lib.zig");

pub fn main() u8 {
    std.debug.print("Main loop started\n", .{});
    std.debug.print("running with: {s}\n", .{lib.info()});
    const device = lib.getDefaultDevice();
    std.debug.print("AudioDevice: {s}\n", .{device});
    return 0;
}

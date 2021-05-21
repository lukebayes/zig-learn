const std = @import("std");
const target_file = switch (std.Target.current.os.tag) {
    .windows => "lib_win.zig",
    .linux => "lib_nix.zig",
    else => "lib_other.zig",
};
const platform = @import(target_file);

pub usingnamespace platform;

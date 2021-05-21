const std = @import("std");

// To build for Windows, run:
// zig build -target x86_64-windows-gnu && wine64 dist/console.exe
pub fn build(b: *std.build.Builder) void {
    const version = b.version(0, 0, 1);
    var target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    // Get the windows target tag enum value
    const windows_tag = std.Target.Os.Tag.windows;
    // Get the explicit build target tag OR if null, the implicit builtin tag
    // We want to know what we're actually building for so we can link against the
    // correct native libraries (right?).
    const curr_tag = if (target.os_tag != null) target.os_tag else std.builtin.os.tag;

    // Determine if this builder has been asked for a Windows binary.
    const is_windows = curr_tag == windows_tag;

    // std.debug.print("std.os.tag: {s}\n", .{std.builtin.os.tag});
    std.debug.print("current os tag: {s}\n", .{curr_tag});
    std.debug.print("Builder is_windows: {s}\n", .{is_windows});

    // Build a shared lib
    const lib = b.addSharedLibrary("sdk", "src/lib.zig", version);
    // TODO(lbayes): Figure out how to emit a .h file for external
    // project inclusion.
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.setOutputDir("dist");
    lib.linkLibC();
    if (is_windows) {
        // Uncommenting the following, still leaves me with three errors
        // "error: undefined symbol: CoCreateInstance"
        // "error: undefined symbol: CLSID_MMDeviceEnumerator"
        // "error: undefined symbol: IID_IMMDeviceEnumerator"
        // lib.linkSystemLibrary("advapi32");
        // lib.linkSystemLibrary("comdlg32");
        // lib.linkSystemLibrary("gdi32");
        // lib.linkSystemLibrary("kernel32");
        // lib.linkSystemLibrary("ole32");
        // lib.linkSystemLibrary("oleaut32");
        // lib.linkSystemLibrary("user32");
        // lib.linkSystemLibrary("uuid");
    }
    lib.install();

    // Build a console client that loads the shared lib statically
    const exe = b.addExecutable("console", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.setOutputDir("dist");
    exe.linkLibC();
    // How to make this dynamically link?
    exe.addPackage(.{
        .name = "sdk",
        .path = "src/lib.zig",
    });
    exe.step.dependOn(&lib.step);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Build tests
    var tests = b.addTest("src/lib.zig");
    tests.setTarget(target);
    tests.setBuildMode(mode);
    // QUESTION(lbayes): How do I include multiple files for this test run?
    // e.g.:
    // tests.addFile("src/main_console.zig");

    // Run the tests
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&tests.step);
}

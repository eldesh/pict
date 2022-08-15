const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("libpict.zig", "src/main.zig");
    lib.setBuildMode(mode);
    try linkPict(lib);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);
    try linkPict(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn linkPict(exe: *std.build.LibExeObjStep) !void {
    exe.addIncludeDir(".");
    exe.addLibPath(".");
    exe.linkLibC();
    exe.linkSystemLibrary("pict");
}

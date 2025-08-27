const std = @import("std");

pub fn build(b: *std.Build) !void {
    const allocator = std.heap.page_allocator;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "blaze",
        .root_module = exe_mod,
    });

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    // C
    exe.linkLibC();

    // Vulkan
    const vulkan_sdk_path: std.Build.LazyPath = .{ .cwd_relative = env_map.get("VULKAN_SDK").? };
    exe.addIncludePath(vulkan_sdk_path.path(b, "Include"));
    exe.addLibraryPath(vulkan_sdk_path.path(b, "Lib"));

    exe.linkSystemLibrary("vulkan-1");

    // SDL
    const sdl = b.dependency("SDL", .{});
    exe.addIncludePath(sdl.path("include"));
    exe.addLibraryPath(sdl.path("lib/x64"));

    exe.linkSystemLibrary("SDL3");

    // Run
    const run = b.addRunArtifact(exe);
    run.addPathDir(sdl.path("lib/x64").getPath(b));

    const run_step = b.step("run", "run blaze");
    run_step.dependOn(&run.step);

    // Tests
    const vk_tests_mod = b.createModule(.{ .root_source_file = b.path("src/vulkan/tests.zig"), .target = target, .optimize = optimize });

    const vk_tests = b.addTest(.{
        .name = "vktests",
        .root_module = vk_tests_mod,
    });

    vk_tests.addIncludePath(vulkan_sdk_path.path(b, "Include"));

    const run_vk_tests = b.addRunArtifact(vk_tests);

    const tests_step = b.step("tests", "run tests");
    tests_step.dependOn(&run_vk_tests.step);
}

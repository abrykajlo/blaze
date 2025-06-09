const std = @import("std");

pub fn build(b: *std.Build) !void {
    const allocator = std.heap.page_allocator;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "blaze",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
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

    const run = b.addRunArtifact(exe);
    run.addPathDir(sdl.path("lib/x64").getPath(b));

    const run_step = b.step("run", "run blaze");
    run_step.dependOn(&run.step);
}

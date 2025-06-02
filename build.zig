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

    const vulkan_sdk_path: std.Build.LazyPath = .{ .cwd_relative = env_map.get("VULKAN_SDK").? };

    exe.addIncludePath(vulkan_sdk_path.path(b, "Include"));

    const run = b.addRunArtifact(exe);

    const run_step = b.step("run", "run blaze");
    run_step.dependOn(&run.step);
}

const std = @import("std");

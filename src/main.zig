const std = @import("std");

const VulkanApp = @import("VulkanApp.zig");

pub fn main() !void {
    var vulkan_app = try VulkanApp.init("blaze demo", VulkanApp.c.VK_MAKE_VERSION(0, 0, 0));
    defer vulkan_app.deinit();
}

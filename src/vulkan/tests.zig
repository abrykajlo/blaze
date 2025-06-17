const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const vk = @import("vk.zig");

const expect = std.testing.expect;

test "ApiVersion should match VK_MAKE_API_VERSION" {
    const api_version: vk.ApiVersion = @bitCast(c.VK_MAKE_API_VERSION(1, 2, 3, 4));
    try expect(api_version.variant == 1);
    try expect(api_version.major == 2);
    try expect(api_version.minor == 3);
    try expect(api_version.patch == 4);
}

test "Version should match VK_MAKE_VERSION" {
    const version: vk.Version = @bitCast(c.VK_MAKE_VERSION(1, 2, 3));
    try expect(version.major == 1);
    try expect(version.minor == 2);
    try expect(version.patch == 3);
}

test "Enumerate Portability should match the bitmask" {
    const flags: vk.Instance.CreateFlags = @bitCast(c.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR);
    try expect(flags.enumerate_portability_khr == 1);
}

test "Struct sizes" {
    try expect(@sizeOf(vk.LayerProperties) == @sizeOf(c.VkLayerProperties));
    try expect(@sizeOf(vk.ExtensionProperties) == @sizeOf(c.VkExtensionProperties));
    try expect(@sizeOf(vk.ApplicationInfo) == @sizeOf(c.VkApplicationInfo));
    try expect(@sizeOf(vk.Instance.CreateInfo) == @sizeOf(c.VkInstanceCreateInfo));
    try expect(@sizeOf(vk.Instance) == @sizeOf(c.VkInstance));
}

const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const vk = @import("vk.zig");

const expect = std.testing.expect;

test "Version should match VK_MAKE_API_VERSION" {
    const api_version: vk.Version = @bitCast(c.VK_MAKE_API_VERSION(1, 2, 3, 4));
    try expect(api_version.variant == 1);
    try expect(api_version.major == 2);
    try expect(api_version.minor == 3);
    try expect(api_version.patch == 4);
}

test "Enumerate Portability should match the bitmask" {
    const flags: vk.Instance.CreateFlags = @bitCast(c.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR);
    try expect(flags.instance_create_enumerate_portability_khr == 1);
}

test "QueueFlags" {
    var flags: vk.QueueFlags = @bitCast(c.VK_QUEUE_GRAPHICS_BIT);
    try expect(flags.queue_graphics_bit == 1);

    flags = @bitCast(c.VK_QUEUE_COMPUTE_BIT);
    try expect(flags.queue_compute_bit == 1);

    flags = @bitCast(c.VK_QUEUE_TRANSFER_BIT);
    try expect(flags.queue_transfer_bit == 1);

    flags = @bitCast(c.VK_QUEUE_PROTECTED_BIT);
    try expect(flags.queue_protected_bit == 1);

    flags = @bitCast(c.VK_QUEUE_SPARSE_BINDING_BIT);
    try expect(flags.queue_sparse_binding_bit == 1);

    flags = @bitCast(c.VK_QUEUE_OPTICAL_FLOW_BIT_NV);
    try expect(flags.queue_optical_flow_bit_nv == 1);

    flags = @bitCast(c.VK_QUEUE_VIDEO_DECODE_BIT_KHR);
    try expect(flags.queue_video_decode_bit_khr == 1);

    flags = @bitCast(c.VK_QUEUE_VIDEO_ENCODE_BIT_KHR);
    try expect(flags.queue_video_encode_bit_khr == 1);
}

test "Struct sizes" {
    try expect(@sizeOf(vk.LayerProperties) == @sizeOf(c.VkLayerProperties));
    try expect(@sizeOf(vk.ExtensionProperties) == @sizeOf(c.VkExtensionProperties));
    try expect(@sizeOf(vk.ApplicationInfo) == @sizeOf(c.VkApplicationInfo));
    try expect(@sizeOf(vk.Instance.CreateInfo) == @sizeOf(c.VkInstanceCreateInfo));
    try expect(@sizeOf(vk.Instance) == @sizeOf(c.VkInstance));
}

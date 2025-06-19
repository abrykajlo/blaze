const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("vk.zig");

ptr: *anyopaque,

pub const Size = u64;

pub const CreateInfo = extern struct {
    sType: vk.StructureType = .device_create_info,
    pNext: ?*const anyopaque = null,
    flags: vk.Device.CreateFlags = .{},
    queueCreateInfoCount: u32 = 0,
    pQueueCreateInfos: ?[*]const vk.Device.QueueCreateInfo = null,
    enabledLayerCount: u32 = 0,
    ppEnabledLayerNames: ?[*]const vk.String = null,
    enabledExtensionCount: u32 = 0,
    ppEnabledExtensionNames: ?[*]const vk.String = null,
    pEnabledFeatures: ?*const vk.PhysicalDevice.Features = null,
};

pub const CreateFlags = packed struct(u32) {
    _0: u32 = 0,
};

pub const QueueCreateInfo = extern struct {
    sType: vk.StructureType = .device_queue_create_info,
    pNext: ?*const anyopaque = null,
    flags: vk.Device.QueueCreateFlags = .{},
    queueFamilyIndex: u32,
    queueCount: u32 = 0,
    pQueuePriorities: ?[*]const f32 = null,
};

pub const QueueCreateFlags = packed struct(u32) {
    device_queue_create_protected_bit: u1 = 0,
    _0: u31 = 0,
};

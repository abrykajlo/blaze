const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("vk.zig");

const Device = @This();

ptr: *anyopaque,

pub fn create(physical_device: vk.PhysicalDevice, create_info: *const vk.Device.CreateInfo) !vk.Device {
    var device: vk.Device = undefined;
    const result = c.vkCreateDevice(@ptrCast(physical_device.ptr), @ptrCast(create_info), null, @ptrCast(&device.ptr));
    if (result != c.VK_SUCCESS) {
        return switch (result) {
            c.VK_ERROR_OUT_OF_HOST_MEMORY => error.OutOfHostMemory,
            c.VK_ERROR_OUT_OF_DEVICE_MEMORY => error.OutOfDeviceMemory,
            c.VK_ERROR_INITIALIZATION_FAILED => error.InitializationFailed,
            c.VK_ERROR_EXTENSION_NOT_PRESENT => error.ExtensionNotPresent,
            c.VK_ERROR_FEATURE_NOT_PRESENT => error.FeatureNotPresent,
            c.VK_ERROR_TOO_MANY_OBJECTS => error.TooManyObjects,
            c.VK_ERROR_DEVICE_LOST => error.DeviceLost,
            else => unreachable,
        };
    }
    return device;
}

pub fn destroy(self: Device) void {
    c.vkDestroyDevice(@ptrCast(self.ptr), null);
}

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

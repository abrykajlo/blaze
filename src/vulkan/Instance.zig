const std = @import("std");

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("vk.zig");

const Instance = @This();

ptr: *anyopaque,

pub fn create(create_info: *const vk.Instance.CreateInfo) CreateError!Instance {
    var instance: Instance = undefined;
    const result = c.vkCreateInstance(@ptrCast(create_info), null, @ptrCast(&instance.ptr));
    if (result != c.VK_SUCCESS) {
        return switch (result) {
            c.VK_ERROR_OUT_OF_HOST_MEMORY => error.OutOfHostMemory,
            c.VK_ERROR_OUT_OF_DEVICE_MEMORY => error.OutOfDeviceMemory,
            c.VK_ERROR_INITIALIZATION_FAILED => error.InitializationFailed,
            c.VK_ERROR_LAYER_NOT_PRESENT => error.LayerNotPresent,
            c.VK_ERROR_EXTENSION_NOT_PRESENT => error.ExtensionNotPresent,
            c.VK_ERROR_INCOMPATIBLE_DRIVER => error.IncompatibleDriver,
            else => unreachable,
        };
    }
    return instance;
}

pub fn destroy(self: Instance) void {
    c.vkDestroyInstance(@ptrCast(self.ptr), null);
}

pub fn enumeratePhysicalDevices(self: Instance, allocator: std.mem.Allocator) ![]vk.PhysicalDevice {
    var device_count: u32 = undefined;
    _ = c.vkEnumeratePhysicalDevices(@ptrCast(self.ptr), &device_count, null);
    const devices = try allocator.alloc(vk.PhysicalDevice, device_count);
    _ = c.vkEnumeratePhysicalDevices(@ptrCast(self.ptr), &device_count, @ptrCast(devices));
    return devices;
}

pub const CreateFlags = packed struct(u32) {
    instance_create_enumerate_portability_khr: u1 = 0,
    _0: u31 = 0,
};

pub const CreateInfo = extern struct {
    sType: vk.StructureType = .instance_create_info,
    pNext: ?*const anyopaque = null,
    flags: vk.Instance.CreateFlags = .{},
    pApplicationInfo: ?*const vk.ApplicationInfo = null,
    enabledLayerCount: u32 = 0,
    ppEnabledLayerNames: ?[*]const vk.String = null,
    enabledExtensionCount: u32 = 0,
    ppEnabledExtensionNames: ?[*]const vk.String = null,

    pub fn setEnabledLayerNames(self: *CreateInfo, enabled_layer_names: []const vk.String) void {
        self.enabledLayerCount = @intCast(enabled_layer_names.len);
        self.ppEnabledLayerNames = enabled_layer_names.ptr;
    }

    pub fn setEnabledExtensionNames(self: *CreateInfo, enabled_extension_names: []const vk.String) void {
        self.enabledExtensionCount = @intCast(enabled_extension_names.len);
        self.ppEnabledExtensionNames = enabled_extension_names.ptr;
    }
};

const CreateError = error{
    OutOfHostMemory,
    OutOfDeviceMemory,
    InitializationFailed,
    LayerNotPresent,
    ExtensionNotPresent,
    IncompatibleDriver,
};

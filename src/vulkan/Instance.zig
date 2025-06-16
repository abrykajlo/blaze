const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("vk.zig");

const Instance = @This();

ptr: *anyopaque,

pub fn create(create_info: *const vk.InstanceCreateInfo) CreateInstanceError!Instance {
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

const CreateInstanceError = error{
    OutOfHostMemory,
    OutOfDeviceMemory,
    InitializationFailed,
    LayerNotPresent,
    ExtensionNotPresent,
    IncompatibleDriver,
};

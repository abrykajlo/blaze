const std = @import("std");

pub const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const VulkanApp = @This();

instance: c.VkInstance,
app_info: c.VkApplicationInfo,
allocator: std.mem.Allocator,

pub fn init(app_name: []const u8, app_version: u32) !VulkanApp {
    var vulkan_app: VulkanApp = undefined;
    vulkan_app.app_info = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = @ptrCast(app_name),
        .applicationVersion = app_version,
        .pEngineName = "blaze",
        .engineVersion = c.VK_MAKE_VERSION(0, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_4,
    };

    // const allocator = std.heap.page_allocator;

    // var property_count: u32 = undefined;
    // _ = c.vkEnumerateInstanceLayerProperties(&property_count, null);
    // const layer_properties = try allocator.alloc(c.VkLayerProperties, property_count);
    // defer allocator.free(layer_properties);
    // _ = c.vkEnumerateInstanceLayerProperties(&property_count, @ptrCast(layer_properties));

    // for (layer_properties) |layer| {
    //     std.debug.print("{s}\n", .{layer.layerName});
    // }

    const create_info: c.VkInstanceCreateInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &vulkan_app.app_info,
    };
    if (c.vkCreateInstance(&create_info, null, &vulkan_app.instance) != c.VK_SUCCESS) {
        return error.CreateInstanceFailed;
    }

    return vulkan_app;
}

pub fn deinit(self: *VulkanApp) void {
    defer c.vkDestroyInstance(self.instance, null);
}

const VulkanError = error{
    CreateInstanceFailed,
};

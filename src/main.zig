const std = @import("std");

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub fn main() !void {
    // const allocator = std.heap.page_allocator;

    const app_info: c.VkApplicationInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "blaze demo",
        .applicationVersion = c.VK_MAKE_VERSION(0, 0, 0),
        .pEngineName = "blaze",
        .engineVersion = c.VK_MAKE_VERSION(0, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_4,
    };

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
        .pApplicationInfo = &app_info,
    };
    var vk_instance: c.VkInstance = undefined;
    if (c.vkCreateInstance(&create_info, null, &vk_instance) != c.VK_SUCCESS) {
        return error.CreateInstanceFailed;
    }
}

const BlazeError = error{
    CreateInstanceFailed,
};

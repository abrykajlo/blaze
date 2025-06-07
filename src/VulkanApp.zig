const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const VulkanApp = @This();

instance: c.VkInstance,
app_info: c.VkApplicationInfo,
allocator: Allocator,

pub fn init(allocator: Allocator, app_name: []const u8, app_version: u32) !VulkanApp {
    var vulkan_app: VulkanApp = undefined;
    vulkan_app.allocator = allocator;
    vulkan_app.app_info = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = @ptrCast(app_name),
        .applicationVersion = app_version,
        .pEngineName = "blaze",
        .engineVersion = c.VK_MAKE_VERSION(0, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_4,
    };

    try vulkan_app.checkValidationLayers();

    const create_info: c.VkInstanceCreateInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &vulkan_app.app_info,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = @ptrCast(validation_layers),
    };
    if (c.vkCreateInstance(&create_info, null, &vulkan_app.instance) != c.VK_SUCCESS) {
        return error.CreateInstanceFailed;
    }

    return vulkan_app;
}

pub fn deinit(self: *VulkanApp) void {
    defer c.vkDestroyInstance(self.instance, null);
}

fn checkValidationLayers(self: *const VulkanApp) !void {
    var property_count: u32 = undefined;
    _ = c.vkEnumerateInstanceLayerProperties(&property_count, null);
    const available_layers = try self.allocator.alloc(c.VkLayerProperties, property_count);
    defer self.allocator.free(available_layers);
    _ = c.vkEnumerateInstanceLayerProperties(&property_count, @ptrCast(available_layers));

    outer: for (validation_layers) |layer_name| {
        for (available_layers) |*layer_properties| {
            std.debug.print("{s}\n", .{&layer_properties.layerName});
            if (std.mem.eql(u8, layer_name, &layer_properties.layerName)) {
                continue :outer;
            }
        }

        return error.ValidationLayerUnavailable;
    }
}

const enable_validation_layers: bool = builtin.mode == .Debug;

const validation_layers: []const []const u8 = &.{"VK_LAYER_KHRONOS_validation"};

const VulkanError = error{
    CreateInstanceFailed,
    ValidationLayerUnavailable,
};

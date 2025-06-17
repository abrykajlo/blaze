const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub const Device = @import("Device.zig");
pub const Instance = @import("Instance.zig");
pub const PhysicalDevice = @import("PhysicalDevice.zig");

pub fn enumerateInstanceExtensionProperties(allocator: Allocator, layer_name: ?String) ![]ExtensionProperties {
    var property_count: u32 = undefined;
    _ = c.vkEnumerateInstanceExtensionProperties(layer_name, &property_count, null);
    const properties = try allocator.alloc(ExtensionProperties, property_count);
    _ = c.vkEnumerateInstanceExtensionProperties(layer_name, &property_count, @ptrCast(properties));
    return properties;
}

pub fn enumerateInstanceLayerProperties(allocator: Allocator) ![]LayerProperties {
    var property_count: u32 = undefined;
    _ = c.vkEnumerateInstanceLayerProperties(&property_count, null);
    const properties = try allocator.alloc(LayerProperties, property_count);
    _ = c.vkEnumerateInstanceLayerProperties(&property_count, @ptrCast(properties));
    return properties;
}

pub const ExtensionProperties = extern struct {
    extensionName: [256]u8,
    specVersion: u32,
};

pub const LayerProperties = extern struct {
    layerName: [256]u8,
    specVersion: u32,
    implementationVersion: u32,
    description: [256]u8,
};

pub const Bool32 = u32;

pub const String = [*:0]const u8;

pub const SampleCountFlags = packed struct(u32) {
    @"1": u1 = 0,
    @"2": u1 = 0,
    @"4": u1 = 0,
    @"8": u1 = 0,
    @"16": u1 = 0,
    @"32": u1 = 0,
    @"64": u1 = 0,
    _: u25 = 0,
};

pub const Version = packed struct(u32) {
    patch: u12,
    minor: u10,
    major: u10,
};

pub const ApiVersion = packed struct(u32) {
    patch: u12,
    minor: u10,
    major: u7,
    variant: u3,
};

pub const StructureType = enum(c_int) {
    application_info = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
    instance_create_info = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
};

pub const ApplicationInfo = extern struct {
    sType: StructureType = .application_info,
    pNext: ?*const anyopaque = null,
    pApplicationName: ?String = null,
    applicationVersion: Version = @bitCast(@as(u32, 0)),
    pEngineName: ?String = null,
    engineVersion: Version = @bitCast(@as(u32, 0)),
    apiVersion: ApiVersion = @bitCast(@as(u32, 0)),
};

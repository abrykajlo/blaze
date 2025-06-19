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

pub const QueueFamilyProperties = extern struct {
    queueFlags: QueueFlags,
    queueCount: u32,
    timestampValidBits: u32,
    minImageTransferGranularity: c.VkExtent3D,
};

pub const QueueFlags = packed struct(u32) {
    queue_graphics_bit: u1 = 0,
    queue_compute_bit: u1 = 0,
    queue_transfer_bit: u1 = 0,
    queue_sparse_binding_bit: u1 = 0,
    queue_protected_bit: u1 = 0,
    queue_video_decode_bit_khr: u1 = 0,
    queue_video_encode_bit_khr: u1 = 0,
    _0: u1 = 0,
    queue_optical_flow_bit_nv: u1 = 0,
    _1: u23 = 0,
};

pub const ExtensionProperties = extern struct {
    extensionName: [256]u8,
    specVersion: Version,
};

pub const LayerProperties = extern struct {
    layerName: [256]u8,
    specVersion: Version,
    implementationVersion: Version,
    description: [256]u8,
};

pub const Bool32 = u32;

pub const String = [*:0]const u8;

pub const SampleCountFlags = packed struct(u32) {
    sample_count_1_bit: u1 = 0,
    sample_count_2_bit: u1 = 0,
    sample_count_4_bit: u1 = 0,
    sample_count_8_bit: u1 = 0,
    sample_count_16_bit: u1 = 0,
    sample_count_32_bit: u1 = 0,
    sample_count_64_bit: u1 = 0,
    _0: u25 = 0,
};

pub const Version = packed struct(u32) {
    patch: u12 = 0,
    minor: u10 = 0,
    major: u7 = 0,
    variant: u3 = 0,
};

pub const StructureType = enum(c_int) {
    application_info = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
    instance_create_info = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
    device_create_info = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
    device_queue_create_info = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
};

pub const ApplicationInfo = extern struct {
    sType: StructureType = .application_info,
    pNext: ?*const anyopaque = null,
    pApplicationName: ?String = null,
    applicationVersion: Version = .{},
    pEngineName: ?String = null,
    engineVersion: Version = .{},
    apiVersion: Version = .{},
};

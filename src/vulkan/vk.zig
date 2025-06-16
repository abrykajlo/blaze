const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub const Instance = @import("Instance.zig");

pub fn enumerateInstanceExtensionProperties(allocator: Allocator, layer_name: ?String) ![]ExtensionProperties {
    var property_count: u32 = undefined;
    _ = c.vkEnumerateInstanceExtensionProperties(layer_name, &property_count, null);
    const properties = try allocator.alloc(ExtensionProperties, property_count);
    _ = c.vkEnumerateInstanceExtensionProperties(layer_name, &property_count, @ptrCast(properties));
    return properties;
}

pub const ExtensionProperties = extern struct {
    extension_name: [256]u8,
    spec_version: u32,
};

pub fn enumerateInstanceLayerProperties(allocator: Allocator) ![]LayerProperties {
    var property_count: u32 = undefined;
    _ = c.vkEnumerateInstanceLayerProperties(&property_count, null);
    const properties = try allocator.alloc(LayerProperties, property_count);
    _ = c.vkEnumerateInstanceLayerProperties(&property_count, @ptrCast(properties));
    return properties;
}

pub const LayerProperties = extern struct {
    layer_name: [256]u8,
    spec_version: u32,
    implementation_version: u32,
    description: [256]u8,
};

pub const String = [*:0]const u8;

pub const InstanceCreateFlags = packed struct(u32) {
    enumerate_portability_khr: u1 = 0,
    _: u31 = 0,
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
    type: StructureType = .application_info,
    next: ?*const anyopaque = null,
    application_name: ?String = null,
    application_version: Version = @bitCast(@as(u32, 0)),
    engine_name: ?String = null,
    engine_version: Version = @bitCast(@as(u32, 0)),
    api_version: ApiVersion = @bitCast(@as(u32, 0)),
};

pub const Slice = extern struct {
    len: u32 = 0,
    ptr: ?[*]const String = null,

    pub fn fromSlice(slice: []const String) Slice {
        return .{
            .len = @intCast(slice.len),
            .ptr = slice.ptr,
        };
    }
};

pub const InstanceCreateInfo = extern struct {
    type: StructureType = .instance_create_info,
    next: ?*const anyopaque = null,
    flags: InstanceCreateFlags = .{},
    application_info: ?*const ApplicationInfo = null,
    enabled_layer_names: Slice = .{},
    enabled_extension_names: Slice = .{},
};

const expect = std.testing.expect;

test "ApiVersion should match VK_MAKE_API_VERSION" {
    const api_version: ApiVersion = @bitCast(c.VK_MAKE_API_VERSION(1, 2, 3, 4));
    try expect(api_version.variant == 1);
    try expect(api_version.major == 2);
    try expect(api_version.minor == 3);
    try expect(api_version.patch == 4);
}

test "Version should match VK_MAKE_VERSION" {
    const version: Version = @bitCast(c.VK_MAKE_VERSION(1, 2, 3));
    try expect(version.major == 1);
    try expect(version.minor == 2);
    try expect(version.patch == 3);
}

test "Enumerate Portability should match the bitmask" {
    const flags: InstanceCreateFlags = @bitCast(c.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR);
    try expect(flags.enumerate_portability_khr == 1);
}

test "Struct sizes" {
    try expect(@sizeOf(LayerProperties) == @sizeOf(c.VkLayerProperties));
    try expect(@sizeOf(ExtensionProperties) == @sizeOf(c.VkExtensionProperties));
    try expect(@sizeOf(ApplicationInfo) == @sizeOf(c.VkApplicationInfo));
    try expect(@sizeOf(InstanceCreateInfo) == @sizeOf(c.VkInstanceCreateInfo));
    try expect(@sizeOf(Instance) == @sizeOf(c.VkInstance));
}

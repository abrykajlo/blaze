const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;

pub const c = @cImport({
    @cInclude("SDL3/SDL_vulkan.h");
});

const vk = @import("vulkan/vk.zig");

const BlazeApp = @This();

instance: vk.Instance,
app_info: vk.ApplicationInfo,
allocator: Allocator,

pub fn init(allocator: Allocator, app_name: []const u8, app_version: vk.Version) !BlazeApp {
    var blaze_app: BlazeApp = undefined;
    blaze_app.allocator = allocator;
    blaze_app.app_info = .{
        .application_name = @ptrCast(app_name),
        .application_version = app_version,
        .engine_name = "blaze",
        .engine_version = .{ .major = 0, .minor = 0, .patch = 0 },
        .api_version = .{ .variant = 0, .major = 1, .minor = 4, .patch = 0 },
    };

    const extensions = try blaze_app.getRequiredExtensions();
    defer allocator.free(extensions);

    var create_info: vk.InstanceCreateInfo = .{
        .application_info = &blaze_app.app_info,
        .enabled_extension_count = @intCast(extensions.len),
        .enabled_extension_names = @ptrCast(extensions),
    };

    if (enable_validation_layers) {
        try blaze_app.checkValidationLayers();
        create_info.enabled_layer_count = validation_layers.len;
        create_info.enabled_extension_names = @ptrCast(validation_layers);
    }

    if (vk.createInstance(&create_info, &blaze_app.instance) != .success) {
        return error.CreateInstanceFailed;
    }

    return blaze_app;
}

pub fn deinit(self: *BlazeApp) void {
    defer self.instance.deinit();
}

fn checkValidationLayers(self: *const BlazeApp) !void {
    var available_layers: []vk.LayerProperties = undefined;
    try vk.enumerateInstanceLayerProperties(self.allocator, &available_layers);
    defer self.allocator.free(available_layers);

    outer: for (validation_layers) |layer_name| {
        for (available_layers) |*layer_properties| {
            if (eql(layer_name, @ptrCast(&layer_properties.layer_name))) {
                continue :outer;
            }
        }

        return error.ValidationLayerUnavailable;
    }
}

fn getRequiredExtensions(self: *const BlazeApp) ![]const vk.String {
    var sdl_extension_count: u32 = undefined;
    const sdl_extensions = c.SDL_Vulkan_GetInstanceExtensions(&sdl_extension_count);

    var extensions = try self.allocator.alloc(vk.String, sdl_extension_count + required_extensions.len);
    errdefer self.allocator.free(extensions);

    var i: usize = 0;
    for (required_extensions) |extension| {
        extensions[i] = extension;
        i += 1;
    }

    for (0..sdl_extension_count) |j| {
        extensions[i] = sdl_extensions[j];
        i += 1;
    }

    // query available extensions
    var available_extensions: []vk.ExtensionProperties = undefined;
    try vk.enumerateInstanceExtensionProperties(self.allocator, null, &available_extensions);
    defer self.allocator.free(available_extensions);

    outer: for (extensions) |extension_name| {
        for (available_extensions) |*extension_properties| {
            if (eql(extension_name, @ptrCast(&extension_properties.extension_name))) {
                continue :outer;
            }
        }

        return error.ExtensionUnavailable;
    }

    return extensions;
}

fn eql(a: [*:0]const u8, b: [*:0]const u8) bool {
    var i: usize = 0;
    while (a[i] != 0 or b[i] != 0) : (i += 1) {
        if (a[i] != b[i])
            return false;
    }

    if (a[i] == b[i])
        return true;

    return false;
}

const enable_validation_layers = builtin.mode == .Debug;

const required_extensions: []const [*:0]const u8 = &.{};

const validation_layers: []const [*:0]const u8 = &.{"VK_LAYER_KHRONOS_validation"};

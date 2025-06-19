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
        .pApplicationName = @ptrCast(app_name),
        .applicationVersion = app_version,
        .pEngineName = "blaze",
        .engineVersion = .{ .major = 0, .minor = 0, .patch = 0 },
        .apiVersion = .{ .variant = 0, .major = 1, .minor = 4, .patch = 0 },
    };

    const extensions = try blaze_app.getRequiredExtensions();
    defer allocator.free(extensions);

    var create_info: vk.Instance.CreateInfo = .{
        .pApplicationInfo = &blaze_app.app_info,
    };

    create_info.setEnabledExtensionNames(extensions);

    if (enable_validation_layers) {
        try blaze_app.checkValidationLayers();
        create_info.setEnabledLayerNames(validation_layers);
    }

    blaze_app.instance = try vk.Instance.create(&create_info);

    const physical_devices = try blaze_app.instance.enumeratePhysicalDevices(allocator);
    defer allocator.free(physical_devices);
    for (physical_devices) |*physical_device| {
        const props = physical_device.getProperties();
        const version = props.driverVersion;
        std.debug.print("{} {} {}\n", .{ version.major, version.minor, version.patch });
    }

    return blaze_app;
}

pub fn deinit(self: *BlazeApp) void {
    defer self.instance.destroy();
}

fn checkValidationLayers(self: *const BlazeApp) !void {
    const available_layers = try vk.enumerateInstanceLayerProperties(self.allocator);
    defer self.allocator.free(available_layers);

    outer: for (validation_layers) |layer_name| {
        for (available_layers) |*layer_properties| {
            if (std.mem.eql(u8, std.mem.span(layer_name), std.mem.span(@as([*:0]u8, @ptrCast(&layer_properties.layerName))))) {
                continue :outer;
            }
        }

        return error.LayerNotPresent;
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

    return extensions;
}

const enable_validation_layers = builtin.mode == .Debug;

const required_extensions: []const vk.String = &.{};

const validation_layers: []const vk.String = &.{"VK_LAYER_KHRONOS_validation"};

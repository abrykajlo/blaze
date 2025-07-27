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
device: vk.Device,
allocator: Allocator,

pub fn init(allocator: Allocator, app_name: []const u8, app_version: vk.Version) !BlazeApp {
    var blaze_app: BlazeApp = undefined;
    try blaze_app.createInstance(allocator, app_name, app_version);
    try blaze_app.createDevice();

    return blaze_app;
}

pub fn deinit(self: *BlazeApp) void {
    defer self.instance.destroy();
    defer self.device.destroy();
}

fn createInstance(self: *BlazeApp, allocator: Allocator, app_name: []const u8, app_version: vk.Version) !void {
    self.allocator = allocator;
    self.app_info = .{
        .pApplicationName = @ptrCast(app_name),
        .applicationVersion = app_version,
        .pEngineName = "blaze",
        .engineVersion = .{ .major = 0, .minor = 0, .patch = 0 },
        .apiVersion = .{ .variant = 0, .major = 1, .minor = 4, .patch = 0 },
    };

    const extensions = try self.getRequiredExtensions();
    defer allocator.free(extensions);

    var create_info: vk.Instance.CreateInfo = .{
        .pApplicationInfo = &self.app_info,
    };

    create_info.enabledExtensionCount = @intCast(extensions.len);
    create_info.ppEnabledExtensionNames = @ptrCast(extensions.ptr);

    if (enable_validation_layers) {
        try self.checkValidationLayers();
        create_info.enabledLayerCount = @intCast(validation_layers.len);
        create_info.ppEnabledLayerNames = @ptrCast(validation_layers.ptr);
    }

    self.instance = try vk.Instance.create(&create_info);
}

fn createDevice(self: *BlazeApp) !void {
    const physical_devices = try self.instance.enumeratePhysicalDevices(self.allocator);
    defer self.allocator.free(physical_devices);

    var queue_create_infos: std.ArrayList(vk.Device.QueueCreateInfo) = .init(self.allocator);
    defer queue_create_infos.deinit();

    var found_suitable_device = false;
    var suitable_device: vk.PhysicalDevice = undefined;

    for (physical_devices) |physical_device| {
        const queue_family_properties = try physical_device.getQueueFamilyProperties(self.allocator);
        defer self.allocator.free(queue_family_properties);

        // check for required queue family support
        var graphics_idx: ?u32 = null;
        var presentation_idx: ?u32 = null;
        for (queue_family_properties, 0..) |*properties, i| {
            const idx: u32 = @intCast(i);
            const graphics_support = properties.queueFlags.queue_graphics_bit;
            graphics_idx = if (graphics_idx == null and graphics_support) idx else null;

            const presentation_support = c.SDL_Vulkan_GetPresentationSupport(@ptrCast(self.instance.ptr), @ptrCast(physical_device.ptr), idx);
            presentation_idx = if (presentation_idx == null and presentation_support) idx else null;

            if (graphics_idx != null and presentation_idx != null) {
                break;
            }
        }

        // if we didn't find the necessary queues we move to the next physical_device
        if (graphics_idx == null or presentation_idx == null) {
            continue;
        }

        found_suitable_device = true;
        suitable_device = physical_device;

        // set up unique queues
        var queue_set: std.DynamicBitSet = try .initEmpty(self.allocator, queue_family_properties.len);
        defer queue_set.deinit();

        // setup graphics queue
        queue_set.set(graphics_idx.?);

        // setup presentation queue
        queue_set.set(presentation_idx.?);

        var iter = queue_set.iterator(.{ .direction = .forward, .kind = .set });
        while (iter.next()) |queue_family_index| {
            const create_info = try queue_create_infos.addOne();
            const queue_priorities: [1]f32 = .{1.0};
            create_info.* = .{ .queueFamilyIndex = @intCast(queue_family_index), .queueCount = 1, .pQueuePriorities = &queue_priorities };
        }

        break;
    }

    if (!found_suitable_device) {
        return error.NoSuitableDevice;
    }

    var device_create_info: vk.Device.CreateInfo = .{};
    device_create_info.queueCreateInfoCount = @intCast(queue_create_infos.items.len);
    device_create_info.pQueueCreateInfos = @ptrCast(queue_create_infos.items);

    self.device = try suitable_device.createDevice(&device_create_info);
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

const BlazeError = error{
    NoSuitableDevice,
};

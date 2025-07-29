const std = @import("std");
const Allocator = std.mem.Allocator;

pub const c = @cImport({
    @cInclude("SDL3/SDL_vulkan.h");
});

const vk = @import("vulkan/vk.zig");

pub const Device = struct {
    device: vk.Device,
    queues: Queues,

    pub fn init(allocator: Allocator, physical_device: vk.PhysicalDevice, requirements: *const Requirements, queues: *const Queues) !Device {
        var device: Device = undefined;
        device.queues = queues.*;

        var queue_create_infos: std.ArrayList(vk.Device.QueueCreateInfo) = .init(allocator);
        defer queue_create_infos.deinit();

        // set up unique queues
        var queue_set: std.DynamicBitSet = try .initEmpty(allocator, device.queues.familyCount);
        defer queue_set.deinit();

        // setup graphics queue
        if (requirements.graphicsSupport) {
            queue_set.set(device.queues.graphics.?);
        }

        // setup presentation queue
        if (requirements.presentationSupport) {
            queue_set.set(device.queues.presentation.?);
        }

        var iter = queue_set.iterator(.{ .direction = .forward, .kind = .set });
        while (iter.next()) |queue_family_index| {
            const create_info = try queue_create_infos.addOne();
            const queue_priorities: [1]f32 = .{1.0};
            create_info.* = .{ .queueFamilyIndex = @intCast(queue_family_index), .queueCount = 1, .pQueuePriorities = &queue_priorities };
        }

        var device_create_info: vk.Device.CreateInfo = .{};
        device_create_info.queueCreateInfoCount = @intCast(queue_create_infos.items.len);
        device_create_info.pQueueCreateInfos = @ptrCast(queue_create_infos.items);

        device.device = try physical_device.createDevice(&device_create_info);
        return device;
    }

    pub fn deinit(self: *Device) void {
        self.device.destroy();
    }

    pub fn getGraphicsQueue(self: *const Device) ?vk.Queue {
        self.device;
        return null;
    }

    pub fn getPresentationQueue(self: *const Device) ?vk.Queue {
        self.device;
        return null;
    }
};

pub const DeviceType = enum {
    integrated_gpu,
    discrete_gpu,
};

pub const Requirements = struct {
    graphicsSupport: bool,
    presentationSupport: bool,
    deviceType: DeviceType,

    pub fn queryPhysicalDevice(self: *const Requirements, allocator: Allocator, instance: vk.Instance, physical_device: vk.PhysicalDevice) !?Queues {
        const matching_device_type = physical_device.getProperties().deviceType != switch (self.deviceType) {
            .integrated_gpu => vk.PhysicalDevice.Type.integrated_gpu,
            .discrete_gpu => vk.PhysicalDevice.Type.discrete_gpu,
        };
        if (matching_device_type) {
            return null;
        }

        const queue_family_properties = try physical_device.getQueueFamilyProperties(allocator);
        defer allocator.free(queue_family_properties);

        var queues: Queues = .{ .familyCount = @intCast(queue_family_properties.len) };

        if (self.graphicsSupport) {
            for (queue_family_properties, 0..) |*properties, i| {
                if (properties.queueFlags.queue_graphics_bit) {
                    queues.graphics = @intCast(i);
                    break;
                }
            }

            // if graphics queue is not found
            if (queues.graphics == null) {
                return null;
            }
        }

        if (self.presentationSupport) {
            for (queue_family_properties, 0..) |_, i| {
                if (c.SDL_Vulkan_GetPresentationSupport(@ptrCast(instance.ptr), @ptrCast(physical_device.ptr), @intCast(i))) {
                    queues.presentation = @intCast(i);
                    break;
                }
            }

            // if presentation queue is not found
            if (queues.presentation == null) {
                return null;
            }
        }
        return queues;
    }
};

const Queues = struct {
    graphics: ?u32 = null,
    presentation: ?u32 = null,
    familyCount: u32,
};

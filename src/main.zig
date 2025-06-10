const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const Window = @import("Window.zig");
const VulkanApp = @import("VulkanApp.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var window = try Window.init();
    defer window.deinit();

    var vulkan_app = try VulkanApp.init(allocator, "blaze demo", VulkanApp.c.VK_MAKE_VERSION(0, 0, 0));
    defer vulkan_app.deinit();

    running: while (true) {
        c.SDL_PumpEvents();

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(@ptrCast(&event))) {
            if (event.type == c.SDL_EVENT_QUIT) {
                break :running;
            }
        }
    }
}

const std = @import("std");

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

const vk = @import("vk.zig");
const Window = @import("../Window.zig");

const SurfaceKHR = @This();

ptr: *anyopaque,

pub fn create(window: *const Window, instance: vk.Instance) !SurfaceKHR {
    const surface: SurfaceKHR = undefined;
    if (!c.SDL_Vulkan_CreateSurface(@ptrCast(window.sdl_window), @ptrCast(instance.ptr), null, @ptrCast(@alignCast(surface.ptr)))) {
        return error.CreateSurfaceError;
    }
    return surface;
}

pub fn destroy(self: SurfaceKHR, instance: vk.Instance) void {
    c.vkDestroySurfaceKHR(@ptrCast(instance.ptr), @ptrCast(self.ptr), null);
}

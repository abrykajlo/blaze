const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const Window = @import("Window.zig");
const BlazeApp = @import("BlazeApp.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var window = try Window.init();
    defer window.deinit();

    var blaze_app = try BlazeApp.init(allocator, "blaze demo", .{ .major = 0, .minor = 0, .patch = 0 });
    defer blaze_app.deinit();

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

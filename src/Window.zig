const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const Window = @This();

sdl_window: *c.SDL_Window,

pub fn init() !Window {
    var result: Window = undefined;

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        return error.InitError;
    }

    const sdl_window = c.SDL_CreateWindow("Window", 640, 480, c.SDL_WINDOW_VULKAN | c.SDL_WINDOW_RESIZABLE);
    if (sdl_window) |w| {
        result.sdl_window = w;
    } else {
        return error.CreateWindowError;
    }

    return result;
}

pub fn deinit(self: *Window) void {
    defer c.SDL_Quit();
    defer c.SDL_DestroyWindow(self.sdl_window);
}

const WindowError = error{
    CreateWindowError,
    InitError,
};

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("../vk.zig");

const SwapChain = @This();

ptr: *anyopaque,

pub fn create(device: vk.Device, create_info: *const vk.khr.Swapchain.CreateInfo) !vk.khr.Swapchain {
    var swapchain: vk.khr.Swapchain = undefined;
    const result = c.vkCreateSwapchainKHR(@ptrCast(device.ptr), @ptrCast(create_info), null, @ptrCast(&swapchain.ptr));
    if (result != c.VK_SUCCESS) {
        return switch (result) {
            c.VK_ERROR_COMPRESSION_EXHAUSTED_EXT => vk.Error.CompressionExhaustedExt,
        };
    }
}

pub fn destroy(self: SwapChain, device: vk.Device) void {
    c.vkDestroySwapchainKHR(@ptrCast(device.ptr), @ptrCast(self.ptr), null);
}

pub const CreateInfo = extern struct {
    sType: vk.StructureType = .swapchain_create_info_khr,
    pNext: ?*const anyopaque = null,
    flags: vk.khr.Swapchain.CreateFlags = .{},
    surface: vk.khr.Swapchain,
    minImageCount: u32 = 0,
    imageFormat: vk.Format,
    imageColorSpace: vk.khr.ColorSpace,
    imageExtent: vk.Extent2D,
    imageArrayLayers: u32 = 0,
    imageUsage: vk.ImageUsageFlags,
    imageSharingMode: vk.SharingMode,
    queueFamilyIndexCount: u32 = 0,
    pQueueFamilyIndices: [*c]const u32 = null,
    preTransform: vk.khr.SurfaceTransformFlagBits = .{},
    compositeAlpha: vk.khr.CompositeAlphaFlagBits = .{},
    presentMode: vk.khr.PresentMode,
    clipped: vk.Bool32 = 0,
    oldSwapchain: vk.khr.Swapchain = .{},
};

pub const CreateFlags = packed struct {};

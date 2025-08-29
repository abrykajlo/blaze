const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("../vk.zig");

const SwapChain = @This();

ptr: *anyopaque,

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

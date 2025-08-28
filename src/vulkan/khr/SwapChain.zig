const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const SwapChain = @This();

ptr: *anyopaque,

pub fn create() !SwapChain {
    c.vkCreateSwapchainKHR(device: ?*struct_VkDevice_T, pCreateInfo: [*c]const struct_VkSwapchainCreateInfoKHR, null, pSwapchain: [*c]?*struct_VkSwapchainKHR_T)
}

pub const CreateInfo = struct {

};
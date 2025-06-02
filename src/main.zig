pub fn main() !void {}

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

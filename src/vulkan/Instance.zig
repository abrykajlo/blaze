const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const InstanceT = opaque {};

instance: *InstanceT,

const std = @import("std");

const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const vk = @import("vk.zig");

const PhysicalDevice = @This();

ptr: *anyopaque,

pub fn getFeatures(self: PhysicalDevice) Features {
    var features: Features = undefined;
    _ = c.vkGetPhysicalDeviceFeatures(@ptrCast(self.ptr), @ptrCast(&features));
    return features;
}

pub fn getProperties(self: PhysicalDevice) Properties {
    var properties: Properties = undefined;
    _ = c.vkGetPhysicalDeviceProperties(@ptrCast(self.ptr), @ptrCast(&properties));
    return properties;
}

pub fn getQueueFamilyProperties(self: PhysicalDevice, allocator: std.mem.Allocator) ![]vk.QueueFamilyProperties {
    var property_count: u32 = undefined;
    _ = c.vkGetPhysicalDeviceQueueFamilyProperties(@ptrCast(self.ptr), &property_count, null);
    const properties = try allocator.alloc(vk.QueueFamilyProperties, property_count);
    _ = c.vkGetPhysicalDeviceQueueFamilyProperties(@ptrCast(self.ptr), &property_count, @ptrCast(properties));
    return properties;
}

pub fn createDevice(self: PhysicalDevice, create_info: *const vk.Device.CreateInfo) CreateDeviceError!vk.Device {
    var device: vk.Device = undefined;
    const result = c.vkCreateDevice(@ptrCast(self.ptr), @ptrCast(create_info), null, @ptrCast(&device.ptr));
    if (result != c.VK_SUCCESS) {
        return switch (result) {
            c.VK_ERROR_OUT_OF_HOST_MEMORY => error.OutOfHostMemory,
            c.VK_ERROR_OUT_OF_DEVICE_MEMORY => error.OutOfDeviceMemory,
            c.VK_ERROR_INITIALIZATION_FAILED => error.InitializationFailed,
            c.VK_ERROR_EXTENSION_NOT_PRESENT => error.ExtensionNotPresent,
            c.VK_ERROR_FEATURE_NOT_PRESENT => error.FeatureNotPresent,
            c.VK_ERROR_TOO_MANY_OBJECTS => error.TooManyObjects,
            c.VK_ERROR_DEVICE_LOST => error.DeviceLost,
            else => unreachable,
        };
    }
    return device;
}

pub const CreateDeviceError = error{
    OutOfHostMemory,
    OutOfDeviceMemory,
    InitializationFailed,
    ExtensionNotPresent,
    FeatureNotPresent,
    TooManyObjects,
    DeviceLost,
};

pub const Features = extern struct {
    robustBufferAccess: vk.Bool32,
    fullDrawIndexUint32: vk.Bool32,
    imageCubeArray: vk.Bool32,
    independentBlend: vk.Bool32,
    geometryShader: vk.Bool32,
    tessellationShader: vk.Bool32,
    sampleRateShading: vk.Bool32,
    dualSrcBlend: vk.Bool32,
    logicOp: vk.Bool32,
    multiDrawIndirect: vk.Bool32,
    drawIndirectFirstInstance: vk.Bool32,
    depthClamp: vk.Bool32,
    depthBiasClamp: vk.Bool32,
    fillModeNonSolid: vk.Bool32,
    depthBounds: vk.Bool32,
    wideLines: vk.Bool32,
    largePoints: vk.Bool32,
    alphaToOne: vk.Bool32,
    multiViewport: vk.Bool32,
    samplerAnisotropy: vk.Bool32,
    textureCompressionETC2: vk.Bool32,
    textureCompressionASTC_LDR: vk.Bool32,
    textureCompressionBC: vk.Bool32,
    occlusionQueryPrecise: vk.Bool32,
    pipelineStatisticsQuery: vk.Bool32,
    vertexPipelineStoresAndAtomics: vk.Bool32,
    fragmentStoresAndAtomics: vk.Bool32,
    shaderTessellationAndGeometryPointSize: vk.Bool32,
    shaderImageGatherExtended: vk.Bool32,
    shaderStorageImageExtendedFormats: vk.Bool32,
    shaderStorageImageMultisample: vk.Bool32,
    shaderStorageImageReadWithoutFormat: vk.Bool32,
    shaderStorageImageWriteWithoutFormat: vk.Bool32,
    shaderUniformBufferArrayDynamicIndexing: vk.Bool32,
    shaderSampledImageArrayDynamicIndexing: vk.Bool32,
    shaderStorageBufferArrayDynamicIndexing: vk.Bool32,
    shaderStorageImageArrayDynamicIndexing: vk.Bool32,
    shaderClipDistance: vk.Bool32,
    shaderCullDistance: vk.Bool32,
    shaderFloat64: vk.Bool32,
    shaderInt64: vk.Bool32,
    shaderInt16: vk.Bool32,
    shaderResourceResidency: vk.Bool32,
    shaderResourceMinLod: vk.Bool32,
    sparseBinding: vk.Bool32,
    sparseResidencyBuffer: vk.Bool32,
    sparseResidencyImage2D: vk.Bool32,
    sparseResidencyImage3D: vk.Bool32,
    sparseResidency2Samples: vk.Bool32,
    sparseResidency4Samples: vk.Bool32,
    sparseResidency8Samples: vk.Bool32,
    sparseResidency16Samples: vk.Bool32,
    sparseResidencyAliased: vk.Bool32,
    variableMultisampleRate: vk.Bool32,
    inheritedQueries: vk.Bool32,
};

pub const Properties = extern struct {
    apiVersion: vk.Version,
    driverVersion: vk.Version,
    vendorID: u32,
    deviceID: u32,
    deviceType: vk.PhysicalDevice.Type,
    deviceName: [256]u8,
    pipelineCacheUUID: [16]u8,
    limits: vk.PhysicalDevice.Limits,
    sparseProperties: vk.PhysicalDevice.SparseProperties,
};

const Type = enum(c_int) {
    other = c.VK_PHYSICAL_DEVICE_TYPE_OTHER,
    integrated_gpu = c.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU,
    discrete_gpu = c.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU,
    virtual_gpu = c.VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU,
    cpu = c.VK_PHYSICAL_DEVICE_TYPE_CPU,
};

const Limits = extern struct {
    maxImageDimension1D: u32,
    maxImageDimension2D: u32,
    maxImageDimension3D: u32,
    maxImageDimensionCube: u32,
    maxImageArrayLayers: u32,
    maxTexelBufferElements: u32,
    maxUniformBufferRange: u32,
    maxStorageBufferRange: u32,
    maxPushConstantsSize: u32,
    maxMemoryAllocationCount: u32,
    maxSamplerAllocationCount: u32,
    bufferImageGranularity: vk.Device.Size,
    sparseAddressSpaceSize: vk.Device.Size,
    maxBoundDescriptorSets: u32,
    maxPerStageDescriptorSamplers: u32,
    maxPerStageDescriptorUniformBuffers: u32,
    maxPerStageDescriptorStorageBuffers: u32,
    maxPerStageDescriptorSampledImages: u32,
    maxPerStageDescriptorStorageImages: u32,
    maxPerStageDescriptorInputAttachments: u32,
    maxPerStageResources: u32,
    maxDescriptorSetSamplers: u32,
    maxDescriptorSetUniformBuffers: u32,
    maxDescriptorSetUniformBuffersDynamic: u32,
    maxDescriptorSetStorageBuffers: u32,
    maxDescriptorSetStorageBuffersDynamic: u32,
    maxDescriptorSetSampledImages: u32,
    maxDescriptorSetStorageImages: u32,
    maxDescriptorSetInputAttachments: u32,
    maxVertexInputAttributes: u32,
    maxVertexInputBindings: u32,
    maxVertexInputAttributeOffset: u32,
    maxVertexInputBindingStride: u32,
    maxVertexOutputComponents: u32,
    maxTessellationGenerationLevel: u32,
    maxTessellationPatchSize: u32,
    maxTessellationControlPerVertexInputComponents: u32,
    maxTessellationControlPerVertexOutputComponents: u32,
    maxTessellationControlPerPatchOutputComponents: u32,
    maxTessellationControlTotalOutputComponents: u32,
    maxTessellationEvaluationInputComponents: u32,
    maxTessellationEvaluationOutputComponents: u32,
    maxGeometryShaderInvocations: u32,
    maxGeometryInputComponents: u32,
    maxGeometryOutputComponents: u32,
    maxGeometryOutputVertices: u32,
    maxGeometryTotalOutputComponents: u32,
    maxFragmentInputComponents: u32,
    maxFragmentOutputAttachments: u32,
    maxFragmentDualSrcAttachments: u32,
    maxFragmentCombinedOutputResources: u32,
    maxComputeSharedMemorySize: u32,
    maxComputeWorkGroupCount: [3]u32,
    maxComputeWorkGroupInvocations: u32,
    maxComputeWorkGroupSize: [3]u32,
    subPixelPrecisionBits: u32,
    subTexelPrecisionBits: u32,
    mipmapPrecisionBits: u32,
    maxDrawIndexedIndexValue: u32,
    maxDrawIndirectCount: u32,
    maxSamplerLodBias: f32,
    maxSamplerAnisotropy: f32,
    maxViewports: u32,
    maxViewportDimensions: [2]u32,
    viewportBoundsRange: [2]f32,
    viewportSubPixelBits: u32,
    minMemoryMapAlignment: usize,
    minTexelBufferOffsetAlignment: vk.Device.Size,
    minUniformBufferOffsetAlignment: vk.Device.Size,
    minStorageBufferOffsetAlignment: vk.Device.Size,
    minTexelOffset: i32,
    maxTexelOffset: u32,
    minTexelGatherOffset: i32,
    maxTexelGatherOffset: u32,
    minInterpolationOffset: f32,
    maxInterpolationOffset: f32,
    subPixelInterpolationOffsetBits: u32,
    maxFramebufferWidth: u32,
    maxFramebufferHeight: u32,
    maxFramebufferLayers: u32,
    framebufferColorSampleCounts: vk.SampleCountFlags,
    framebufferDepthSampleCounts: vk.SampleCountFlags,
    framebufferStencilSampleCounts: vk.SampleCountFlags,
    framebufferNoAttachmentsSampleCounts: vk.SampleCountFlags,
    maxColorAttachments: u32,
    sampledImageColorSampleCounts: vk.SampleCountFlags,
    sampledImageIntegerSampleCounts: vk.SampleCountFlags,
    sampledImageDepthSampleCounts: vk.SampleCountFlags,
    sampledImageStencilSampleCounts: vk.SampleCountFlags,
    storageImageSampleCounts: vk.SampleCountFlags,
    maxSampleMaskWords: u32,
    timestampComputeAndGraphics: vk.Bool32,
    timestampPeriod: f32,
    maxClipDistances: u32,
    maxCullDistances: u32,
    maxCombinedClipAndCullDistances: u32,
    discreteQueuePriorities: u32,
    pointSizeRange: [2]f32,
    lineWidthRange: [2]f32,
    pointSizeGranularity: f32,
    lineWidthGranularity: f32,
    strictLines: vk.Bool32,
    standardSampleLocations: vk.Bool32,
    optimalBufferCopyOffsetAlignment: vk.Device.Size,
    optimalBufferCopyRowPitchAlignment: vk.Device.Size,
    nonCoherentAtomSize: vk.Device.Size,
};

const SparseProperties = extern struct {
    residencyStandard2DBlockShape: vk.Bool32,
    residencyStandard2DMultisampleBlockShape: vk.Bool32,
    residencyStandard3DBlockShape: vk.Bool32,
    residencyAlignedMipSize: vk.Bool32,
    residencyNonResidentStrict: vk.Bool32,
};

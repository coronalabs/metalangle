//
// Copyright (c) 2019 The ANGLE Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// GlslangWrapper: Wrapper for Khronos's glslang compiler.
//

#include "libANGLE/renderer/metal/GlslangWrapper.h"

#include "libANGLE/renderer/glslang_wrapper_utils.h"

namespace rx
{
namespace
{
angle::Result ErrorHandler(mtl::ErrorHandler *context, GlslangWrapperUtils::Error)
{
    ANGLE_MTL_TRY(context, false);
    return angle::Result::Stop;
}

GlslangWrapperUtils::Options CreateOptions(mtl::ErrorHandler *context)
{
    GlslangWrapperUtils::Options options;
    // We don't actually use descriptor set for now, the actual binding will be done inside
    // ProgramMtl using spirv-cross.
    options.uniformsAndXfbDescriptorSetIndex = kDefaultUniformsBindingIndex;
    options.textureDescriptorSetIndex        = 0;
    options.driverUniformsDescriptorSetIndex = kDriverUniformsBindingIndex;
    // TODO(hqle): Unused for now, until we support ES 3.0
    options.shaderResourceDescriptorSetIndex = -1;
    options.xfbBindingIndexStart             = -1;

    static_assert(kDefaultUniformsBindingIndex != 0, "kDefaultUniformsBindingIndex must not be 0");
    static_assert(kDriverUniformsBindingIndex != 0, "kDriverUniformsBindingIndex must not be 0");

    if (context)
    {
        options.errorCallback = [context](GlslangWrapperUtils::Error error) {
            return ErrorHandler(context, error);
        };
    }

    return options;
}
}  // namespace

// static
void GlslangWrapperMtl::Initialize()
{
    GlslangWrapperUtils::Initialize();
}

// static
void GlslangWrapperMtl::Release()
{
    GlslangWrapperUtils::Release();
}

// static
void GlslangWrapperMtl::GetShaderSource(const gl::ProgramState &programState,
                                        const gl::ProgramLinkedResources &resources,
                                        gl::ShaderMap<std::string> *shaderSourcesOut)
{
    GlslangWrapperUtils::GetShaderSource(CreateOptions(nullptr), false, programState, resources,
                                         shaderSourcesOut);
}

// static
angle::Result GlslangWrapperMtl::GetShaderCode(mtl::ErrorHandler *context,
                                               const gl::Caps &glCaps,
                                               bool enableLineRasterEmulation,
                                               const gl::ShaderMap<std::string> &shaderSources,
                                               gl::ShaderMap<std::vector<uint32_t>> *shaderCodeOut)
{
    return GlslangWrapperUtils::GetShaderCode(
        CreateOptions(context), glCaps, enableLineRasterEmulation, shaderSources, shaderCodeOut);
}
}  // namespace rx
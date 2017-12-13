import opengl
include easygl.easygl_types

# When passing objects to opengl you may need this to get a relative pointer
template offsetof*(typ, field): untyped = (var dummy: typ; cast[int](addr(dummy.field)) - cast[int](addr(dummy)))

# Deviate from opengl name here because GetError conflicts with SDL2
template getGLError*() : ErrorType =
    glGetError().ErrorType

template viewport*(x,y,width,height:int32) =
    glViewport(x.GLint,y.GLint,width.GLsizei,height.GLsizei)

template enable*(cap:Capability) =
    glEnable(cap.GLenum)

template disable*(cap:Capability) =
    glDisable(cap.GLenum)

template polygonMode*(face:PolygonFace, mode:PolygonModeEnum) =
    glPolygonMode(face.GLenum, mode.GLenum)

template depthMask*(flag: bool) =
    glDepthMask(flag.GLboolean)

template depthFunc*(fun: AlphaFunc) = 
    glDepthFunc(fun.GLenum)

template stencilMask*(mask:uint32)  =     
    glStencilMask(mask.GLuint)

template stencilFunc*(fun:AlphaFunc, reference: int32, mask:uint32) =     
    glStencilFunc(fun.GLenum, reference.GLint, mask.GLuint)

template stencilFuncSeparate*(face:PolygonFace,fun:AlphaFunc, reference: int32, mask:uint32) =
    glStencilFuncSeparate(face.GLenum, fun.GLenum, reference.GLint, mask.GLuint)

template stencilOp*(sfail: StencilOpEnum, dpfail: StencilOpEnum, dppass: StencilOpEnum) =
    glStencilOp(sfail.GLenum, dpfail.GLenum, dppass.GLenum)

template stencilOpSeparate*(face:PolygonFace, sfail: StencilOpEnum, dpfail: StencilOpEnum, dppass: StencilOpEnum) =
    glStencilOpSeparate(face.GLenum,sfail.GLenum, dpfail.GLenum, dppass.GLenum)

template genFramebuffer*() : FramebufferId =
    var frameBuffer:GLuint
    glGenFramebuffers(1,addr frameBuffer)
    frameBuffer

template genFramebuffers*(count:int32) : seq[FramebufferId] =
    let frames = newSeq[FramebufferId](count)
    glGenFramebuffers(count.GLsizei,cast[ptr GLuint](buffers[0].unsafeAddr))
    frames

template bindFramebuffer*(target:FramebufferTarget, frameBuffer:FramebufferId) =
    glBindFramebuffer(target.GLenum,frameBuffer.GLuint)

template genBindFramebuffer*(target:FramebufferTarget) : FramebufferId =
    var framebuffer:GLuint
    glGenFramebuffers(1,addr framebuffer)
    glBindFramebuffer(target.GLenum,framebuffer)
    frameBuffer.FramebufferId

template unBindFramebuffer*(target:FramebufferTarget) = 
    glBindFramebuffer(target.GLenum,0)

template checkFramebufferStatus*(target:FramebufferTarget) : FramebufferStatus =
    glCheckFramebufferStatus(target.GLenum).FramebufferStatus

# todo: this has a lot of rules about what the arguments can be, see:
# https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glFramebufferTexture.xhtml
# can we get compile time gaurantees on these?  asserts in debug mode maybe?
template framebufferTexture2D*(target:FramebufferTarget,
                                attachment:FramebufferAttachment,
                                textarget: FramebufferTextureTarget,
                                texture: TextureId,
                                level:int) =
    glFramebufferTexture2D(target.GLenum,attachment.GLenum,textarget.GLenum,texture.GLuint,level.int32)

template blitFramebuffer*(srcX0,srcY0,srcX1,srcY1,dstX0,dstY0,dstX1,dsyY1:int,masks:varargs[BufferMask],filter:BlitFilter) =
    var mask : uint32 
    for m in masks:
        mask = mask or m.uint32
    glBlitFramebuffer(srcX0.GLint,srcY0.GLint,srcX1.GLint,srcY1.GLint,dstX0.GLint,dstY0.GLint,dstX1.GLint,dsyY1.GLint,mask.GLbitfield,filter.GLenum)

template deleteFramebuffers*(framebuffers:openarray[FramebufferId]) =
    glDeleteBuffers(framebuffers.len.GLsizei,cast[ptr GLUint](framebuffers[0].unsafeAddr))

template deleteFramebuffer*(framebuffer:FramebufferId) =
    glDeleteBuffers(1,framebuffer.addr)

template genRenderbuffer*() : RenderbufferId =
    var renderbuffer:GLuint
    glGenRenderBuffers(1, addr renderbuffer)
    renderbuffer.RenderbufferId

template genRenderbuffers*(count:int32) : seq[RenderbufferId] =
    let renderbuffers = newSeq[RenderbufferId](count)
    glGenRenderBuffers(count.GLsizei,cast[ptr GLuint](renderbuffers[0].unsafeAddr))
    renderbuffers

# target can only be GL_RENDERBUFFER so we don't both asking for it
template bindRenderbuffer*(renderbuffer:RenderbufferId) = 
    glBindRenderBuffer(GL_RENDERBUFFER,renderbuffer.GLuint)

template unBindRenderbuffer*() = 
    glBindRenderBuffer(GL_RENDERBUFFER,0)

template genBindRenderBuffer*() : RenderbufferId =
    var renderbuffer:GLuint
    glGenRenderBuffers(1, addr renderbuffer)
    glBindRenderBuffer(GL_RENDERBUFFER,renderbuffer)
    renderbuffer.RenderbufferId

# renderbuffertarget must be GL_RENDERBUFFER so we don't ask for it
template framebufferRenderbuffer*(target:FramebufferTarget, 
                                 attachment: FramebufferAttachment,
                                 renderbuffer:RenderbufferId) =
    glFramebufferRenderBuffer(target.GLenum,attachment.GLenum,GL_RENDERBUFFER,renderbuffer.GLuint)


type RenderbufferSize* =  range[1..GL_MAX_RENDERBUFFER_SIZE.int]
template renderbufferStorage*(internalformat:RenderbufferFormat, width:RenderbufferSize,height:RenderbufferSize) =
    glRenderBufferStorage(GL_RENDERBUFFER,internalformat.GLenum,width.GLsizei,height.GLsizei)

template renderbufferStorageMultisample*(samples:int,internalformat:RenderbufferFormat, width:RenderbufferSize,height:RenderbufferSize) =
    glRenderBufferStorageMultisample(GL_RENDERBUFFER,samples.GLsizei,internalformat.GLenum,width.GLsizei,height.GLsizei)
                                 
template genBuffer*() : BufferId  =
    var buffer:GLuint
    glGenBuffers(1,addr buffer)
    buffer.BufferId

template genBuffers*(count:int32) : seq[BufferId] =
    let buffers = newSeq[BufferId](count)
    glGenBuffers(count.GLsizei,cast[ptr GLuint](buffers[0].unsafeAddr))
    buffers

template bindBuffer*(target:BufferTarget, buffer:BufferId)  =
    glBindBuffer(target.GLenum,buffer.GLuint)

template unBindBuffer*(target:BufferTarget) = 
    glBindBuffer(target.GLenum,0)

template genBindBuffer*(target:BufferTarget) : BufferId = 
    var buffer : GLuint
    glGenBuffers(1,addr buffer)
    glBindBuffer(target.GLenum,buffer)
    buffer.BufferId

template bindBufferRange*(target:BufferRangeTarget,index:uint32,buffer:BufferId, offset:int32, size:int) =
    glBindBufferRange(target.GLenum,index.GLuint,buffer.GLuint,offset.GLintptr,size.GLsizeiptr)
    
template bufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage)  =
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,usage.GLenum)

template bufferData*[T](target:BufferTarget,size:int, data:ptr T, usage:BufferDataUsage)  =
    glBufferData(target.GLenum,size.GLsizeiptr,cast[pointer](data),usage.GLenum)

template bufferData*(target:BufferTarget,size:int,usage:BufferDataUsage) =
    glBufferData(target.GLenum,size.GLsizeiptr,nil,usage.GLenum)

# bind and set buffer data in one go
template bindBufferData*[T](target:BufferTarget, buffer:BufferId, data:openarray[T], usage:BufferDataUsage)  = 
    glBindBuffer(target.GLenum,buffer.GLuint)
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,usage.GLenum)

# generate, bind, and set buffer data in one go
template genBindBufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage) :BufferId   =     
    var buffer : GLuint
    glGenBuffers(1,addr buffer)
    glBindBuffer(target.GLenum,buffer)
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,usage.GLenum)
    buffer.BufferId
        
template deleteBuffer*(buffer:BufferId) =    
    var b = buffer
    glDeleteBuffers(1,b.GLuint.addr)

template deleteBuffers*(buffers:openArray[BufferId]) =
    glDeleteBuffers(buffers.len.GLsizei,cast[ptr GLUint](buffers[0].unsafeAddr))

template bufferSubData*[T](target:BufferTarget,offset:int,size:int,data:openarray[T]) =
    glBufferSubData(target.GLenum,offset.GLintptr, size.GLsizeiptr, data[0].unsafeAddr)

template copyBufferSubData*(readTarget:BufferTarget, 
                           writeTarget:BufferTarget,
                           readOffset:int32,
                           writeOffset:int32,
                           size:int32) =
    glCopyBufferSubData(readTarget.GLenum,writeTarget.GLenum,readOffset.GLintptr,writeOffset.GLintptr,size.GLsizeiptr)
    
template mapBuffer*[T](target:BufferTarget, access:Access) : ptr UncheckedArray[T] =
    cast[ptr UncheckedArray[T]](glMapBuffer(target.GLenum, access.GLenum))

template unmapBuffer*(target:BufferTarget) =
    glUnmapBuffer(target.GLenum)

template genVertexArray*() : VertexArrayId  =
    var VAO : GLuint
    glGenVertexArrays(1.GLsizei,cast[ptr GLuint](addr VAO))
    VAO.VertexArrayId

# Gen and bind vertex array in one go
template genBindVertexArray*() : VertexArrayId  =
    var VAO : GLuint
    glGenVertexArrays(1.GLsizei,addr VAO)
    glBindVertexArray(VAO)
    VAO.VertexArrayId
    
template genVertexArrays*(count:int32) : seq[VertexArrayId]  =
    let vertexArrays = newSeq[VertexArrayId](count)
    glGenVertexArrays(count.GLsizei,cast[ptr GLuint](vertexArrays[0].unsafeAddr))
    vertexArrays
    
template bindVertexArray*(vertexArray:VertexArrayId)  =
    glBindVertexArray(vertexArray.GLuint)

template unBindVertexArray*() =
    glBindVertexArray(0)

template deleteVertexArray*(vertexArray:VertexArrayId) =    
    var v = vertexArray
    glDeleteVertexArrays(1,v.GLUint.addr)

template deleteVertexArrays*(vertexArrays:openArray[VertexArrayId]) =
    glDeleteVertexArrays(vertexArrays.len.GLsizei,cast[ptr GLUint](vertexArrays[0].unsafeAddr))
    
template genTexture*() : TextureId =
    var tex : GLuint
    glGenTextures(1.GLsizei,addr tex)
    tex.TextureId

template genTextures*(count:int32) : seq[TextureId] =
    let textures = newSeq[TextureId](count)
    glGenTextures(count.GLsizei,cast[ptr GLuint](textures[0].unsafeAddr))
    textures

template genBindTexture*(target:TextureTarget) : TextureId = 
    var tex : GLuint
    glGenTextures(1.GLsizei,addr tex)
    glBindTexture(target.GLenum, tex)
    tex.TextureId

template bindTexture*(target:TextureTarget, texture:TextureId) =
    glBindTexture(target.GLenum, texture.GLuint)

template unBindTexture*(target:TextureTarget) =
    glBindTexture(target.GLenum, 0.GLuint)

template activeTexture*(texture:TextureUnit) =
    glActiveTexture(texture.GLenum)

template texParameteri*(target:TextureTarget, pname:TextureParameter, param:GLint) =
    glTexParameteri(target.GLenum,pname.GLenum,param)

template texImage2D*[T](target:TexImageTarget, level:int32, internalFormat:TextureInternalFormat, width:int32, height:int32, format:PixelDataFormat, pixelType:PixelDataType, data: openArray[T] )  =    
    glTexImage2D(target.GLenum,level.GLint,internalFormat.GLint,width.GLsizei,height.GLsizei,0,format.GLenum,pixelType.GLenum,data[0].unsafeAddr)

# for cases where data is null, just don't pass it in
template texImage2D*(target:TexImageTarget, level:int32, internalFormat:TextureInternalFormat, width:int32, height:int32, format:PixelDataFormat, pixelType:PixelDataType) =
    glTexImage2D(target.GLenum,level.GLint,internalFormat.GLint,width.GLsizei,height.GLsizei,0,format.GLenum,pixelType.GLenum,nil)    

template texImage2DMultisample*(target:TexImageMultiSampleTarget,samples:int,internalformat:TextureInternalFormat,width:int,height:int,fixedsamplelocations:bool) = 
    glTexImage2DMultisample(target.GLenum,samples.GLsizei,internalformat.GLint,width.GLsizei,height.GLsizei,fixedsamplelocations.GLboolean)

template generateMipmap*(target:MipmapTarget) =
    glGenerateMipmap(target.GLenum)

# Doesn't seem to exist on win10
#template GenerateTextureMipmap*(texture:TextureId) =
#    glGenerateTextureMipmap(texture.GLuint)

template createShader*(shaderType:ShaderType) : ShaderId  =
    glCreateShader(shaderType.GLenum).ShaderId

template shaderSource*(shader:ShaderId, src: string) =
    let cstr =  allocCStringArray([src])
    glShaderSource(shader.GLuint, 1, cstr, nil)
    deallocCStringArray(cstr)

template compileShader*(shader:ShaderId)  =
    glCompileShader(shader.GLuint)

template getShaderCompileStatus*(shader:ShaderId) : bool  =
    var r : GLint
    glGetShaderiv(shader.GLuint,GL_COMPILE_STATUS,addr r)
    r.bool

template getShaderInfoLog*(shader:ShaderId) : string =
    var logLen : GLint
    glGetShaderiv(shader.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetShaderInfoLog(shader.GLuint,logLen,addr logLen,logStr)
    $logStr

template deleteShader*(shader:ShaderId)  =
    glDeleteShader(shader.GLuint)

template createProgram*() : ShaderProgramId  =
    glCreateProgram().ShaderProgramId

template attachShader*(program:ShaderProgramId, shader:ShaderId)  =
    glAttachShader(program.GLuint,shader.GLuint)

template linkProgram*(program:ShaderProgramId)  =
    glLinkProgram(program.GLuint)

template getProgramLinkStatus*(program:ShaderProgramId) : bool  =
    var r : GLint
    glGetProgramiv(program.GLuint,GL_LINK_STATUS,addr r)
    r.bool

template getProgramInfoLog*(program:ShaderProgramId) : string  =
    var logLen : GLint
    glGetProgramiv(program.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetProgramInfoLog(program.GLuint,logLen,addr logLen,logStr)
    $logStr

template use*(program:ShaderProgramId)  =
    glUseProgram(program.GLuint)

template getUniformLocation*(program: ShaderProgramId, name: string) : UniformLocation  =
    glGetUniformLocation(program.GLuint,name).UniformLocation

template getUniformBlockIndex*(program:ShaderProgramId, uniformBlockName:string) : uint32 =
    glGetUniformBlockIndex(program.GLuint,uniformBlockName)

template uniformBlockBinding*(program:ShaderProgramId, uniformBlockIndex:uint32, uniformBlockBinding:uint32) =    
    glUniformBLockBinding(program.GLuint, uniformBlockIndex.GLuint, uniformBlockBinding.GLuint)

template uniform1i*(location:UniformLocation, value: int32)   =
    glUniform1i(location.GLint,value.GLint)

template uniform1f*(location:UniformLocation,value: float32)   =
    glUniform1f(location.GLint,value.GLfloat)

template uniform2f*(location:UniformLocation,x:float32, y:float32)   =
    glUniform2f(location.GLint,x.GLfloat,y.GLfloat)
        
template uniform3f*(location:UniformLocation,x:float32, y:float32, z:float32)   =
    glUniform3f(location.GLint,x.GLfloat,y.GLfloat,z.GLfloat)

template uniform3fv*[T](location:UniformLocation,count:int,value:openarray[T]) =
    glUniform3fv(location.GLint,count,cast[ptr GLfloat](value[0].unsafeAddr))

template uniform4f*(location:UniformLocation,x:float32, y:float32, z:float32, w:float32)   =
    glUniform4f(location.GLint,x.GLfloat,y.GLfloat,z.GLfloat, w.GLfloat)
                
type VertexAttribSize = range[1..4]
template vertexAttribPointer*(index:uint32, size:VertexAttribSize, attribType:VertexAttribType, normalized:bool, stride:int, offset:int)  =
    glVertexAttribPointer(index.GLuint, size.GLint, attribType.GLenum, normalized.GLboolean,stride.GLsizei, cast[pointer](offset))
                    
template enableVertexAttribArray*(index:uint32)  =
    glEnableVertexAttribArray(index.GLuint)

# works only for non overlaping offsets
template vertexAttribSetup*[T : int8|uint8|int16|uint16|int32|uint32|float32|float](
    target:BufferTarget,
    data:openarray[T],
    usage:BufferDataUsage,
    normalized:bool,
    ranges:varargs[tuple[index:int,size:int]]) : tuple[vao:VertexArrayId,vbo:BufferId] =
    
    var vertexType : VertexAttribType
    when T is int8:
        vertexType = VertexAttribType.BYTE
    when T is uint8:
        vertexType = VertexAttribType.UNSIGNED_BYTE
    when T is int16:
        vertexType = VertexAttribType.SHORT
    when T is uint16:
        vertexType = VertexAttribType.UNSIGNED_SHORT
    when T is int32:
        vertexType = VertexAttribType.INT
    when T is uint32:
        vertexType = VertexAttribType.UNSIGNED_INT
    when T is float32:        
        vertexType = VertexAttribType.FLOAT
    when T is float:
        vertexType = VertexAttribType.DOUBLE

    let vao = genBindVertexArray()
    let vbo = genBindBufferData(target,data,usage)

    var offset = 0    
    var totalSize = 0
    for r in ranges:
        totalSize = totalSize + r.size
    for i,r in ranges:        
        enableVertexAttribArray(i.uint32)
        vertexAttribPointer(r.index.uint32,r.size,vertexType,normalized,totalSize*T.sizeof(),offset*T.sizeof())
        offset = offset + r.size

    unBindVertexArray()
    (vao,vbo)

template vertexAttribDivisor*(index:uint32,divisor:uint32) =
    glVertexAttribDivisor(index.GLuint,divisor.GLuint)

template drawArrays*(mode:DrawMode, first:int32, count:int32)   =
    glDrawArrays(mode.GLenum, first.GLint, count.GLsizei)

template drawArraysInstanced*(mode:DrawMode, first:int32, count:int32,primcount:int32) =
    glDrawArraysInstanced(mode.GLenum, first.GLint, count.GLsizei,primcount.GLsizei)

template drawElements*[T](mode:DrawMode, count:int, indexType:IndexType, indices:openarray[T])  =
    glDrawElements(mode.GLenum, count.GLsizei, indexType.GLenum, indices[0].unsafeAddr)

template drawElementsInstanced*[T](mode:DrawMode, count:int, indexType:IndexType, indices:openarray[T],primcount:int)  =
    glDrawElementsInstanced(mode.GLenum, count.GLsizei, indexType.GLenum, indices[0].unsafeAddr,primcount.GLsizei)
    
template drawElementsInstanced*(mode:DrawMode, count:int, indexType:IndexType,primcount:int)  =
    glDrawElementsInstanced(mode.GLenum, count.GLsizei, indexType.GLenum, nil,primcount.GLsizei)

template drawElements*(mode:DrawMode, count:int, indexType:IndexType, offset:int) =
    glDrawElements(mode.GLenum, count.GLsizei, indexType.GLenum, cast[pointer](offset))
    
template clear*(buffersToClear:varargs[BufferMask])  =
    var mask : uint32 
    for m in buffersToClear:
        mask = mask or m.uint32
    glClear(mask.GLbitfield)

template clearColor*(r:float32, g:float32, b:float32, a:float32) =
    glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)
    
template blendFunc*(sfactor: BlendFactor, dfactor: BlendFactor) =
    glBlendFunc(sfactor.GLenum, dfactor.GLenum)

template blendFunci*(buf:BufferId, sfactor: BlendFactor, dfactor: BlendFactor) =
    glBlendFunci(buf.GLuint,sfactor.GLenum, dfactor.GLenum)
    
template blendFuncSeparate*(srcRGB: BlendFactor, dstRGB: BlendFactor,srcAlpha: BlendFactor,dstAlpha: BlendFactor) =
    glBlendFunc(srcRGB.GLenum,dstRGB.GLenum,srcAlpha.GLenum,dstAlpha.GLenum)

template blendFuncSeparatei*(buf: BufferId,srcRGB: BlendFactor, dstRGB: BlendFactor,srcAlpha: BlendFactor,dstAlpha: BlendFactor) =
    glBlendFunc(buf.GLuint,srcRGB.GLenum,dstRGB.GLenum,srcAlpha.GLenum,dstAlpha.GLenum)

template blendEquation*(mode:BlendEquationEnum) =
    glBlendEquation(mode.GLenum)

template blendEquationi*(buf:BufferId,mode:BlendEquationEnum) =
    glBlendEquation(buf.GLuint,mode.GLenum)

template cullFace*(face:PolygonFace) = 
    glCullFace(face.GLenum)

template frontFace*(mode:FaceMode) =
    glFrontFace(mode.GLenum)


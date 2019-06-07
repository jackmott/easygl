import opengl


type 
    BufferId* = distinct GLuint
    VertexArrayId* = distinct GLuint    
    TextureId* = distinct GLuint
    ShaderId* = distinct GLuint
    ShaderProgramId* = distinct GLuint
    FrameBufferId* = distinct GLuint
    RenderBufferID* = distinct GLuint
    UniformLocation* = distinct GLint    
        
# When passing objects to opengl you may need this to get a relative pointer
template offsetof*(typ, field): untyped = (var dummy: typ; cast[int](addr(dummy.field)) - cast[int](addr(dummy)))

# Deviate from opengl name here because GetError conflicts with SDL2
template getGLError*() : GLenum =
    glGetError()

template viewport*(x,y,width,height:int32) =
    glViewport(x.GLint,y.GLint,width.GLsizei,height.GLsizei)

template enable*(cap:GLenum) =
    glEnable(cap)

template disable*(cap:GLenum) =
    glDisable(cap)

template polygonMode*(face, mode:GLenum) =
    glPolygonMode(face, mode)

template depthMask*(flag: bool) =
    glDepthMask(flag.GLboolean)

template depthFunc*(fun: GLenum) = 
    glDepthFunc(fun)

template stencilMask*(mask:uint32)  =     
    glStencilMask(mask.GLuint)

template stencilFunc*(fun:GLenum, reference: int32, mask:uint32) =     
    glStencilFunc(fun, reference.GLint, mask.GLuint)

template stencilFuncSeparate*(face:GLenum,fun:GLenum, reference: int32, mask:uint32) =
    glStencilFuncSeparate(face, fun, reference.GLint, mask.GLuint)

template stencilOp*(sfail,dpfail,dppass: GLenum) =
    glStencilOp(sfail, dpfail, dppass)

template stencilOpSeparate*(face, sfail, dpfail, dppass:GLenum) =
    glStencilOpSeparate(face,sfail, dpfail, dppass)


template genFramebuffer*() : FramebufferId =
    var frameBuffer:GLuint
    glGenFramebuffers(1,addr frameBuffer)
    frameBuffer

template genFramebuffers*(count:int32) : seq[FramebufferId] =
    let frames = newSeq[FramebufferId](count)
    glGenFramebuffers(count.GLsizei,cast[ptr GLuint](buffers[0].unsafeAddr))
    frames

template bindFramebuffer*(target:GLenum, frameBuffer:FramebufferId) =
    glBindFramebuffer(target,frameBuffer.GLuint)

template genBindFramebuffer*(target:GLenum) : FramebufferId =
    var framebuffer:GLuint
    glGenFramebuffers(1,addr framebuffer)
    glBindFramebuffer(target,framebuffer)
    frameBuffer.FramebufferId

template unBindFramebuffer*(target:GLenum) = 
    glBindFramebuffer(target,0)

template checkFramebufferStatus*(target:GLenum) : GLenum =
    glCheckFramebufferStatus(target)

# todo: this has a lot of rules about what the arguments can be, see:
# https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glFramebufferTexture.xhtml
# can we get compile time gaurantees on these?  asserts in debug mode maybe?
template framebufferTexture2D*(target,
                                attachment,
                                textarget: GLenum,
                                texture: TextureId,
                                level:int) =
    glFramebufferTexture2D(target,attachment,textarget,texture.GLuint,level.int32)

template blitFramebuffer*(srcX0,srcY0,srcX1,srcY1,dstX0,dstY0,dstX1,dsyY1:int,masks:varargs[GLenum],filter:GLenum) =
    var mask : uint32 
    for m in masks:
        mask = mask or m.uint32
    glBlitFramebuffer(srcX0.GLint,srcY0.GLint,srcX1.GLint,srcY1.GLint,dstX0.GLint,dstY0.GLint,dstX1.GLint,dsyY1.GLint,mask.GLbitfield,filter)


template drawBuffers*(bufs: openarray[GLenum]) =
    glDrawBuffers(bufs.len.GLsizei,bufs[0].unsafeAddr)

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
template framebufferRenderbuffer*(target, 
                                 attachment:GLenum,
                                 renderbuffer:RenderbufferId) =
    glFramebufferRenderBuffer(target,attachment,GL_RENDERBUFFER,renderbuffer.GLuint)


type RenderbufferSize* =  range[1..GL_MAX_RENDERBUFFER_SIZE.int]
template renderbufferStorage*(internalformat:GLenum, width:RenderbufferSize,height:RenderbufferSize) =
    glRenderBufferStorage(GL_RENDERBUFFER,internalformat,width.GLsizei,height.GLsizei)

template renderbufferStorageMultisample*(samples:int,internalformat:GLenum, width:RenderbufferSize,height:RenderbufferSize) =
    glRenderBufferStorageMultisample(GL_RENDERBUFFER,samples.GLsizei,internalformat.GLenum,width.GLsizei,height.GLsizei)
                                 
template genBuffer*() : BufferId  =
    var buffer:GLuint
    glGenBuffers(1,addr buffer)
    buffer.BufferId

template genBuffers*(count:int32) : seq[BufferId] =
    let buffers = newSeq[BufferId](count)
    glGenBuffers(count.GLsizei,cast[ptr GLuint](buffers[0].unsafeAddr))
    buffers

template bindBuffer*(target:GLenum, buffer:BufferId)  =
    glBindBuffer(target,buffer.GLuint)

template unBindBuffer*(target:GLenum) = 
    glBindBuffer(target.GLenum,0)

template genBindBuffer*(target:GLenum) : BufferId = 
    var buffer : GLuint
    glGenBuffers(1,addr buffer)
    glBindBuffer(target,buffer)
    buffer.BufferId

template bindBufferRange*(target:GLenum,index:uint32,buffer:BufferId, offset:int32, size:int) =
    glBindBufferRange(target,index.GLuint,buffer.GLuint,offset.GLintptr,size.GLsizeiptr)
    
template bufferData*[T](target:GLenum, data:openarray[T], usage:GLenum)  =
    glBufferData(target,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,usage)

template bufferData*[T](target:GLenum,size:int, data:ptr T, usage:GLenum)  =
    glBufferData(target,size.GLsizeiptr,cast[pointer](data),usage)

template bufferData*(target:GLenum,size:int,usage:GLenum) =
    glBufferData(target,size.GLsizeiptr,nil,usage)

# bind and set buffer data in one go
template bindBufferData*[T](target:GLenum, buffer:BufferId, data:openarray[T], usage)  = 
    glBindBuffer(target,buffer.GLuint)
    glBufferData(target,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,usage)

# generate, bind, and set buffer data in one go
template genBindBufferData*[T](target:GLenum, data:openarray[T], usage:GLenum) :BufferId   =     
    var buffer : GLuint
    glGenBuffers(1,addr buffer)
    glBindBuffer(target,buffer)
    glBufferData(target,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,usage)
    buffer.BufferId
        
template deleteBuffer*(buffer:BufferId) =    
    var b = buffer
    glDeleteBuffers(1,b.GLuint.addr)

template deleteBuffers*(buffers:openArray[BufferId]) =
    glDeleteBuffers(buffers.len.GLsizei,cast[ptr GLUint](buffers[0].unsafeAddr))

template bufferSubData*[T](target:GLenum,offset:int,size:int,data:openarray[T]) =
    glBufferSubData(target,offset.GLintptr, size.GLsizeiptr, data[0].unsafeAddr)

template copyBufferSubData*(readTarget:GLenum, 
                           writeTarget:GLenum,
                           readOffset:int32,
                           writeOffset:int32,
                           size:int32) =
    glCopyBufferSubData(readTarget,writeTarget,readOffset.GLintptr,writeOffset.GLintptr,size.GLsizeiptr)
    
template mapBuffer*[T](target:GLenum, access:GLenum) : ptr UncheckedArray[T] =
    cast[ptr UncheckedArray[T]](glMapBuffer(target, access))

template unmapBuffer*(target:GLenum) =
    glUnmapBuffer(target)

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

template genBindTexture*(target:GLenum) : TextureId = 
    var tex : GLuint
    glGenTextures(1.GLsizei,addr tex)
    glBindTexture(target, tex)
    tex.TextureId

template bindTexture*(target:GLenum, texture:TextureId) =
    glBindTexture(target, texture.GLuint)

template unBindTexture*(target:GLenum) =
    glBindTexture(target, 0.GLuint)

template activeTexture*(texture:GLenum) =
    glActiveTexture(texture)

template texParameteri*(target:GLenum, pname:GLenum, param:GLint) =
    glTexParameteri(target,pname,param)

template texParameterf*(target:GLenum, pname:GLenum, param:GLfloat) =
    glTexParameterf(target,pname,param)

template texImage2D*[T](target:GLenum, level:int32, internalFormat:GLEnum, width:int32, height:int32, format:GLenum, pixelType:GLenum, data: openArray[T] )  =    
    glTexImage2D(target,level.GLint,internalFormat.GLint,width.GLsizei,height.GLsizei,0,format,pixelType,data[0].unsafeAddr)

# for cases where data is null, just don't pass it in
template texImage2D*(target:GLenum, level:int32, internalFormat:GLEnum, width:int32, height:int32, format:GLenum, pixelType:GLenum) =
    glTexImage2D(target,level.GLint,internalFormat.GLint,width.GLsizei,height.GLsizei,0,format,pixelType,nil)    

template texImage2DMultisample*(target:GLenum,samples:int,internalformat:GLenum,width:int,height:int,fixedsamplelocations:bool) = 
    glTexImage2DMultisample(target,samples.GLsizei,internalformat.GLint,width.GLsizei,height.GLsizei,fixedsamplelocations.GLboolean)

template generateMipmap*(target:GLenum) =
    glGenerateMipmap(target)

# Doesn't seem to exist on win10
#template GenerateTextureMipmap*(texture:TextureId) =
#    glGenerateTextureMipmap(texture.GLuint)

template createShader*(shaderType:GLenum) : ShaderId  =
    glCreateShader(shaderType).ShaderId

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
template vertexAttribPointer*(index:uint32, size:VertexAttribSize, attribType:GLenum, normalized:bool, stride:int, offset:int)  =
    glVertexAttribPointer(index.GLuint, size.GLint, attribType, normalized.GLboolean,stride.GLsizei, cast[pointer](offset))
                    
template enableVertexAttribArray*(index:uint32)  =
    glEnableVertexAttribArray(index.GLuint)

# works only for non overlaping offsets
template vertexAttribSetup*[T : int8|uint8|int16|uint16|int32|uint32|float32|float](
    target:GLenum,
    data:openarray[T],
    usage:GLenum,
    normalized:bool,
    ranges:varargs[tuple[index:int,size:int]]) : tuple[vao:VertexArrayId,vbo:BufferId] =
    
    var vertexType : GLenum
    when T is int8:
        vertexType = GL_BYTE
    when T is uint8:
        vertexType = GL_UNSIGNED_BYTE
    when T is int16:
        vertexType = GL_SHORT
    when T is uint16:
        vertexType = GL_UNSIGNED_SHORT
    when T is int32:
        vertexType = GL_INT
    when T is uint32:
        vertexType = GL_UNSIGNED_INT
    when T is float32:        
        vertexType = GL_FLOAT
    when T is float:
        vertexType = GL_DOUBLE

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

template drawArrays*(mode:GLenum, first:int32, count:int32)   =
    glDrawArrays(mode, first.GLint, count.GLsizei)

template drawArraysInstanced*(mode:GLenum, first:int32, count:int32,primcount:int32) =
    glDrawArraysInstanced(mode, first.GLint, count.GLsizei,primcount.GLsizei)

template drawElements*[T](mode:GLenum, count:int, indexType:GLenum, indices:openarray[T])  =
    glDrawElements(mode, count.GLsizei, indexType, indices[0].unsafeAddr)

template drawElementsInstanced*[T](mode:GLenum, count:int, indexType:GLenum, indices:openarray[T],primcount:int)  =
    glDrawElementsInstanced(mode, count.GLsizei, indexType, indices[0].unsafeAddr,primcount.GLsizei)
    
template drawElementsInstanced*(mode:GLenum, count:int, indexType:GLenum,primcount:int)  =
    glDrawElementsInstanced(mode, count.GLsizei, indexType, nil,primcount.GLsizei)

template drawElements*(mode:GLenum, count:int, indexType:GLenum, offset:int) =
    glDrawElements(mode, count.GLsizei, indexType, cast[pointer](offset))
    
template clear*(mask:GLbitfield)  =    
    glClear(mask)

template clearColor*(r:float32, g:float32, b:float32, a:float32) =
    glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)
    
template blendFunc*(sfactor, dfactor: GLenum) =
    glBlendFunc(sfactor, dfactor)

template blendFunci*(buf:BufferId, sfactor, dfactor: GLenum) =
    glBlendFunci(buf.GLuint,sfactor, dfactor)
    
template blendFuncSeparate*(srcRGB, dstRGB,srcAlpha,dstAlpha:GLenum) =
    glBlendFunc(srcRGB,dstRGB,srcAlpha,dstAlpha)

template blendFuncSeparatei*(buf: BufferId,srcRGB, dstRGB,srcAlpha,dstAlpha:GLenum) =
    glBlendFunc(buf.GLuint,srcRGB,dstRGB,srcAlpha,dstAlpha)

template blendEquation*(mode:GLenum) =
    glBlendEquation(mode)

template blendEquationi*(buf:BufferId,mode:GLenum) =
    glBlendEquation(buf.GLuint,mode)

template cullFace*(face:GLenum) = 
    glCullFace(face)

template frontFace*(mode:GLenum) =
    glFrontFace(mode)

template pushAttrib*(mask:GLbitfield) =    
    glPushAttrib(mask)


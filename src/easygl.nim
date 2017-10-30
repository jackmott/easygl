import opengl
include easygl.easygl_types

# When passing objects to opengl you may need this to get a relative pointer
template offsetof*(typ, field): untyped = (var dummy: typ; cast[int](addr(dummy.field)) - cast[int](addr(dummy)))

template Enable*(cap:Capability) =
    glEnable(cap.GLenum)

template Disable*(cap:Capability) =
    glDisable(cap.GLenum)

template PolygonMode*(face:PolygonFace, mode:PolygonModeEnum) =
    glPolygonMode(face.GLenum, mode.GLenum)

template DepthMask*(flag: bool) =
    glDepthMask(flag.GLboolean)

template DepthFunc*(fun: AlphaFunc) = 
    glDepthFunc(fun.GLenum)

template StencilMask*(mask:uint32)  = 
    glStencilMask(mask.GLuint)

template StencilFunc*(fun:AlphaFunc, reference: int32, mask:uint32) = 
    glStencilFunc(fun.GLenum, reference.GLint, mask.GLuint)

template StencilFuncSeparate*(face:PolygonFace,fun:AlphaFunc, reference: int32, mask:uint32) =
    glStencilFuncSeparate(face.GLenum, fun.GLenum, reference.GLint, mask.GLuint)

template StencilOp*(sfail: StencilOpEnum, dpfail: StencilOpEnum, dppass: StencilOpEnum) =
    glStencilOp(sfail.GLenum, dpfail.GLenum, dppass.GLenum)

template StencilOpSeparate*(face:PolygonFace, sfail: StencilOpEnum, dpfail: StencilOpEnum, dppass: StencilOpEnum) =
    glStencilOpSeparate(face.GLenum,sfail.GLenum, dpfail.GLenum, dppass.GLenum)

template GenBuffer*() : BufferId  =
    var buffer:GLuint
    glGenBuffers(1,addr buffer)
    buffer.BufferId

template GenBuffers*(count:int32) : seq[BufferId] =
    let buffers = newSeq[BufferId](count)
    glGenBuffers(count.GLsizei,cast[ptr GLuint](buffers[0].unsafeAddr))
    buffers

template BindBuffer*(target:BufferTarget, buffer:BufferId)  =
    glBindBuffer(target.GLenum,buffer.GLuint)
    
proc BufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage) {.inline.} =
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data.unsafeAddr,usage.GLenum)

# bind and set buffer data in one go
proc BindBufferData*[T](target:BufferTarget, buffer:BufferId, data:openarray[T], usage:BufferDataUsage) {.inline.} = 
    glBindBuffer(target.GLenum,buffer.GLuint)
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data.unsafeAddr,usage.GLenum)

# generate, bind, and set buffer data in one go
proc GenBindBufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage) :BufferId  {.inline.} = 
    var buffer : GLuint
    glGenBuffers(1,addr buffer)
    glBindBuffer(target.GLenum,buffer)
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data.unsafeAddr,usage.GLenum)
    buffer.BufferId
    
template DeleteBuffer*(buffer:BufferId) =    
    var b = buffer
    glDeleteBuffers(1,b.GLuint.addr)

template DeleteBuffers*(buffers:openArray[BufferId]) =
    glDeleteBuffers(buffers.len.GLsizei,cast[ptr GLUint](buffers.unsafeAddr))
    
template GenVertexArray*() : VertexArrayId  =
    var VAO : GLuint
    glGenVertexArrays(1.GLsizei,cast[ptr GLuint](addr VAO))
    VAO.VertexArrayId

# Gen and bind vertex array in one go
template GenBindVertexArray*() : VertexArrayId  =
    var VAO : GLuint
    glGenVertexArrays(1.GLsizei,addr VAO)
    glBindVertexArray(VAO)
    VAO.VertexArrayId
    
template GenVertexArrays*(count:int32) : seq[VertexArrayId]  =
    let vertexArrays = newSeq[VertexArrayId](count)
    glGenVertexArrays(count.GLsizei,cast[ptr GLuint](vertexArrays[0].unsafeAddr))
    vertexArrays
    
template BindVertexArray*(vertexArray:VertexArrayId)  =
    glBindVertexArray(vertexArray.GLuint)

template UnbindVertexArray*() =
    glBindVertexArray(0)

template DeleteVertexArray*(vertexArray:VertexArrayId) =    
    var v = vertexArray
    glDeleteVertexArrays(1,v.GLUint.addr)

template DeleteVertexArrays*(vertexArrays:openArray[VertexArrayId]) =
    glDeleteVertexArrays(vertexArrays.len.GLsizei,cast[ptr GLUint](vertexArrays[0].unsafeAddr))
    
template GenTexture*() : TextureId =
    var tex : GLuint
    glGenTextures(1.GLsizei,addr tex)
    tex.TextureId

template GenTextures*(count:int32) : seq[TextureId] =
    let textures = newSeq[TextureId](count)
    glGenTextures(count.GLsizei,cast[ptr GLuint](textures[0].unsafeAddr))
    textures

template BindTexture*(target:TextureTarget, texture:TextureId) =
    glBindTexture(target.GLenum, texture.GLuint)

template ActiveTexture*(texture:TextureUnit) =
    glActiveTexture(texture.GLenum)

template TexParameteri*(target:TextureTarget, pname:TextureParameter, param:GLint) =
    glTexParameteri(target.GLenum,pname.GLenum,param)

# todo why not template work?
proc TexImage2D*[T](target:TexImageTarget, level:int32, internalFormat:TextureInternalFormat, width:int32, height:int32, format:PixelDataFormat, pixelType:PixelDataType, data: openArray[T] ) {.inline.} =
    glTexImage2D(target.GLenum,level.GLint,internalFormat.GLint,width.GLsizei,height.GLsizei,0,format.GLenum,pixelType.GLenum,data.unsafeAddr)

template GenerateMipmap*(target:MipmapTarget) =
    glGenerateMipmap(target.GLenum)

# Doesn't seem to exist on win10
#template GenerateTextureMipmap*(texture:TextureId) =
#    glGenerateTextureMipmap(texture.GLuint)

template CreateShader*(shaderType:ShaderType) : ShaderId  =
    glCreateShader(shaderType.GLenum).ShaderId

template ShaderSource*(shader:ShaderId, src: string) =
    let cstr =  allocCStringArray([src])
    glShaderSource(shader.GLuint, 1, cstr, nil)
    deallocCStringArray(cstr)

template CompileShader*(shader:ShaderId)  =
    glCompileShader(shader.GLuint)

template GetShaderCompileStatus*(shader:ShaderId) : bool  =
    var r : GLint
    glGetShaderiv(shader.GLuint,GL_COMPILE_STATUS,addr r)
    r.bool

template GetShaderInfoLog*(shader:ShaderId) : string =
    var logLen : GLint
    glGetShaderiv(shader.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetShaderInfoLog(shader.GLuint,logLen,addr logLen,logStr)
    $logStr

template DeleteShader*(shader:ShaderId)  =
    glDeleteShader(shader.GLuint)

template CreateProgram*() : ShaderProgramId  =
    glCreateProgram().ShaderProgramId

template AttachShader*(program:ShaderProgramId, shader:ShaderId)  =
    glAttachShader(program.GLuint,shader.GLuint)

template LinkProgram*(program:ShaderProgramId)  =
    glLinkProgram(program.GLuint)

template GetProgramLinkStatus*(program:ShaderProgramId) : bool  =
    var r : GLint
    glGetProgramiv(program.GLuint,GL_LINK_STATUS,addr r)
    r.bool

template GetProgramInfoLog*(program:ShaderProgramId) : string  =
    var logLen : GLint
    glGetProgramiv(program.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetProgramInfoLog(program.GLuint,logLen,addr logLen,logStr)
    $logStr

template UseProgram*(program:ShaderProgramId)  =
    glUseProgram(program.GLuint)

template GetUniformLocation*(program: ShaderProgramId, name: string) : UniformLocation  =
    glGetUniformLocation(program.GLuint,name).UniformLocation

template Uniform1i*(location:UniformLocation, value: int32)   =
    glUniform1i(location.GLint,value.GLint)

template Uniform1f*(location:UniformLocation,value: float32)   =
    glUniform1f(location.GLint,value.GLfloat)

template Uniform2f*(location:UniformLocation,x:float32, y:float32)   =
    glUniform2f(location.GLint,x.GLfloat,y.GLfloat)
        
template Uniform3f*(location:UniformLocation,x:float32, y:float32, z:float32)   =
    glUniform3f(location.GLint,x.GLfloat,y.GLfloat,z.GLfloat)

template Uniform4f*(location:UniformLocation,x:float32, y:float32, z:float32, w:float32)   =
    glUniform4f(location.GLint,x.GLfloat,y.GLfloat,z.GLfloat, w.GLfloat)
                
type VertexAttribSize = range[1..4]
template VertexAttribPointer*(index:uint32, size:VertexAttribSize, attribType:VertexAttribType, normalized:bool, stride:int32, offset:int32)  =
    glVertexAttribPointer(index.GLuint, size.GLint, attribType.GLenum, normalized.GLboolean,stride.GLsizei, cast[pointer](offset))
    
template EnableVertexAttribArray*(index:uint32)  =
    glEnableVertexAttribArray(index.GLuint)

template DrawArrays*(mode:DrawMode, first:int32, count:int32)   =
    glDrawArrays(mode.GLenum, first.GLint, count.GLsizei)

proc DrawElements*[T](mode:DrawMode, count:int, indexType:IndexType, indices:openarray[T]) {.inline.} =
    glDrawElements(mode.GLenum, count.GLsizei, indexType.GLenum, indices.unsafeAddr)

template DrawElements*(mode:DrawMode, count:int, indexType:IndexType, offset:int) =
    glDrawElements(mode.GLenum, count.GLsizei, indexType.GLenum, cast[pointer](offset))
    
template Clear*(buffersToClear:varargs[ClearBufferMask])  =
    var mask : uint32 
    for m in buffersToClear:
        mask = mask or m.uint32
    glClear(mask.GLbitfield)

template ClearColor*(r:float32, g:float32, b:float32, a:float32) =
        glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)
    

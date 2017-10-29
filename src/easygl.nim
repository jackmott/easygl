import opengl
include easygl.easygl_types

# When passing objects to opengl you may need this to get a relative pointer
template offsetof*(typ, field): untyped = (var dummy: typ; cast[int](addr(dummy.field)) - cast[int](addr(dummy)))

# OpenGL uses the convention of 0 for 'null' which is used to clear things
# These are convenience constants you can use
const VERTEX_ARRAY_NULL* = 0.VertexArrayId
const BUFFER_NULL* = 0.BufferId
const TEXTURE_NULL* = 0.TextureId

proc Enable*(cap:Capability) =
    glEnable(cap.GLenum)

proc Disable*(cap:Capability) =
    glDisable(cap.GLenum)

proc PolygonMode*(face:PolygonFace, mode:PolygonModeEnum) {.inline.} =
    glPolygonMode(face.GLenum, mode.GLenum)

proc GenBuffer*() : BufferId {.inline.} =
    glGenBuffers(1,cast[ptr GLuint](addr result))

proc GenBuffers*(count:int32) : seq[BufferId] =
    result = newSeq[BufferId](count)
    glGenBuffers(count.GLsizei,cast[ptr GLuint](result[0].unsafeAddr))

proc BindBuffer*(target:BufferTarget, buffer:BufferId) {.inline.} =
    glBindBuffer(target.GLenum,buffer.GLuint)
    
proc BufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage) {.inline.} =
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data.unsafeAddr,usage.GLenum)
    
proc DeleteBuffer*(buffer:BufferId) =
    var b = buffer
    glDeleteBuffers(1,b.GLuint.addr)

proc DeleteBuffers*(buffers:openArray[BufferId]) =
    glDeleteBuffers(buffers.len.GLsizei,cast[ptr GLUint](buffers.unsafeAddr))
    
proc GenVertexArray*() : VertexArrayId {.inline.} =
    glGenVertexArrays(1.GLsizei,cast[ptr GLuint](addr result))
    
proc GenVertexArrays*(count:int32) : seq[VertexArrayId] {.inline.} =
    result = newSeq[VertexArrayId](count)
    glGenVertexArrays(count.GLsizei,cast[ptr GLuint](result[0].unsafeAddr))
    
proc BindVertexArray*(vertexArray:VertexArrayId) {.inline.} =
    glBindVertexArray(vertexArray.GLuint)

proc DeleteVertexArray*(vertexArray:VertexArrayId) =
    var v = vertexArray
    glDeleteVertexArrays(1,v.GLUint.addr)

proc DeleteVertexArrays*(vertexArrays:openArray[VertexArrayId]) =
    glDeleteVertexArrays(vertexArrays.len.GLsizei,cast[ptr GLUint](vertexArrays.unsafeAddr))
    
proc GenTexture*() : TextureId =
    glGenTextures(1.GLsizei,cast[ptr GLuint](addr result))

proc GenTextures*(count:int32) : seq[TextureId] =
    result = newSeq[TextureId](count)
    glGenTextures(count.GLsizei,cast[ptr GLuint](result[0].unsafeAddr))

proc BindTexture*(target:TextureTarget, texture:TextureId) =
    glBindTexture(target.GLenum, texture.GLuint)


proc ActiveTexture*(texture:TextureUnit) =
    glActiveTexture(texture.GLenum)

proc TexParameteri*(target:TextureTarget, pname:TextureParameter, param:GLint) =
    glTexParameteri(target.GLenum,pname.GLenum,param)

proc TexImage2D*[T](target:TexImageTarget, level:int32, internalFormat:TextureInternalFormat, width:int32, height:int32, format:PixelDataFormat, `type`:PixelDataType, data: openArray[T] ) =
    glTexImage2D(target.GLenum,level.GLint,internalFormat.GLint,width.GLsizei,height.GLsizei,0,format.GLenum,`type`.GLenum,data.unsafeAddr)

proc GenerateMipmap*(target:MipmapTarget) =
    glGenerateMipmap(target.GLenum)

# Doesn't seem to exist on win10
#proc GenerateTextureMipmap*(texture:TextureId) =
#    glGenerateTextureMipmap(texture.GLuint)

proc CreateShader*(shaderType:ShaderType) : ShaderId {.inline.} =
    glCreateShader(shaderType.GLenum).ShaderId

proc ShaderSource*(shader:ShaderId, src: string) =
    let cstr =  allocCStringArray([src])
    glShaderSource(shader.GLuint, 1, cstr, nil)
    deallocCStringArray(cstr)

proc CompileShader*(shader:ShaderId) {.inline.} =
    glCompileShader(shader.GLuint)

proc GetShaderCompileStatus*(shader:ShaderId) : bool {.inline.} =
    var r : GLint
    glGetShaderiv(shader.GLuint,GL_COMPILE_STATUS,addr r)
    r.bool

proc GetShaderInfoLog*(shader:ShaderId) : string =
    var logLen : GLint
    glGetShaderiv(shader.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetShaderInfoLog(shader.GLuint,logLen,addr logLen,logStr)
    $logStr

proc DeleteShader*(shader:ShaderId) {.inline.} =
    glDeleteShader(shader.GLuint)

proc CreateProgram*() : ShaderProgramId {.inline.} =
    glCreateProgram().ShaderProgramId

proc AttachShader*(program:ShaderProgramId, shader:ShaderId) {.inline.} =
    glAttachShader(program.GLuint,shader.GLuint)

proc LinkProgram*(program:ShaderProgramId) {.inline.} =
    glLinkProgram(program.GLuint)

proc GetProgramLinkStatus*(program:ShaderProgramId) : bool {.inline.} =
    var r : GLint
    glGetProgramiv(program.GLuint,GL_LINK_STATUS,addr r)
    r.bool

proc GetProgramInfoLog*(program:ShaderProgramId) : string {.inline.} =
    var logLen : GLint
    glGetProgramiv(program.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetProgramInfoLog(program.GLuint,logLen,addr logLen,logStr)
    $logStr

proc UseProgram*(program:ShaderProgramId) {.inline.} =
    glUseProgram(program.GLuint)

proc GetUniformLocation*(program: ShaderProgramId, name: string) : UniformLocation {.inline.} =
    glGetUniformLocation(program.GLuint,name).UniformLocation

proc Uniform1i*(location:UniformLocation, value: int32)  {.inline.} =
    glUniform1i(location.GLint,value.GLint)

proc Uniform1f*(location:UniformLocation,value: float32)  {.inline.} =
    glUniform1f(location.GLint,value.GLfloat)

proc Uniform2f*(location:UniformLocation,x:float32, y:float32)  {.inline.} =
    glUniform2f(location.GLint,x.GLfloat,y.GLfloat)
        
proc Uniform3f*(location:UniformLocation,x:float32, y:float32, z:float32)  {.inline.} =
    glUniform3f(location.GLint,x.GLfloat,y.GLfloat,z.GLfloat)

proc Uniform4f*(location:UniformLocation,x:float32, y:float32, z:float32, w:float32)  {.inline.} =
    glUniform4f(location.GLint,x.GLfloat,y.GLfloat,z.GLfloat, w.GLfloat)
                
type VertexAttribSize = range[1..4]
proc VertexAttribPointer*(index:uint32, size:VertexAttribSize, attribType:VertexAttribType, normalized:bool, stride:int32, `pointer`:int32) {.inline.} =
    glVertexAttribPointer(index.GLuint, size.GLint, attribType.GLenum, normalized.GLboolean,stride.GLsizei, cast[pointer](`pointer`))
    
proc EnableVertexAttribArray*(indeX:uint32) {.inline.} =
    glEnableVertexAttribArray(index.GLuint)

proc DrawArrays*(mode:DrawMode, first:int32, count:int32)  {.inline.} =
    glDrawArrays(mode.GLenum, first.GLint, count.GLsizei)

proc DrawElements*[T](mode:DrawMode, count:int, indexType:IndexType, indices:openarray[T]) =
    glDrawElements(mode.GLenum, count.GLsizei, indexType.GLenum, indices.unsafeAddr)

proc DrawElements*(mode:DrawMode, count:int, indexType:IndexType, offset:int) =
    glDrawElements(mode.GLenum, count.GLsizei, indexType.GLenum, cast[pointer](offset))
    
proc Clear*(buffersToClear:varargs[ClearBufferMask]) {.inline.} =
    var mask = buffersToClear[0].uint32
    for i in countup(1,<buffersToClear.len):
        mask = mask or buffersToClear[i].uint32
    glClear(mask.GLbitfield)

proc ClearColor*(r:float32, g:float32, b:float32, a:float32) =
        glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)
    

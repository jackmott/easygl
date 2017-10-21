import opengl
import glm
include types/easygl_types

proc rawSeq[T](s: seq[T]): ptr T =
    {.emit: "result = `s`->data;".}

proc GenBuffer*() : BufferId {.inline.} =
    glGenBuffers(1,cast[ptr GLuint](addr result))

proc GenBuffers*(count:int32) : seq[BufferId] =
    result = newSeq[BufferId](count)
    glGenBuffers(count.GLsizei,cast[ptr GLuint](result.rawSeq))

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
    glGenVertexArrays(count.GLsizei,cast[ptr GLuint](result.rawSeq))

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
    glGenTextures(count.GLsizei,cast[ptr GLuint](result.rawSeq))

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

proc CompileAndAttachShader*(shaderType:ShaderType, shaderPath: string, programId:ShaderProgramId) : ShaderId =
    echo "Compiling and attaching shader"
    echo $shaderType
    let shaderId = CreateShader(shaderType)
    ShaderSource(shaderId,readFile(shaderPath))
    CompileShader(shaderId)
    if not GetShaderCompileStatus(shaderId):
        echo "Shader Compile Error:" 
        echo GetShaderInfoLog(shaderId)
    else:
        AttachShader(programId,shaderId)
    shaderId

proc GetProgramLinkStatus*(program:ShaderProgramId) : bool {.inline.} =
    var r : GLint
    glGetProgramiv(program.GLuint,GL_LINK_STATUS,addr r)
    r.bool

proc GetProgramInfoLog*(program:ShaderProgramId) : string =
    var logLen : GLint
    glGetProgramiv(program.GLuint,GL_INFO_LOG_LENGTH, addr logLen)
    var logStr = cast[ptr GLchar](alloc(logLen))
    glGetProgramInfoLog(program.GLuint,logLen,addr logLen,logStr)
    $logStr


proc CreateAndLinkProgram*(vertexPath:string, fragmentPath:string, geometryPath:string = nil) : ShaderProgramId =
    let programId = CreateProgram()
    let vert = CompileAndAttachShader(ShaderType.VERTEX_SHADER,vertexPath,programId)
    let frag = CompileAndAttachShader(ShaderType.FRAGMENT_SHADER,fragmentPath,programId)
    let geo =
        if geometryPath != nil:
            CompileAndAttachShader(ShaderType.GEOMETRY_SHADER,geometryPath,programId)
        else:
            0.ShaderId

    LinkProgram(programId)
    echo "linked"
    if not GetProgramLinkStatus(programId):
        echo "Link Error:"
        echo GetProgramInfoLog(programId)
    
    DeleteShader(vert)
    DeleteShader(frag)
    if geometryPath != nil: DeleteShader(geo)
    programId

proc UseProgram*(program:ShaderProgramId) {.inline.} =
    glUseProgram(program.GLuint)

proc GetUniformLocation*(program: ShaderProgramId, name: string) : UniformLocation =
    glGetUniformLocation(program.GLuint,name).UniformLocation

proc SetBool*(program:ShaderProgramId, name: string, value: bool) =
    glUniform1i(GetUniformLocation(program,name).GLint,value.GLint)


proc SetInt*(program:ShaderProgramId, name: string, value: int32) =
    glUniform1i(GetUniformLocation(program,name).GLint,value.GLint)
    
proc SetFloat*(program:ShaderProgramId, name: string, value: float32) =
    glUniform1f(GetUniformLocation(program,name).GLint,value.GLfloat)

proc SetVec2*(program:ShaderProgramId, name: string, value:var Vec2f) =
    glUniform2fv(GetUniformLocation(program,name).GLint,2,value.caddr)

proc SetVec2*(program:ShaderProgramId, name: string, x:float32, y:float32) =
    glUniform2f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat)
    
proc SetVec3*(program:ShaderProgramId, name: string, value:var Vec3f) =
    glUniform3fv(GetUniformLocation(program,name).GLint,3,value.caddr)
    
proc SetVec3*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32) =
    glUniform3f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat)

proc SetVec4*(program:ShaderProgramId, name:string, value: var Vec4f) =
    glUniform4fv(GetUniformLocation(program,name).GLint,4,value.caddr)

proc SetVec4*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32, w:float32) =
    glUniform4f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat,w.GLfloat)
            
proc SetMat4*(program:ShaderProgramId, name: string, transpose:bool, value: var Mat4f ) =
    glUniformMatrix4fv(GetUniformLocation(program,name).GLint,1,transpose.GLboolean,value.caddr)

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
    
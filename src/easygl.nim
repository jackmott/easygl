import opengl
import basic2d
import basic3d

type 
    BufferId* = distinct GLuint
    ShaderId* = distinct GLuint
    ShaderProgramId* = distinct GLuint
    VertexArrayId* = distinct GLuint
    UniformLocation = distinct GLint

    BufferTarget* {.pure.} = enum
        ARRAY_BUFFER = GL_ARRAY_BUFFER, #0x88923
        ELEMENT_ARRAY_BUFFER = GL_ELEMENT_ARRAY_BUFFER, #0x8893 
        PIXEL_PACK_BUFFER = GL_PIXEL_PACK_BUFFER, #0x88EB
        PIXEL_UNPACK_BUFFER = GL_PIXEL_UNPACK_BUFFER, #0x88EC
        UNIFORM_BUFFER = GL_UNIFORM_BUFFER #0x8A11
        TEXTURE_BUFFER = GL_TEXTURE_BUFFER, #0x8C2A
        TRANSFORM_FEEDBACK_BUFFER = GL_TRANSFORM_FEEDBACK_BUFFER, #0x8C8E
        COPY_READ_BUFFER = GL_COPY_READ_BUFFER, #0x8F36
        COPY_WRITE_BUFFER = GL_COPY_WRITE_BUFFER, #0x8F37
        DRAW_INDIRECT_BUFFER = GL_DRAW_INDIRECT_BUFFER,#0x8F3F 
        SHADER_STORAGE_BUFFER = GL_SHADER_STORAGE_BUFFER, #0x90D2
        DISPATCH_INDIRECT_BUFFER = GL_DISPATCH_INDIRECT_BUFFER, #0x90EE
        QUERY_BUFFER = GL_QUERY_BUFFER, #0x9192
        ATOMIC_COUNTER_BUFFER = GL_ATOMIC_COUNTER_BUFFER, #0x92C0
    
    BufferDataUsage* {.pure.} = enum
        STREAM_DRAW = GL_STREAM_DRAW, 
        STREAM_READ = GL_STREAM_READ, 
        STREAM_COPY = GL_STREAM_COPY, 
        STATIC_DRAW = GL_STATIC_DRAW, 
        STATIC_READ = GL_STATIC_READ, 
        STATIC_COPY = GL_STATIC_COPY,
        DYNAMIC_DRAW = GL_DYNAMIC_DRAW, 
        DYNAMIC_READ = GL_DYNAMIC_READ,
        DYNAMIC_COPY = GL_DYNAMIC_COPY

    ShaderType* {.pure.} = enum
        FRAGMENT_SHADER = GL_FRAGMENT_SHADER #0x8B30
        VERTEX_SHADER = GL_VERTEX_SHADER #0x8B31,
        GEOMETRY_SHADER = GL_GEOMETRY_SHADER, #0x8DD9
        TESS_EVALUATION_SHADER = GL_TESS_EVALUATION_SHADER, #0x8E87
        TESS_CONTROL_SHADER = GL_TESS_CONTROL_SHADER, #0x8E88
        COMPUTE_SHADER = GL_COMPUTE_SHADER, #0x91B9

    VertexAttribIType* {.pure.} = enum
        BYTE = cGL_BYTE, 
        UNSIGNED_BYTE = GL_UNSIGNED_BYTE,
        SHORT =  cGL_SHORT, 
        UINSIGNED_SHORT = GL_UNSIGNED_SHORT, 
        INT = cGL_INT, 
        UNSIGNED_INT = GL_UNSIGNED_INT

    VertexAttribType* {.pure.} = enum
        BYTE = cGL_BYTE, #0x1400
        UNSIGNED_BYTE = GL_UNSIGNED_BYTE, #0x1401
        SHORT =  cGL_SHORT, #0x1402
        UINSIGNED_SHORT = GL_UNSIGNED_SHORT, #0x1403
        INT = cGL_INT,#0x1404 
        UNSIGNED_INT = GL_UNSIGNED_INT, #0x1405
        FLOAT = cGL_FLOAT, #0x1406
        DOUBLE = cGL_DOUBLE, 
        HALF_FLOT = GL_HALF_FLOAT, #0x140B                
        FIXED = cGL_FIXED, 
        UNSIGNED_INT_2_10_10_10_REV = GL_UNSIGNED_INT_2_10_10_10_REV, # 0x8368
        UNSIGNED_INT_10F_11F_11F_REV = GL_UNSIGNED_INT_10F_11F_11F_REV #0x8C3B
        INT_2_10_10_10_REV = GL_INT_2_10_10_10_REV, #0x8D9F        

    DrawMode* {.pure.} = enum
        POINTS = GL_POINTS, #0x0000
        LINE = GL_LINES, # 0x0001        
        LINE_LOOP = GL_LINE_LOOP, #0x0002
        LINE_STRIP = GL_LINE_STRIP, #0x0003
        TRIANGLES = GL_TRIANGLES, #0x0004
        TRIANGLE_STRIP = GL_TRIANGLE_STRIP, #0x0005
        TRIANGLE_FAN = GL_TRIANGLE_FAN, #0x0006
        LINES_ADJACENCY = GL_LINES_ADJACENCY, #0x000A
        LINE_STRIP_ADJACENCY = GL_LINE_STRIP_ADJACENCY, #0x000B
        TRIANGLES_ADJACENCY = GL_TRIANGLES_ADJACENCY, #0x000C                        
        TRIANGLE_STRIP_ADJACENCY = GL_TRIANGLE_STRIP_ADJACENCY, #0x000D        
        PATCHES = GL_PATCHES #0x000E

    ClearBufferMask* {.pure.} = enum
        DEPTH_BUFFER_BIT = GL_DEPTH_BUFFER_BIT,
        STENCIL_BUFFER_BIT = GL_STENCIL_BUFFER_BIT,
        COLOR_BUFFER_BIT = GL_COLOR_BUFFER_BIT

    IndexType* {.pure.} = enum
        UNSIGNED_BYTE = GL_UNSIGNED_BYTE,
        UNSIGNED_SHORT = GL_UNSIGNED_SHORT,
        UNSIGNED_INT = GL_UNSIGNED_INT

proc rawSeq[T](s: seq[T]): ptr T =
    {.emit: "result = `s`->data;".}

proc GenBuffer*() : BufferId {.inline.} =
    glGenBuffers(1,cast[ptr GLuint](addr result))

proc GenBuffers*(count:int32) : seq[BufferId] =
    result = newSeq[BufferId](count)
    glGenBuffers(count.GLsizei,cast[ptr GLuint](result.rawSeq))

proc DeleteBuffer*(buffer:BufferId) =
    var b = buffer
    glDeleteBuffers(1,b.GLuint.addr)

proc DeleteBuffers*(buffers:openArray[BufferId]) =
    glDeleteBuffers(buffers.len.GLsizei,cast[ptr GLUint](buffers.unsafeAddr))

proc BindBuffer*(target:BufferTarget, buffer:BufferId) {.inline.} =
    glBindBuffer(target.GLenum,buffer.GLuint)
    
proc BufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage) {.inline.} =    
    glBufferData(target.GLenum,data.len*T.sizeof().GLsizeiptr,data.unsafeAddr,usage.GLenum)

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

proc SetVec2*(program:ShaderProgramId, name: string, value: Vector2d) =
    glUniform2f(GetUniformLocation(program,name).GLint,value.x.GLfloat,value.y.GLfloat)

proc SetVec2*(program:ShaderProgramId, name: string, x:float32, y:float32) =
    glUniform2f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat)
    
proc SetVec3*(program:ShaderProgramId, name: string, value: Vector3d) =
    glUniform3f(GetUniformLocation(program,name).GLint,value.x.GLfloat,value.y.GLfloat,value.z.GLfloat)
    
proc SetVec3*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32) =
    glUniform3f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat)

proc SetVec4*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32, w:float32) =
    glUniform4f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat,w.GLfloat)
            

proc GenVertexArray*() : VertexArrayId {.inline.} =
    glGenVertexArrays(1.GLsizei,cast[ptr GLuint](addr result))
    
proc GenVertexArrays*(count:int32) : seq[VertexArrayId] {.inline.} =
    result = newSeq[VertexArrayId](count)
    glGenVertexArrays(count.GLsizei,cast[ptr GLuint](result.rawSeq))

proc DeleteVertexArray*(vertexArray:VertexArrayId) =
    var v = vertexArray
    glDeleteVertexArrays(1,v.GLUint.addr)

proc DeleteVertexArrays*(vertexArrays:openArray[VertexArrayId]) =
    glDeleteVertexArrays(vertexArrays.len.GLsizei,cast[ptr GLUint](vertexArrays.unsafeAddr))

proc BindVertexArray*(vertexArray:VertexArrayId) {.inline.} = 
    glBindVertexArray(vertexArray.GLuint)

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
    
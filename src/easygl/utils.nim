import ../easygl
import stb_image/read as stbi
import opengl
import glm

# Compiles and attaches in 1 step with error reporting
proc CompileAndAttachShader*(shaderType:ShaderType, shaderPath: string, programId:ShaderProgramId) : ShaderId =    
    let shaderId = CreateShader(shaderType)
    ShaderSource(shaderId,readFile(shaderPath))
    CompileShader(shaderId)
    if not GetShaderCompileStatus(shaderId):
        echo "Shader Compile Error:" 
        echo GetShaderInfoLog(shaderId)
    else:
        AttachShader(programId,shaderId)
    shaderId

# Handles everything needed to set up a shader, with error reporting
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

    if not GetProgramLinkStatus(programId):
        echo "Link Error:"
        echo GetProgramInfoLog(programId)
    
    DeleteShader(vert)
    DeleteShader(frag)
    if geometryPath != nil: DeleteShader(geo)
    programId

#handles most image types automatically
proc LoadTextureWithMips*(path:string) : TextureId =        
        let textureId = GenTexture()
        var
            width,height,channels:int
            data: seq[uint8]
        stbi.setFlipVerticallyOnLoad(true)        
        data = stbi.load(path,width,height,channels,stbi.Default)
        
        if data != nil and data.len != 0:
            let format = 
                if channels == 1:                    
                    PixelDataFormat.RED
                elif channels == 3:                    
                    PixelDataFormat.RGB
                elif channels == 4:
                    PixelDataFormat.RGBA
                else:            
                    ( echo "texture unknown, assuming rgb";        
                    PixelDataFormat.RGB)
            
            BindTexture(TextureTarget.TEXTURE_2D,textureId)
            TexImage2D(TexImageTarget.TEXTURE_2D,0'i32,format.TextureInternalFormat,width.int32,height.int32,format,PixelDataType.UNSIGNED_BYTE,data)
            GenerateMipmap(MipmapTarget.TEXTURE_2D)                        
            TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_S,GL_REPEAT)
            TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_T,GL_REPEAT)            
            TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
            TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)               
            textureId
        else:
            echo "Failure to Load Image"            
            0.TextureId
            
                            

# Uniform funcs with easier / shorter names and glm types
proc SetBool*(program:ShaderProgramId, name: string, value: bool) =
    glUniform1i(GetUniformLocation(program,name).GLint,value.GLint)

proc SetInt*(program:ShaderProgramId, name: string, value: int32) =
    glUniform1i(GetUniformLocation(program,name).GLint,value.GLint)
    
proc SetFloat*(program:ShaderProgramId, name: string, value: float32) =
    glUniform1f(GetUniformLocation(program,name).GLint,value.GLfloat)

proc SetVec2*(program:ShaderProgramId, name: string, value:var Vec2f) =
    glUniform2fv(GetUniformLocation(program,name).GLint,1,value.caddr)

proc SetVec2*(program:ShaderProgramId, name: string, x:float32, y:float32) =
    glUniform2f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat)
    
proc SetVec3*(program:ShaderProgramId, name: string, value:var Vec3f) =
    glUniform3fv(GetUniformLocation(program,name).GLint,1,value.caddr)
    
proc SetVec3*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32) =
    glUniform3f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat)

proc SetVec4*(program:ShaderProgramId, name:string, value: var Vec4f) =
    glUniform4fv(GetUniformLocation(program,name).GLint,1,value.caddr)

proc SetVec4*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32, w:float32) =
    glUniform4f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat,w.GLfloat)
            
proc SetMat4*(program:ShaderProgramId, name: string, transpose:bool, value: var Mat4f ) =
    glUniformMatrix4fv(GetUniformLocation(program,name).GLint,1,transpose.GLboolean,value.caddr)
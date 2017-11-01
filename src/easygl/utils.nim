import 
    ../easygl,
    stb_image/read as stbi,
    opengl,
    glm    

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
proc LoadCubemap*(faces:array[6,string]) : TextureId =        
        let textureId = GenBindTexture(TextureTarget.TEXTURE_CUBE_MAP)
        
        stbi.setFlipVerticallyOnLoad(false)               

        # todo parallelize this
        for i,face in faces:            
            var width,height,channels:int                
            let data = stbi.load(face,width,height,channels,stbi.Default)        
            if data != nil and data.len != 0:                
                let target = (GL_TEXTURE_CUBE_MAP_POSITIVE_X.int+i).TexImageTarget
                TexImage2D(target,0'i32,TextureInternalFormat.RGB,width.int32,height.int32,PixelDataFormat.RGB,PixelDataType.UNSIGNED_BYTE,data)                    
            else:
                echo "Failure to Load Cubemap Image"            
                                                          
        TexParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
        TexParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)               
        TexParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
        TexParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)
        TexParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE)
        textureId
       
            
proc LoadTextureWithMips*(path:string) : TextureId =        
    let textureId = GenBindTexture(TextureTarget.Texture2D)    
    stbi.setFlipVerticallyOnLoad(true)               
    var width,height,channels:int        
    let data = stbi.load(path,width,height,channels,stbi.Default)        
    if data != nil and data.len != 0:
        let (format,param) = 
            if channels == 1:                    
                (PixelDataFormat.RED,GL_REPEAT)
            elif channels == 3:                    
                (PixelDataFormat.RGB,GL_REPEAT)
            elif channels == 4:
                (PixelDataFormat.RGBA,GL_CLAMP_TO_EDGE)
            else:            
                ( echo "texture unknown, assuming rgb";        
                (PixelDataFormat.RGB,GL_REPEAT) )
                
        TexImage2D(TexImageTarget.TEXTURE_2D,0'i32,format.TextureInternalFormat,width.int32,height.int32,format,PixelDataType.UNSIGNED_BYTE,data)
        GenerateMipmap(MipmapTarget.TEXTURE_2D)        
        
        TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_S,param)
        TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_T,param)            
        TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
        TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)               
        textureId
    else:
        echo "Failure to Load Image"            
        0.TextureId
                    

# Uniform funcs with easier / shorter names and glm types
template SetBool*(program:ShaderProgramId, name: string, value: bool) =
    glUniform1i(GetUniformLocation(program,name).GLint,value.GLint)

template SetInt*(program:ShaderProgramId, name: string, value: int32) =
    glUniform1i(GetUniformLocation(program,name).GLint,value.GLint)
    
template SetFloat*(program:ShaderProgramId, name: string, value: float32) =
    glUniform1f(GetUniformLocation(program,name).GLint,value.GLfloat)

template SetVec2*(program:ShaderProgramId, name: string, value:var Vec2f) =
    glUniform2fv(GetUniformLocation(program,name).GLint,1,value.caddr)

template SetVec2*(program:ShaderProgramId, name: string, x:float32, y:float32) =
    glUniform2f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat)
    
template SetVec3*(program:ShaderProgramId, name: string, value:var Vec3f) =
    glUniform3fv(GetUniformLocation(program,name).GLint,1,value.caddr)
    
template SetVec3*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32) =
    glUniform3f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat)

template SetVec4*(program:ShaderProgramId, name:string, value: var Vec4f) =
    glUniform4fv(GetUniformLocation(program,name).GLint,1,value.caddr)

template SetVec4*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32, w:float32) =
    glUniform4f(GetUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat,w.GLfloat)
            
template SetMat4*(program:ShaderProgramId, name: string, value: var Mat4f ) =
    glUniformMatrix4fv(GetUniformLocation(program,name).GLint,1,GL_FALSE,value.caddr)

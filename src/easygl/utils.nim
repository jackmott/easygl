import 
    ../easygl,
    stb_image/read as stbi,
    opengl,
    glm    

# Compiles and attaches in 1 step with error reporting
proc compileAndAttachShader*(shaderType:ShaderType, shaderPath: string, programId:ShaderProgramId) : ShaderId =    
    let shaderId = createShader(shaderType)
    shaderSource(shaderId,readFile(shaderPath))
    compileShader(shaderId)
    if not getShaderCompileStatus(shaderId):
        echo "Shader Compile Error:" 
        echo getShaderInfoLog(shaderId)
    else:
        attachShader(programId,shaderId)
    shaderId

# Handles everything needed to set up a shader, with error reporting
proc createAndLinkProgram*(vertexPath:string, fragmentPath:string, geometryPath:string = nil) : ShaderProgramId =
    let programId = createProgram()
    let vert = compileAndAttachShader(ShaderType.VERTEX_SHADER,vertexPath,programId)
    let frag = compileAndAttachShader(ShaderType.FRAGMENT_SHADER,fragmentPath,programId)
    let geo =
        if geometryPath != nil:
            compileAndAttachShader(ShaderType.GEOMETRY_SHADER,geometryPath,programId)
        else:
            0.ShaderId

    linkProgram(programId)    

    if not getProgramLinkStatus(programId):
        echo "Link Error:"
        echo getProgramInfoLog(programId)
    
    deleteShader(vert)
    deleteShader(frag)
    if geometryPath != nil: deleteShader(geo)
    programId

#handles most image types automatically
proc loadCubemap*(faces:array[6,string]) : TextureId =        
        let textureId = genBindTexture(TextureTarget.TEXTURE_CUBE_MAP)
        
        stbi.setFlipVerticallyOnLoad(false)               
        # todo parallelize this
        
        for i,face in faces:            
            var width,height,channels:int                
            let data = stbi.load(face,width,height,channels,stbi.Default)        
            if data != nil and data.len != 0:                
                let target = (GL_TEXTURE_CUBE_MAP_POSITIVE_X.int+i).TexImageTarget
                texImage2D(target,0'i32,TextureInternalFormat.RGB,width.int32,height.int32,PixelDataFormat.RGB,PixelDataType.UNSIGNED_BYTE,data)                    
            else:
                echo "Failure to Load Cubemap Image"            
                                                          
        texParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
        texParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)               
        texParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
        texParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)
        texParameteri(TextureTarget.TEXTURE_CUBE_MAP,TextureParameter.TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE)
        textureId
       
            
proc loadTextureWithMips*(path:string, gammaCorrection:bool = false) : TextureId =        
    let textureId = genBindTexture(TextureTarget.Texture2D)    
    stbi.setFlipVerticallyOnLoad(true)               
    var width,height,channels:int        
    let data = stbi.load(path,width,height,channels,stbi.Default)        
    if data != nil and data.len != 0:
        let gammaFormat = 
            if gammaCorrection: 
                TextureInternalFormat.SRGB 
            else: 
                TextureInternalFormat.RGB
                
        let (internalFormat,dataFormat,param) = 
            if channels == 1:                    
                (TextureInternalFormat.RED,PixelDataFormat.RED,GL_REPEAT)
            elif channels == 3:                    
                (gammaFormat,PixelDataFormat.RGB,GL_REPEAT)
            elif channels == 4:
                (gammaFormat,PixelDataFormat.RGBA,GL_CLAMP_TO_EDGE)
            else:            
                ( echo "texture unknown, assuming rgb";        
                       (TextureInternalFormat.RGB,PixelDataFormat.RGB,GL_REPEAT) )
                
        texImage2D(TexImageTarget.TEXTURE_2D,
                   0'i32,
                   internalFormat.TextureInternalFormat,
                   width.int32,
                   height.int32,
                   dataFormat,
                   PixelDataType.UNSIGNED_BYTE,
                   data)

        generateMipmap(MipmapTarget.TEXTURE_2D)        
        
        texParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_S,param)
        texParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_T,param)            
        texParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
        texParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)               
        textureId
    else:
        echo "Failure to Load Image"            
        0.TextureId
                    

# Uniform funcs with easier / shorter names and glm types
template setBool*(program:ShaderProgramId, name: string, value: bool) =
    glUniform1i(getUniformLocation(program,name).GLint,value.GLint)

template setInt*(program:ShaderProgramId, name: string, value: int32) =
    glUniform1i(getUniformLocation(program,name).GLint,value.GLint)
    
template setFloat*(program:ShaderProgramId, name: string, value: float32) =
    glUniform1f(getUniformLocation(program,name).GLint,value.GLfloat)

template setVec2*(program:ShaderProgramId, name: string, value:var Vec2f) =
    glUniform2fv(getUniformLocation(program,name).GLint,1,value.caddr)

template setVec2*(program:ShaderProgramId, name: string, x:float32, y:float32) =
    glUniform2f(getUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat)
    
template setVec3*(program:ShaderProgramId, name: string, value:var Vec3f) =
    glUniform3fv(getUniformLocation(program,name).GLint,1,value.caddr)
    
template setVec3*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32) =
    glUniform3f(getUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat)

template setVec4*(program:ShaderProgramId, name:string, value: var Vec4f) =
    glUniform4fv(getUniformLocation(program,name).GLint,1,value.caddr)

template setVec4*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32, w:float32) =
    glUniform4f(getUniformLocation(program,name).GLint,x.GLfloat,y.GLfloat,z.GLfloat,w.GLfloat)
            
template setMat4*(program:ShaderProgramId, name: string, value: var Mat4f ) =
    glUniformMatrix4fv(getUniformLocation(program,name).GLint,1,GL_FALSE,value.caddr)

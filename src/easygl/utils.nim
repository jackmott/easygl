import 
    ../easygl,
    stb_image/read as stbi,
    opengl,
    glm,
    options 
 

proc compileAndAttachShaderString*(shaderType:GLenum, shaderSrc: string, programId:ShaderProgramId) : ShaderId =    
    let shaderId = createShader(shaderType)
    shaderSource(shaderId,shaderSrc)
    compileShader(shaderId)
    if not getShaderCompileStatus(shaderId):
        echo "Shader Compile Error:" 
        echo getShaderInfoLog(shaderId)
    else:
        attachShader(programId,shaderId)
    shaderId

proc createAndLinkProgramString*(vertexSrc:string, fragmentSrc:string, geometrySrc:Option[string] = none(string) ) : ShaderProgramId =
    let programId = createProgram()
    let vert = compileAndAttachShaderString(GL_VERTEX_SHADER,vertexSrc,programId)
    let frag = compileAndAttachShaderString(GL_FRAGMENT_SHADER,fragmentSrc,programId)
    let geo =
        if geometrySrc.isSome:
            compileAndAttachShaderString(GL_GEOMETRY_SHADER,geometrySrc.get(),programId)
        else:
            0.ShaderId

    linkProgram(programId)    

    if not getProgramLinkStatus(programId):
        echo "Link Error:"
        echo getProgramInfoLog(programId)
    
    deleteShader(vert)
    deleteShader(frag)
    if geometrySrc.isSome: deleteShader(geo)
    programId

# Compiles and attaches in 1 step with error reporting
proc compileAndAttachShader*(shaderType:GLenum, shaderPath: string, programId:ShaderProgramId) : ShaderId =    
    let shaderId = createShader(shaderType)
    shaderSource(shaderId,readFile(shaderPath))
    compileShader(shaderId)
    if not getShaderCompileStatus(shaderId):
        echo "Shader Compile Error ("&shaderPath&"):" 
        echo getShaderInfoLog(shaderId)
    else:
        attachShader(programId,shaderId)
    shaderId

# Handles everything needed to set up a shader, with error reporting
proc createAndLinkProgram*(vertexPath:string, fragmentPath:string, geometryPath:Option[string] = none(string)) : ShaderProgramId =
    let programId = createProgram()
    let vert = compileAndAttachShader(GL_VERTEX_SHADER,vertexPath,programId)
    let frag = compileAndAttachShader(GL_FRAGMENT_SHADER,fragmentPath,programId)
    let geo =
        if geometryPath.isSome:
            compileAndAttachShader(GL_GEOMETRY_SHADER,geometryPath.get(),programId)
        else:
            0.ShaderId

    linkProgram(programId)    

    if not getProgramLinkStatus(programId):
        echo "Link Error:"
        echo getProgramInfoLog(programId)
    
    deleteShader(vert)
    deleteShader(frag)
    if geometryPath.isSome: deleteShader(geo)
    programId

#handles most image types automatically 
proc loadCubemap*(faces:array[6,string]) : TextureId =        
        let textureId = genBindTexture(GL_TEXTURE_CUBE_MAP)
        
        stbi.setFlipVerticallyOnLoad(false)               
        # todo parallelize this
        
        for i,face in faces:            
            var width,height,channels:int                
            let data = stbi.load(face,width,height,channels,stbi.Default)        
            let target = (GL_TEXTURE_CUBE_MAP_POSITIVE_X.int+i).GLenum
            texImage2D(target,0'i32,GL_RGB,width.int32,height.int32,GL_RGB,GL_UNSIGNED_BYTE,data)                    
                                                          
        texParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
        texParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAG_FILTER,GL_LINEAR)               
        texParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
        texParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)
        texParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE)
        textureId
       
            
proc loadTextureWithMips*(path:string, gammaCorrection:bool = false) : TextureId =        
    let textureId = genBindTexture(GL_Texture2D)    
    stbi.setFlipVerticallyOnLoad(true)               
    var width,height,channels:int        
    let data = stbi.load(path,width,height,channels,stbi.Default)        
    let gammaFormat = 
        if gammaCorrection: 
            GL_SRGB 
        else: 
            GL_RGB
            
    let (internalFormat,dataFormat,param) = 
        if channels == 1:                    
            (GL_RED,GL_RED,GL_REPEAT)
        elif channels == 3:                    
            (gammaFormat,GL_RGB,GL_REPEAT)
        elif channels == 4:
            (gammaFormat,GL_RGBA,GL_CLAMP_TO_EDGE)
        else:            
            ( echo "texture unknown, assuming rgb";        
                   (GL_RGB,GL_RGB,GL_REPEAT) )
            
    texImage2D(GL_TEXTURE_2D,
               0'i32,
               internalFormat,
               width.int32,
               height.int32,
               dataFormat,
               GL_UNSIGNED_BYTE,
               data)

    generateMipmap(GL_TEXTURE_2D)        
    
    texParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,param)
    texParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,param)            
    texParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
    texParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)               
    textureId
                

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

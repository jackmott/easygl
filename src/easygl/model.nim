import 
    ../easygl,
    utils,
    opengl,
    assimp,
    glm,
    mesh,
    strutils

type Model* = object
    texturesLoaded* : seq[Texture]
    meshes*: seq[Mesh]
    directory*:string
    gammaCorrection*:bool

proc draw*(model:Model, shaderProgram:ShaderProgramId) =
   
    for mesh in model.meshes:
        mesh.draw(shaderProgram)
    
proc loadMaterialTextures(model: var Model, mat:PMaterial, texType:TTextureType, typeName:TextureType) : seq[Texture] =
    var textures = newSeq[Texture]()
    let texCount = getTextureCount(mat,texType).int    
    for i in 0 .. <texCount:        
        var str : AIString
        let ret = getTexture(mat,texType,i.cint,addr str)       
        if ret == ReturnFailure:
            echo "failed to get texture"
            break;         
        var skip = false
        for j,loadedTex in model.texturesLoaded:
            if loadedTex.path == $str:
                textures.add(loadedTex)
                skip = true;
                break;
        if not skip:
            var texture:Texture
            texture.id = loadTextureWithMips(model.directory & $str)
            texture.texType = typeName
            texture.path = $str
            textures.add(texture)
            model.texturesLoaded.add(texture)
    textures


proc processMesh(model:var Model, mesh:PMesh, scene:PScene) : Mesh =    
    var vertices = newSeq[Vertex]()
    var indices = newSeq[uint32]()
    var textures = newSeq[Texture]()

    let vertexCount = mesh.vertexCount.int
    for i in 0 .. <vertexCount:
        var vertex:Vertex
        var vector:Vec3f
        vector.x = mesh.vertices[i].x
        vector.y = mesh.vertices[i].y
        vector.z = mesh.vertices[i].z
        vertex.Position = vector

        vector.x = mesh.normals[i].x
        vector.y = mesh.normals[i].y
        vector.z = mesh.normals[i].z
        vertex.Normal = vector

        # todo - texCoords are a multidimensional array
        # will this work??
        if mesh.texCoords[0] != nil:
            let m = mesh.texCoords[0]
            var vec : Vec2f
            vec.x = m[i].x
            vec.y = m[i].y
            vertex.TexCoords = vec
        else:
            vertex.TexCoords = vec2(0.0'f32,0.0'f32)
        
        vector.x = mesh.tangents[i].x
        vector.y = mesh.tangents[i].y
        vector.z = mesh.tangents[i].z
        vertex.Tangent = vector

        vector.x = mesh.bitTangents[i].x
        vector.y = mesh.bitTangents[i].y
        vector.z = mesh.bitTangents[i].z
        vertex.Bitangent = vector

        vertices.add(vertex)
    
    for i in 0 .. <mesh.faceCount.int:
        let face = mesh.faces[i]
        for j in 0 .. <face.indexCount.int:
            indices.add(face.indices[j].uint32)

    let material = scene.materials[mesh.materialIndex]          

    # we assume a convention for sampler names in the shaders. Each diffuse texture should be named
    # as 'texture_diffuseN' where N is a sequential number ranging from 1 to MAX_SAMPLER_NUMBER. 
    # Same applies to other texture as the following list summarizes:
    # diffuse: texture_diffuseN
    # specular: texture_specularN
    # normal: texture_normalN
    let diffuseMaps = loadMaterialTextures(model,material,TTextureType.TexDiffuse,TextureType.TextureDiffuse)    
    let specularMaps = loadMaterialTextures(model,material,TTextureType.TexSpecular,TextureType.TextureSpecular)
    let normalMaps = loadMaterialTextures(model,material,TTextureType.TexNormals,TextureType.TextureNormal)
    let heightMaps = loadMaterialTextures(model,material,TTextureType.TexHeight,TextureType.TextureHeight)
    textures = textures & diffuseMaps
    textures = textures & specularMaps
    textures = textures & normalMaps
    textures = textures & heightMaps    
    newMesh(vertices,indices,textures)
    

    

proc processNode(model:var Model,node:PNode, scene:PScene) = 
    let meshCount = node.meshCount.int    
    for i in 0 .. <meshCount:        
        model.meshes.add(processMesh(model,scene.meshes[node.meshes[i]],scene))
    let childrenCount = node.childrenCount.int
    for i in 0 .. <childrenCount:
        processNode(model,node.children[i],scene)


proc loadModel*(path:string) : Model = 
    var model:Model
    model.texturesLoaded = newSeq[Texture]()
    model.meshes = newSeq[Mesh]()
    echo path
    let scene = aiImportFile(path,aiProcess_Triangulate or aiProcess_FlipUVs or aiProcess_CalcTangentSpace)
    #todo error check
    model.directory = path.substr(0,path.rfind("/"))
    echo model.directory
    processNode(model,scene.rootNode,scene)
    model
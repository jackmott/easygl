import 
    ../easygl,
    utils,
    opengl,
    assimp,
    glm,
    mesh,
    strutils

type Model* = object
    texturesLoaded : var seq[Texture]
    meshes: seq[Mesh]
    directory:string
    gammaCorrection:bool

proc LoadMaterialTextures(model: Model, mat:PMaterial, texType:TTextureType, typeName:TextureType) : seq[Texture] =
    var textures = newSeq[Texture]()
    for i in 0 .. <GetTextureCount(texType):
        var str : AIString
        discard getTexture(mat,texType,i.cint,addr str)
        var skip = false
        for j,loadedTex in model.texturesLoaded:
            if loadedTex.path == $str:
                textures.add(loadedTex)
                skip = true;
                break;
        if not skip:
            var texture:Texture
            texture.id = LoadTextureWithMips(model.directory & $str)
            texture.texType = typeName
            texture.path = $str
            textures.add(texture)
            model.texturesLoaded.add(texture)
    textures


proc ProcessMesh(model:var Model, mesh:PMesh, scene:PScene) : Mesh =
    var vertices : seq[Vertex]
    var indices: seq[uint32]
    var textures: seq[Texture]

    for i in 0 .. <mesh.vertexCount:
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
            var vec : Vec2f
            vec.x = mesh.texCoords[i].x
            vec.y = mesh.texCoords[i].y
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

    for i in 0 .. <mesh.faceCount:
        let face = mesh.faces[i]
        for j in 0 .. <face.indexCount:
            indices.add(face.indices[j].uint32)

    let material = scene.materials[mesh.materialIndex]          

    # we assume a convention for sampler names in the shaders. Each diffuse texture should be named
    # as 'texture_diffuseN' where N is a sequential number ranging from 1 to MAX_SAMPLER_NUMBER. 
    # Same applies to other texture as the following list summarizes:
    # diffuse: texture_diffuseN
    # specular: texture_specularN
    # normal: texture_normalN
    
    

proc ProcessNode(model:var Model,node:PNode, scene:PScene) = 
    for i in 0 .. <node.meshCount:
        model.meshes.add(ProcessMesh(model,scene.meshes[i],scene))
    for i in 0 .. <node.childrenCount:
        ProcessNode(model,node.children[i],scene)


proc LoadModel(model:var Model,path:string) = 
    let scene = aiImportFile(path,aiProcess_Triangulate or aiProcess_FlipUVs or aiProcess_CalcTangentSpace)
    #todo error check
    model.directory = path.substr(0,path.rfind("/"))
    ProcessNode(model,scene.rootNode,scene)
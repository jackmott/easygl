import 
    ../easygl,
    utils,
    opengl,
    assimp,
    glm

type TextureType* {.pure.} = enum
    TextureDiffuse,
    TextureSpecular,
    TextureNormal,
    TextureHeight

type Vertex* = object
    Position*:Vec3f
    Normal*:Vec3f
    TexCoords*:Vec2f
    Tangent*:Vec3f
    Bitangent*:Vec3f


type Texture* = object
    id*:TextureId
    texType*:TextureType
    path*:string

type Mesh* = object
    vertices*: seq[Vertex]
    indices*: seq[uint32]
    textures*: seq[Texture]
    VAO*:VertexArrayId
    VBO:BufferId
    EBO:BufferId


proc SetupMesh(mesh:var Mesh) =
    mesh.VAO = GenVertexArray()
    mesh.VBO = GenBuffer()
    mesh.EBO = GenBuffer()
    BindVertexArray(mesh.VAO)
    BindBuffer(BufferTarget.ARRAY_BUFFER,mesh.VBO)
    
    BufferData(BufferTarget.ARRAY_BUFFER,mesh.vertices,BufferDataUsage.STATIC_DRAW)

    BindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER,mesh.EBO)
    BufferData(BufferTarget.ELEMENT_ARRAY_BUFFER,mesh.indices,BufferDataUsage.STATIC_DRAW)

    EnableVertexAttribArray(0)
    VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,Vertex.sizeof().int32,0)
    EnableVertexAttribArray(1)
    VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,Vertex.sizeof().int32,offsetof(Vertex,Normal).int32)
    EnableVertexAttribArray(2)
    VertexAttribPointer(2,3,VertexAttribType.FLOAT,false,Vertex.sizeof().int32,offsetof(Vertex,TexCoords).int32)
    EnableVertexAttribArray(3)
    VertexAttribPointer(3,3,VertexAttribType.FLOAT,false,Vertex.sizeof().int32,offsetof(Vertex,Tangent).int32)
    EnableVertexAttribArray(4)
    VertexAttribPointer(4,3,VertexAttribType.FLOAT,false,Vertex.sizeof().int32,offsetof(Vertex,Bitangent).int32)

    BindVertexArray(VERTEX_ARRAY_NULL)


proc newMesh*(vertices:seq[Vertex], indices:seq[uint32], textures:seq[Texture]) : Mesh =
    result.vertices = vertices
    result.indices = indices
    result.textures = textures
    result.SetupMesh()

proc Draw*(mesh:Mesh,shaderProgram:ShaderProgramId) =
    var diffuseNr,specularNr,normalNr,heightNr = 1'u32
    for i,tex in mesh.textures:
        echo "i:" & $i        
        ActiveTexture((TextureUnit.TEXTURE0.ord + i).TextureUnit)
        let texIndex =
            case tex.texType:
                of TextureType.TextureDiffuse:
                    diffuseNr.inc()
                    diffuseNr-1
                of TextureType.TextureSpecular:
                    specularNr.inc()
                    specularNr-1
                of TextureType.TextureNormal:
                    normalNr.inc()
                    normalNr-1
                of TextureType.TextureHeight:
                    heightNr.inc()
                    heightNr-1
        let uniform = $tex.texType & $texIndex
        echo "uniform:" & uniform
        shaderProgram.SetInt(uniform,i.int32)
        BindTexture(TextureTarget.TEXTURE_2D, mesh.textures[i].id)

    BindVertexArray(mesh.VAO)
    DrawElements(DrawMode.TRIANGLES,mesh.indices.len,IndexType.UNSIGNED_INT,0)
    BindVertexArray(VERTEX_ARRAY_NULL)
    ActiveTexture(TextureUnit.TEXTURE0)
import easygl
import opengl
import easygl.assimp
import glm

type TextureType* {.pure.} = enum
    DIFFUSE,
    SPECULAR,
    NORMAL,
    HEIGHT

type Vertex* = object
    Position:Vec3f
    Normal:Vec3f
    TexCoords:Vec3f
    Tangent:Vec3f
    Bitangent:Vec3f


type Texture* = object
    id:TextureId
    texType:TextureType
    path:AIstring

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

    # is this safe in nim?rbp

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



proc newMesh(vertices:seq[Vertex], indices:seq[uint32], textures:seq[Texture]) : Mesh =
    result.vertices = vertices
    result.indices = indices
    result.textures = textures
    result.SetupMesh()
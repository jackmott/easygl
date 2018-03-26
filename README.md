# EasyGL

A typesafe opengl wrapper for the nim language with no runtime overhead

Also includes utility functions for working with shaders, model importing (using ASSIMP), and texture loading (using stb_image)

/examples includes a port (ongoing) of the tutorials on learnopengl.com



# OpenGL ids are made type safe

OpenGL uses object ids in it's api which are all just unsigned integers. This can cause hard to track down bugs. For instance, if you transposed program and shader on accident, it would compile fine in C or with a normal wrapper, as both are GLuint types. You would need to call glGetError() to find out what was wrong, and you wouldn't know what line of code it was caused by:

```c
// void glAttachShader(GLuint program,GLuint shader);

glAttachShader(shader,program);   // no compile time error

```

With EasyGL I use Nim's `distinct` type alias feature so that this would be a compiler error:

```nim
type ShaderId = distinct GLuint
type ShaderProgramId = distinct GLuint

template AttachShader(program:ShaderProgramId,shader:ShaderId) =
  glAttachShader(program.GLuint,shader.GLuint)

AttachShader(shader,program) # compile error because shader and program are transposed
```


# Range types prevent invalid input

Some OpenGL functions only accept a certain range of values as valid, but the type system can't restrict that at compile time. EasyGL uses Nim's range type to constrain input. For instance glVertexAttribPointer can only accept 1..4 as valid input for the size parameter. Using a range type this can be checked at compile time when possible, and a runtime in debug builds.

```nim
type VertexAttribSize = range[1..4] 
template VertexAttribPointer*(index:uint32, size:VertexAttribSize, attribType:GL_, normalized:bool, stride:int, offset:int)  =
    glVertexAttribPointer(index.GLuint, size.GLint, attribType.GLenum, normalized.GLboolean,stride.GLsizei, cast[pointer](offset))
```

# Remove the need for casting and non idiomatic Nim code

Using the raw OpenGL bindings requries constant casting and non idiomatic code. Such as:

```nim

glBufferData(GL_ARRAY_BUFFER,data.len*T.sizeof().GLsizeiptr,data[0].unsafeAddr,GL_STATIC_DRAW)

```
Here one must pass an unsafe pointer to a `seq` type, and it's size, even though seq already knows it's size. EasyGl abstracts this away, and can accept seq or array types:

```nim
BufferData(GL_ARRAY_BUFFER,data,GL_STATIC_DRAW)
```

# Handy utility functions with Nim Generics

Using Nim's generics features one can drastically reduce the amount of code needed for some common OpenGL patterns, for instance:

```c
unsigned int planeVAO, planeVBO;
glGenVertexArrays(1, &planeVAO);
glGenBuffers(1, &planeVBO);
glBindVertexArray(planeVAO);
glBindBuffer(GL_ARRAY_BUFFER, planeVBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(planeVertices), planeVertices, GL_STATIC_DRAW);
glEnableVertexAttribArray(0);
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
glEnableVertexAttribArray(1);
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
glEnableVertexAttribArray(2);
glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
glBindVertexArray(0);
```

becomes:

```nim
let (planeVAO,planeVBO) = 
  VertexAttribSetup(
    GL_ARRAY_BUFFER,
    planeVertices,
    GL_STATIC_DRAW,
    false,
    (0,3),(1,3),(2,2))
```


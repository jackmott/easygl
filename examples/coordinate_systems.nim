# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import stb_image/read as stbi
import glm

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Shaders", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program

let ourShader = CreateAndLinkProgram("shaders/coordinate_systems.vert","shaders/coordinate_systems.frag")

# Set up vertex data
let vertices : seq[float32]  = 
  @[   
    # positions                 # texture coords
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 0.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32, 0.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32, 1.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32, 1.0'f32,
   -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 0.0'f32,

   -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, 0.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 1.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 1.0'f32,
   -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32, 1.0'f32,
   -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, 0.0'f32,

   -0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
   -0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32, 1.0'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
   -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, 0.0'f32,
   -0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,

    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32, 1.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, 0.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,

   -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32, 1.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
   -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, 0.0'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,

   -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32, 1.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32, 0.0'f32,
   -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32, 0.0'f32,
   -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32, 1.0'f32]

let cubePositions : seq[Vec3f] = 
    @[
        vec3( 0.0'f32,  0.0'f32,  0.0'f32),
        vec3( 2.0'f32,  5.0'f32, -15.0'f32),
        vec3(-1.5'f32, -2.2'f32, -2.5'f32),
        vec3(-3.8'f32, -2.0'f32, -12.3'f32),
        vec3( 2.4'f32, -0.4'f32, -3.5'f32),
        vec3(-1.7'f32,  3.0'f32, -7.5'f32),
        vec3( 1.3'f32, -2.0'f32, -2.5'f32),
        vec3( 1.5'f32,  2.0'f32, -2.5'f32),
        vec3( 1.5'f32,  0.2'f32, -1.5'f32),
        vec3(-1.3'f32,  1.0'f32, -1.5'f32)]

let VAO = GenVertexArray()
let VBO = GenBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
BindVertexArray(VAO)

BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
BufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)

VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
EnableVertexAttribArray(0)

VertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
EnableVertexAttribArray(1)


let texture1 = GenTexture()
BindTexture(TextureTarget.TEXTURE_2D,texture1)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_S,GL_REPEAT)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_T,GL_REPEAT)

TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)

var
    width,height,channels:int
    data: seq[uint8]
stbi.setFlipVerticallyOnLoad(true)
data = stbi.load("textures/container.jpg",width,height,channels,stbi.Default)

if data != nil and data.len != 0:
    TexImage2D(TexImageTarget.TEXTURE_2D,0'i32,TextureInternalFormat.RGB,width.int32,height.int32,PixelDataFormat.RGB,PixelDataType.UNSIGNED_BYTE,data)
    GenerateMipmap(MipmapTarget.TEXTURE_2D)
else:
    echo "Failure to Load Image"

let texture2 = GenTexture()
BindTexture(TextureTarget.TEXTURE_2D,texture2)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_S,GL_REPEAT)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_WRAP_T,GL_REPEAT)

TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)

data = stbi.load("textures/awesomeface.png",width,height,channels,stbi.Default)

if data != nil and data.len != 0:
    TexImage2D(TexImageTarget.TEXTURE_2D,0'i32,TextureInternalFormat.RGB,width.int32,height.int32,PixelDataFormat.RGBA,PixelDataType.UNSIGNED_BYTE,data)
    GenerateMipmap(MipmapTarget.TEXTURE_2D)
else:
    echo "Failure to Load Image"

ourShader.UseProgram()
ourShader.SetInt("texture1",0)
ourShader.SetInt("texture2",1)


var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
  
while run:
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      run = false
      break
    if evt.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(evt))
      if windowEvent.event == WindowEvent_Resized:
        let newWidth = windowEvent.data1
        let newHeight = windowEvent.data2
        glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window
        
  # Render
  ClearColor(0.2,0.3,0.3,1.0)
  Clear(ClearBufferMask.COLOR_BUFFER_BIT)

  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_2D,texture1)
  ActiveTexture(TextureUnit.TEXTURE1)
  BindTexture(TextureTarget.TEXTURE_2D, texture2)
  
  ourShader.UseProgram()
  var view = mat4(1.0'f32)
  var projection = mat4(1.0'f32)
  projection = perspective(radians(45.0'f32),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  view = translate(view,vec3(0.0'f32,0.0'f32,-3.0'f32))
  ourShader.SetMat4("projection",false,projection)
  ourShader.SetMat4("view",false,view)
  BindVertexArray(VAO) # Not necessary since we only have one VAO

  for i in 0 .. <10:
    var model = mat4(1.0'f32)
    model = translate(model,cubePositions[i])
    let angle = 20.0'f32*i.float32
    model = rotate(model,vec3(1.0'f32,0.3'f32,0.5'f32),radians(angle))
    ourShader.SetMat4("model",false,model)
    DrawArrays(DrawMode.TRIANGLES,0,36)
  window.glSwapWindow()

DeleteVertexArray(VAO)
DeleteBuffer(VBO)
destroy window
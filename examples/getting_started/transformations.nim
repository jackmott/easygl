# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import easygl.utils
import stb_image/read as stbi
import glm
import os

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Transformations", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let ourShader = CreateAndLinkProgram(appDir&"/shaders/transformations.vert",appDir&"/shaders/transformations.frag")

# Set up vertex data
let vertices : seq[float32]  = 
  @[   
    # positions                 # texture coords
    0.5'f32,  0.5'f32, 0.0'f32, 1.0'f32, 1.0'f32, # top right
    0.5'f32, -0.5'f32, 0.0'f32, 1.0'f32, 0.0'f32, # bottom right
   -0.5'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, # bottom left
   -0.5'f32,  0.5'f32, 0.0'f32, 0.0'f32, 1.0'f32  # top left 
  ]

let indices : seq[uint32] = 
    @[
        0'u32, 1'u32, 3'u32, # first triangle
        1'u32, 2'u32, 3'u32  # second triangle
    ]

let VAO = GenVertexArray()
let VBO = GenBuffer()
let EBO = GenBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
BindVertexArray(VAO)

BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
BufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)

BindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER,EBO)
BufferData(BufferTarget.ELEMENT_ARRAY_BUFFER,indices,BufferDataUsage.STATIC_DRAW)

VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
EnableVertexAttribArray(0)

VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
EnableVertexAttribArray(1)


let texture1 = LoadTextureWithMips(appDir&"/textures/container.jpg")
let texture2 = LoadTextureWithMips(appDir&"/textures/awesomeface.png")

ourShader.Use()
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
  
  var transform = mat4(1.0'f32)
  transform = translate(transform,vec3(0.5'f32,-0.5'f32,0.0'f32))
  transform = rotate(transform,vec3(0.0'f32,0.0'f32,1.0'f32),getTicks().float32/1000.0'f32)

  ourShader.Use()
  ourShader.SetMat4("transform",transform)

  BindVertexArray(VAO) # Not necessary since we only have one VAO
  DrawElements(DrawMode.TRIANGLES,6,IndexType.UNSIGNED_INT,0)
  window.glSwapWindow()

DeleteVertexArray(VAO)
DeleteBuffer(VBO)
DeleteBuffer(EBO)
destroy window
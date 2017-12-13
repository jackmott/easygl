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

let window = createWindow("Coordinate Systems", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let ourShader = createAndLinkProgram(appDir&"/shaders/coordinate_systems.vert",appDir&"/shaders/coordinate_systems.frag")

enable(Capability.DEPTH_TEST)

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

let VAO = genVertexArray()
let VBO = genBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
bindVertexArray(VAO)

bindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
bufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)

vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(0)

vertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
enableVertexAttribArray(1)

let texture1 = loadTextureWithMips(appDir&"/textures/container.jpg")
let texture2 = loadTextureWithMips(appDir&"/textures/awesomeface.png")

ourShader.use()
ourShader.setInt("texture1",0)
ourShader.setInt("texture2",1)


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
  clearColor(0.2,0.3,0.3,1.0)
  clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

  activeTexture(TextureUnit.TEXTURE0)
  bindTexture(TextureTarget.TEXTURE_2D,texture1)
  activeTexture(TextureUnit.TEXTURE1)
  bindTexture(TextureTarget.TEXTURE_2D, texture2)
  
  ourShader.use()
  var view = mat4(1.0'f32)
  var projection = mat4(1.0'f32)
  projection = perspective(radians(45.0'f32),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  view = translate(view,vec3(0.0'f32,0.0'f32,-3.0'f32))
  ourShader.setMat4("projection",projection)
  ourShader.setMat4("view",view)
  bindVertexArray(VAO) # Not necessary since we only have one VAO

  for i in 0 .. <10:
    var model = mat4(1.0'f32)
    model = translate(model,cubePositions[i])
    let angle = 20.0'f32*i.float32
    model = rotate(model,vec3(1.0'f32,0.3'f32,0.5'f32),radians(angle))
    ourShader.setMat4("model",model)
    drawArrays(DrawMode.TRIANGLES,0,36)
  window.glSwapWindow()

deleteVertexArray(VAO)
deleteBuffer(VBO)
destroy window
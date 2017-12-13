# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import easygl.utils
import os

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Shaders", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let ourShader = createAndLinkProgram(appDir&"/shaders/shaders.vert",appDir&"/shaders/shaders.frag")

# Set up vertex data
let vertices : seq[float32]  = 
  @[   
     0.5'f32, -0.5'f32, 0.0'f32,  1.0'f32, 0.0'f32, 0.0'f32,  # bottom right
    -0.5'f32, -0.5'f32, 0.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,  # bottom left
     0.0'f32,  0.5'f32, 0.0'f32,  0.0'f32, 0.0'f32, 1.0'f32 ] # top left


let VAO = genVertexArray()
let VBO = genBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
bindVertexArray(VAO)

bindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
bufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)

vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),0)
enableVertexAttribArray(0)

vertexAttribPointer(1,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),3*float32.sizeof())
enableVertexAttribArray(1)

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
  clear(BufferMask.COLOR_BUFFER_BIT)
  ourShader.use()
  bindVertexArray(VAO) # Not necessary since we only have one VAO
  drawArrays(DrawMode.TRIANGLES,0,3)
  window.glSwapWindow()

deleteVertexArray(VAO)
deleteBuffer(VBO)
destroy window
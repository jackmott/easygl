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
let ourShader = createAndLinkProgram(appDir&"/shaders/transformations.vert",appDir&"/shaders/transformations.frag")

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

let VAO = genVertexArray()
let VBO = genBuffer()
let EBO = genBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
bindVertexArray(VAO)

bindBuffer(GL_ARRAY_BUFFER,VBO)
bufferData(GL_ARRAY_BUFFER,vertices,GL_STATIC_DRAW)

bindBuffer(GL_ELEMENT_ARRAY_BUFFER,EBO)
bufferData(GL_ELEMENT_ARRAY_BUFFER,indices,GL_STATIC_DRAW)

vertexAttribPointer(0,3,cGL_FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(0)

vertexAttribPointer(1,3,cGL_FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
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
  clear(GL_COLOR_BUFFER_BIT)

  activeTexture(GL_TEXTURE0)
  bindTexture(GL_TEXTURE_2D,texture1)
  activeTexture(GL_TEXTURE1)
  bindTexture(GL_TEXTURE_2D, texture2)
  
  var transform = mat4(1.0'f32)
  transform = translate(transform,vec3(0.5'f32,-0.5'f32,0.0'f32))
  transform = rotate(transform,vec3(0.0'f32,0.0'f32,1.0'f32),getTicks().float32/1000.0'f32)

  ourShader.use()
  ourShader.setMat4("transform",transform)

  bindVertexArray(VAO) # Not necessary since we only have one VAO
  drawElements(GL_TRIANGLES,6,GL_UNSIGNED_INT,0)
  window.glSwapWindow()

deleteVertexArray(VAO)
deleteBuffer(VBO)
deleteBuffer(EBO)
destroy window
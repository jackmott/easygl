# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import stb_image/read as stbi
import glm
import ../utils/camera_util
import times
import os
import easygl.utils

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Colors", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let lightingShader = createAndLinkProgram(appDir&"/shaders/colors.vert",appDir&"/shaders/colors.frag")
let lampShader = createAndLinkProgram(appDir&"/shaders/color.vert",appDir&"/shaders/lamp.frag")


enable(GL_DEPTH_TEST)

# Set up vertex data
let vertices : seq[float32]  =
  @[
    # positions                 # texture coords
    -0.5'f32, -0.5'f32, -0.5'f32,
    0.5'f32, -0.5'f32, -0.5'f32,
    0.5'f32,  0.5'f32, -0.5'f32,
    0.5'f32,  0.5'f32, -0.5'f32,
   -0.5'f32,  0.5'f32, -0.5'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,

   -0.5'f32, -0.5'f32,  0.5'f32,
    0.5'f32, -0.5'f32,  0.5'f32,
    0.5'f32,  0.5'f32,  0.5'f32,
    0.5'f32,  0.5'f32,  0.5'f32,
   -0.5'f32,  0.5'f32,  0.5'f32,
   -0.5'f32, -0.5'f32,  0.5'f32,

   -0.5'f32,  0.5'f32,  0.5'f32,
   -0.5'f32,  0.5'f32, -0.5'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,
   -0.5'f32, -0.5'f32,  0.5'f32,
   -0.5'f32,  0.5'f32,  0.5'f32,

    0.5'f32,  0.5'f32,  0.5'f32,
    0.5'f32,  0.5'f32, -0.5'f32,
    0.5'f32, -0.5'f32, -0.5'f32,
    0.5'f32, -0.5'f32, -0.5'f32,
    0.5'f32, -0.5'f32,  0.5'f32,
    0.5'f32,  0.5'f32,  0.5'f32,

   -0.5'f32, -0.5'f32, -0.5'f32,
    0.5'f32, -0.5'f32, -0.5'f32,
    0.5'f32, -0.5'f32,  0.5'f32,
    0.5'f32, -0.5'f32,  0.5'f32,
   -0.5'f32, -0.5'f32,  0.5'f32,
   -0.5'f32, -0.5'f32, -0.5'f32,

   -0.5'f32,  0.5'f32, -0.5'f32,
    0.5'f32,  0.5'f32, -0.5'f32,
    0.5'f32,  0.5'f32,  0.5'f32,
    0.5'f32,  0.5'f32,  0.5'f32,
   -0.5'f32,  0.5'f32,  0.5'f32,
   -0.5'f32,  0.5'f32, -0.5'f32]

let cubeVAO = genVertexArray()
let VBO = genBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
bindBuffer(GL_ARRAY_BUFFER,VBO)
bufferData(GL_ARRAY_BUFFER,vertices,GL_STATIC_DRAW)

bindVertexArray(cubeVAO)

vertexAttribPointer(0,3,cGL_FLOAT,false,3*float32.sizeof(),0)
enableVertexAttribArray(0)

let lightVAO = genVertexArray()
bindVertexArray(lightVAO)
bindBuffer(GL_ARRAY_BUFFER,VBO)
vertexAttribPointer(0,3,cGL_FLOAT,false,3*float32.sizeof(),0)
enableVertexAttribArray(0)

let lightPos = vec3(1.2'f32,1.0'f32,2.0'f32)
var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,9.0'f32))

var currentTime,prevTime:float
prevTime=epochTime()
while run:  
  currentTime = epochTime()
  let keyState = getKeyboardState()
  let elapsedTime = (currentTime - prevTime).float32*10.0'f32
  prevTime = currentTime
  while pollEvent(evt):
    case evt.kind
        of QuitEvent:
            run = false
        of WindowEvent:
            var windowEvent = cast[WindowEventPtr](addr(evt))
            if windowEvent.event == WindowEvent_Resized:
                let newWidth = windowEvent.data1
                let newHeight = windowEvent.data2
                glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window     
        of MouseWheel:
            var wheelEvent = cast[MouseWheelEventPtr](addr(evt))
            camera.processMouseScroll(wheelEvent.y.float32)
        of MouseMotion:
            var motionEvent = cast[MouseMotionEventPtr](addr(evt))
            camera.processMouseMovement(motionEvent.xrel.float32,motionEvent.yrel.float32)
        else:
            discard
             

  if keyState[SDL_SCANCODE_W.uint8] != 0:
    camera.processKeyboard(FORWARD,elapsedTime)
  if keyState[SDL_SCANCODE_S.uint8] != 0:
    camera.processKeyBoard(BACKWARD,elapsedTime)
  if keyState[SDL_SCANCODE_A.uint8] != 0:
    camera.processKeyBoard(LEFT,elapsedTime)
  if keyState[SDL_SCANCODE_D.uint8] != 0:
    camera.processKeyBoard(RIGHT,elapsedTime)
  if keyState[SDL_SCANCODE_ESCAPE.uint8] != 0:
    break

  # Render
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

 
  lightingShader.use()
  lightingShader.setVec3("objectColor",1.0'f32,0.5'f32,0.31'f32)
  lightingShader.setVec3("lightColor",1.0'f32,1.0'f32,1.0'f32)

  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  var view = camera.getViewMatrix()

  lightingShader.setMat4("projection",projection)
  lightingShader.setMat4("view",view)
  
  var model = mat4(1.0'f32)
  lightingShader.setMat4("model",model)

  bindVertexArray(cubeVAO)
  drawArrays(GL_TRIANGLES,0,36)
  
  lampShader.use()
  lampShader.setMat4("projection",projection)
  lampShader.setMat4("view",view)

  model = translate(model,lightPos)
  model = scale(model,vec3(0.2'f32))
  lampShader.setMat4("model",model)
  bindVertexArray(lightVao)
  drawArrays(GL_TRIANGLES,0,36)

  window.glSwapWindow()

deleteVertexArray(cubeVAO)
deleteVertexArray(lightVAO)
deleteBuffer(VBO)
destroy window

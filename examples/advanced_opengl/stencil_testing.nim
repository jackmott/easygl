
# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import stb_image/read as stbi
import glm
import ../utils/camera_util
import times
import os
import easygl/utils

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 1280
var screenHeight: cint = 720

 ### IMPORTANT! - unlike glfw used by LearnOpenGL - SDL2 requies you to explicitly 
 ### create a stencil buffer like so:
discard glSetAttribute(SDL_GL_STENCIL_SIZE,8)

let window = createWindow("Float", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()
enable(GL_DEPTH_TEST)
depthFunc(GL_LESS)
enable(GL_STENCIL_TEST)
stencilOp(GL_KEEP,GL_KEEP,GL_REPLACE)
stencilFunc(GL_NOTEQUAL,1,0xFF)


### Build and compile shader program
let appDir = getAppDir()
let shader = createAndLinkProgram(appDir&"/shaders/stencil_testing.vert",appDir&"/shaders/stencil_testing.frag")
let shaderSingleColor = createAndLinkProgram(appDir&"/shaders/stencil_testing.vert",appDir&"/shaders/stencil_single_color.frag")


# Set up vertex data
let cubeVertices  =
  @[
    # positions                 

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

let planeVertices = 
    @[
         5.0'f32, -0.5'f32,  5.0'f32,  2.0'f32, 0.0'f32,
        -5.0'f32, -0.5'f32,  5.0'f32,  0.0'f32, 0.0'f32,
        -5.0'f32, -0.5'f32, -5.0'f32,  0.0'f32, 2.0'f32,

         5.0'f32, -0.5'f32,  5.0'f32,  2.0'f32, 0.0'f32,
        -5.0'f32, -0.5'f32, -5.0'f32,  0.0'f32, 2.0'f32,
         5.0'f32, -0.5'f32, -5.0'f32,  2.0'f32, 2.0'f32
    ]
    
# Cube
let cubeVAO = genBindVertexArray()
let cubeVBO = genBindBufferData(GL_ARRAY_BUFFER,cubeVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,cGL_FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,cGL_FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
unBindVertexArray()

# Plane
let planeVAO = genBindVertexArray()
let planeVBO = genBindBufferData(GL_ARRAY_BUFFER,planeVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,cGL_FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,cGL_FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
unBindVertexArray()

let cubeTexture = loadTextureWithMips(appDir&"/textures/marble.jpg")
let floorTexture = loadTextureWithMips(appDir&"/textures/metal.png")

shader.use()
shader.setInt("texture1",0)

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,4.0'f32))

var currentTime,prevTime:float
prevTime=epochTime()

while run:
  
  let error = getGLError()
  if (error != GL_NO_ERROR):
    echo "Error:" & $error.int32

  let keyState = getKeyboardState()
  currentTime = epochTime()
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
  
  stencilMask(0xFF)
  easygl.clear(GL_COLOR_BUFFER_BIT or
         GL_DEPTH_BUFFER_BIT or
         GL_STENCIL_BUFFER_BIT)
  

  shaderSingleColor.use()
  var model = mat4(1.0'f32)    
  var view = camera.getViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shaderSingleColor.setMat4("view",view)
  shaderSingleColor.setMat4("projection",projection)
 
  shader.use()  
  shader.setMat4("view",view)
  shader.setMat4("projection",projection)

  # dont write to stencil when drawing floor    
  stencilMask(0x00)
  # floor  
  bindVertexArray(planeVAO)  
  bindTexture(GL_TEXTURE_2D,floorTexture)  
  shader.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,6)
  unBindVertexArray()

  # 1st. render pass, draw objects as normal, writing to the stencil buffer
  # --------------------------------------------------------------------
  stencilFunc(GL_ALWAYS,1,0xFF)
  stencilMask(0xFF)
  # cubes
  bindVertexArray(cubeVAO)
  activeTexture(GL_TEXTURE0)
  bindTexture(GL_TEXTURE_2D, cubeTexture)
  model = translate(model,vec3(-1.0'f32,0.0'f32,-1.0'f32))
  shader.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)
  model = mat4(1.0'f32)
  model = translate(model,vec3(2.0'f32,0.0'f32,0.0'f32))
  shader.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)

  # 2nd. render pass: now draw slightly scaled versions of the objects, this time disabling stencil writing.
  # Because the stencil buffer is now filled with several 1s. The parts of the buffer that are 1 are not drawn, thus only drawing 
  # the objects' size differences, making it look like borders.
  # -----------------------------------------------------------------------------------------------------------------------------
  stencilFunc(GL_NOTEQUAL,1,0xFF)
  stencilMask(0x00)
  disable(GL_DEPTH_TEST)
  shaderSingleColor.use()
  let scale = 1.1'f32
  # cubes
  bindVertexArray(cubeVAO)  
  bindTexture(GL_TEXTURE_2D, cubeTexture)
  model = mat4(1.0'f32)
  model = translate(model,vec3(-1.0'f32,0.0'f32,-1.0'f32))
  model = scale(model,vec3(scale,scale,scale))
  shaderSingleColor.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)
  model = mat4(1.0'f32)
  model = translate(model,vec3(2.0'f32,0.0'f32,0.0'f32))
  model = scale(model,vec3(scale,scale,scale))
  shaderSingleColor.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)  
  unBindVertexArray()
  stencilMask(0xFF)
  enable(GL_DEPTH_TEST)
  
  window.glSwapWindow()

deleteVertexArray(cubeVAO)
deleteVertexArray(planeVAO)
deleteBuffer(cubeVBO)
deleteBuffer(planeVBO)
destroy window

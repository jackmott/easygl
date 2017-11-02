
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
Enable(Capability.DEPTH_TEST)
DepthFunc(AlphaFunc.LESS)
Enable(Capability.STENCIL_TEST)
StencilOp(StencilOpEnum.KEEP,StencilOpEnum.KEEP,StencilOpEnum.REPLACE)
StencilFunc(AlphaFunc.NOTEQUAL,1,0xFF)


### Build and compile shader program
let appDir = getAppDir()
let shader = CreateAndLinkProgram(appDir&"/shaders/stencil_testing.vert",appDir&"/shaders/stencil_testing.frag")
let shaderSingleColor = CreateAndLinkProgram(appDir&"/shaders/stencil_testing.vert",appDir&"/shaders/stencil_single_color.frag")


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
let cubeVAO = GenBindVertexArray()
let cubeVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,cubeVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
UnBindVertexArray()

# Plane
let planeVAO = GenBindVertexArray()
let planeVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,planeVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
UnBindVertexArray()

let cubeTexture = LoadTextureWithMips(appDir&"/textures/marble.jpg")
let floorTexture = LoadTextureWithMips(appDir&"/textures/metal.png")

shader.Use()
shader.SetInt("texture1",0)

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,4.0'f32))

var currentTime,prevTime:float
prevTime=epochTime()

while run:
  
  let error = GetGLError()
  if (error != ErrorType.NO_ERROR):
    echo "Error:" & $error

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
            camera.ProcessMouseScroll(wheelEvent.y.float32)
        of MouseMotion:
            var motionEvent = cast[MouseMotionEventPtr](addr(evt))
            camera.ProcessMouseMovement(motionEvent.xrel.float32,motionEvent.yrel.float32)
        else:
            discard
             
  if keyState[SDL_SCANCODE_W.uint8] != 0:
    camera.ProcessKeyboard(FORWARD,elapsedTime)
  if keyState[SDL_SCANCODE_S.uint8] != 0:
    camera.ProcessKeyBoard(BACKWARD,elapsedTime)
  if keyState[SDL_SCANCODE_A.uint8] != 0:
    camera.ProcessKeyBoard(LEFT,elapsedTime)
  if keyState[SDL_SCANCODE_D.uint8] != 0:
    camera.ProcessKeyBoard(RIGHT,elapsedTime)
  if keyState[SDL_SCANCODE_ESCAPE.uint8] != 0:
    break
  # Render  
  
  ClearColor(0.1,0.1,0.1,1.0)
  
  StencilMask(0xFF)
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, 
         BufferMask.DEPTH_BUFFER_BIT,
         BufferMask.STENCIL_BUFFER_BIT)
  

  shaderSingleColor.Use()
  var model = mat4(1.0'f32)    
  var view = camera.GetViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shaderSingleColor.SetMat4("view",view)
  shaderSingleColor.SetMat4("projection",projection)
 
  shader.Use()  
  shader.SetMat4("view",view)
  shader.SetMat4("projection",projection)

  # dont write to stencil when drawing floor    
  StencilMask(0x00)
  # floor  
  BindVertexArray(planeVAO)  
  BindTexture(TextureTarget.TEXTURE_2D,floorTexture)  
  shader.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,6)
  UnBindVertexArray()

  # 1st. render pass, draw objects as normal, writing to the stencil buffer
  # --------------------------------------------------------------------
  StencilFunc(AlphaFunc.ALWAYS,1,0xFF)
  StencilMask(0xFF)
  # cubes
  BindVertexArray(cubeVAO)
  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_2D, cubeTexture)
  model = translate(model,vec3(-1.0'f32,0.0'f32,-1.0'f32))
  shader.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)
  model = mat4(1.0'f32)
  model = translate(model,vec3(2.0'f32,0.0'f32,0.0'f32))
  shader.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)

  # 2nd. render pass: now draw slightly scaled versions of the objects, this time disabling stencil writing.
  # Because the stencil buffer is now filled with several 1s. The parts of the buffer that are 1 are not drawn, thus only drawing 
  # the objects' size differences, making it look like borders.
  # -----------------------------------------------------------------------------------------------------------------------------
  StencilFunc(AlphaFunc.NOTEQUAL,1,0xFF)
  StencilMask(0x00)
  Disable(Capability.DEPTH_TEST)
  shaderSingleColor.Use()
  let scale = 1.1'f32
  # cubes
  BindVertexArray(cubeVAO)  
  BindTexture(TextureTarget.TEXTURE_2D, cubeTexture)
  model = mat4(1.0'f32)
  model = translate(model,vec3(-1.0'f32,0.0'f32,-1.0'f32))
  model = scale(model,vec3(scale,scale,scale))
  shaderSingleColor.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)
  model = mat4(1.0'f32)
  model = translate(model,vec3(2.0'f32,0.0'f32,0.0'f32))
  model = scale(model,vec3(scale,scale,scale))
  shaderSingleColor.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)  
  UnBindVertexArray()
  StencilMask(0xFF)
  Enable(Capability.DEPTH_TEST)
  
  window.glSwapWindow()

DeleteVertexArray(cubeVAO)
DeleteVertexArray(planeVAO)
DeleteBuffer(cubeVBO)
DeleteBuffer(planeVBO)
destroy window

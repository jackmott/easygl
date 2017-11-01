
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
import algorithm

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 1280
var screenHeight: cint = 720

let window = createWindow("Float", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()
Enable(Capability.DEPTH_TEST)
### Build and compile shader program
let appDir = getAppDir()
let shader = CreateAndLinkProgram(appDir&"/shaders/framebuffers.vert",appDir&"/shaders/framebuffers.frag")
let screenShader = CreateAndLinkProgram(appDir&"/shaders/framebuffers_screen.vert",appDir&"/shaders/framebuffers_screen.frag")


# Set up vertex data
let cubeVertices  =
  @[
    # positions                    #tex coords

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
    @[   # positions                   #tex coords
         5.0'f32, -0.5'f32,  5.0'f32,  2.0'f32, 0.0'f32,
        -5.0'f32, -0.5'f32,  5.0'f32,  0.0'f32, 0.0'f32,
        -5.0'f32, -0.5'f32, -5.0'f32,  0.0'f32, 2.0'f32,

         5.0'f32, -0.5'f32,  5.0'f32,  2.0'f32, 0.0'f32,
        -5.0'f32, -0.5'f32, -5.0'f32,  0.0'f32, 2.0'f32,
         5.0'f32, -0.5'f32, -5.0'f32,  2.0'f32, 2.0'f32
    ]

let quadVertices = 
  @[ # positions         #tex coords
    -1.0'f32,  1.0'f32,  0.0'f32, 1.0'f32,
    -1.0'f32, -1.0'f32,  0.0'f32, 0.0'f32,
     1.0'f32, -1.0'f32,  1.0'f32, 0.0'f32,

    -1.0'f32,  1.0'f32,  0.0'f32, 1.0'f32,
     1.0'f32, -1.0'f32,  1.0'f32, 0.0'f32,
     1.0'f32,  1.0'f32,  1.0'f32, 1.0'f32
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


# screen quad VAO
let quadVAO = GenBindVertexArray()
let quadVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,quadVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,2,VertexAttribType.FLOAT,false,4*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,2,VertexAttribType.FLOAT,false,4*float32.sizeof(),2*float32.sizeof())

let cubeTexture = LoadTextureWithMips(appDir&"/textures/container.jpg")
let floorTexture = LoadTextureWithMips(appDir&"/textures/metal.png")

shader.Use()
shader.SetInt("texture1",0)

screenShader.Use()
screenShader.SetInt("screenTexture",0)

# framebuffer config
let framebuffer = GenBindFramebuffer(FramebufferTarget.FRAMEBUFFER)
let textureColorbuffer = GenBindTexture(TextureTarget.TEXTURE_2D)
TexImage2D(TexImageTarget.TEXTURE_2D,0'i32,TextureInternalFormat.RGB,screenWidth.int32,screenHeight.int32,PixelDataFormat.RGB,PixelDataType.UNSIGNED_BYTE)
TexParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
TexParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)
FramebufferTexture2D(FramebufferTarget.FRAMEBUFFER,FramebufferAttachment.COLOR_ATTACHMENT0,FramebufferTextureTarget.TEXTURE_2D,textureColorbuffer,0)

# create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
let rbo = GenBindRenderBuffer()
RenderBufferSTorage(RenderBufferFormat.DEPTH24_STENCIL8,screenWidth,screenHeight)
FramebufferRenderbuffer(FramebufferTarget.FRAMEBUFFER,FramebufferAttachment.DEPTH_STENCIL_ATTACHMENT,rbo)
# now that we actually created the framebuffer and added all attachments we want to check if it is actually complete now
if CheckFramebufferStatus(FramebufferTarget.FRAMEBUFFER) != FrameBufferStatus.FRAMEBUFFER_COMPLETE:
  echo "error: framebuffer is not complete"
UnbindFramebuffer(FramebufferTarget.FRAMEBUFFER)

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
  # ------
  # bind to framebuffer and draw scene as we normally would to color texture 
  BindFramebuffer(FramebufferTarget.FRAMEBUFFER,framebuffer)
  Enable(Capability.DEPTH_TEST)      
 
  # make sure we clear the framebuffer's content
  ClearColor(0.1,0.1,0.1,1.0)    
  easygl.Clear(ClearBufferMask.COLOR_BUFFER_BIT, 
               ClearBufferMask.DEPTH_BUFFER_BIT)
  

  shader.Use()
  var model = mat4(1.0'f32)    
  var view = camera.GetViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shader.SetMat4("view",view)
  shader.SetMat4("projection",projection)


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
 
  # floor  
  BindVertexArray(planeVAO)  
  BindTexture(TextureTarget.TEXTURE_2D,floorTexture)  
  shader.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,6)
    
  # now bind back to default framebuffer and draw a quad plane with the attached framebuffer color texture
  UnbindFramebuffer(FramebufferTarget.FRAMEBUFFER)
  Disable(Capability.DEPTH_TEST) # disable depth test so screen-space quad isn't discarded due to depth test.
  # clear all relevant buffers
  ClearColor(1.0,1.0,1.0,1.0) # set clear color to white (not really necessery actually, since we won't be able to see behind the quad anyways)  
  easygl.Clear(ClearBufferMask.COLOR_BUFFER_BIT) 

  screenShader.Use()
  BindVertexArray(quadVAO)
  BindTexture(TextureTarget.TEXTURE_2D,textureColorBuffer)
  DrawArrays(DrawMode.TRIANGLES,0,6)

  window.glSwapWindow()


destroy window

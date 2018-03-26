
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
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()
enable(GL_DEPTH_TEST)
### Build and compile shader program
let appDir = getAppDir()
let shader = createAndLinkProgram(appDir&"/shaders/framebuffers.vert",appDir&"/shaders/framebuffers.frag")
let screenShader = createAndLinkProgram(appDir&"/shaders/framebuffers_screen.vert",appDir&"/shaders/framebuffers_screen.frag")


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


# screen quad VAO
let quadVAO = genBindVertexArray()
let quadVBO = genBindBufferData(GL_ARRAY_BUFFER,quadVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,2,cGL_FLOAT,false,4*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,cGL_FLOAT,false,4*float32.sizeof(),2*float32.sizeof())

let cubeTexture = loadTextureWithMips(appDir&"/textures/container.jpg")
let floorTexture = loadTextureWithMips(appDir&"/textures/metal.png")

shader.use()
shader.setInt("texture1",0)

screenShader.use()
screenShader.setInt("screenTexture",0)

# framebuffer config
let framebuffer = genBindFramebuffer(GL_FRAMEBUFFER)
let textureColorbuffer = genBindTexture(GL_TEXTURE_2D)
texImage2D(GL_TEXTURE_2D,0'i32,GL_RGB,screenWidth.int32,screenHeight.int32,GL_RGB,GL_UNSIGNED_BYTE)
texParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR)
texParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR)
framebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,textureColorbuffer,0)

# create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
let rbo = genBindRenderBuffer()
renderBufferStorage(GL_DEPTH24_STENCIL8,screenWidth,screenHeight)
framebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_STENCIL_ATTACHMENT,rbo)
# now that we actually created the framebuffer and added all attachments we want to check if it is actually complete now
if checkFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE:
  echo "error: framebuffer is not complete"
unBindFramebuffer(GL_FRAMEBUFFER)

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
  # ------
  # bind to framebuffer and draw scene as we normally would to color texture 
  bindFramebuffer(GL_FRAMEBUFFER,framebuffer)
  enable(GL_DEPTH_TEST)      
 
  # make sure we clear the framebuffer's content
  clearColor(0.1,0.1,0.1,1.0)    
  easygl.clear(GL_COLOR_BUFFER_BIT or
               GL_DEPTH_BUFFER_BIT)
  

  shader.use()
  var model = mat4(1.0'f32)    
  var view = camera.getViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shader.setMat4("view",view)
  shader.setMat4("projection",projection)


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
 
  # floor  
  bindVertexArray(planeVAO)  
  bindTexture(GL_TEXTURE_2D,floorTexture)  
  shader.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,6)
    
  # now bind back to default framebuffer and draw a quad plane with the attached framebuffer color texture
  unBindFramebuffer(GL_FRAMEBUFFER)
  disable(GL_DEPTH_TEST) # disable depth test so screen-space quad isn't discarded due to depth test.
  # clear all relevant buffers
  clearColor(1.0,1.0,1.0,1.0) # set clear color to white (not really necessery actually, since we won't be able to see behind the quad anyways)  
  easygl.clear(GL_COLOR_BUFFER_BIT) 

  screenShader.use()
  bindVertexArray(quadVAO)
  bindTexture(GL_TEXTURE_2D,textureColorBuffer)
  drawArrays(GL_TRIANGLES,0,6)

  window.glSwapWindow()


destroy window

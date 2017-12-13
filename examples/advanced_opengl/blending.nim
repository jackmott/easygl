
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
enable(Capability.DEPTH_TEST)
enable(Capability.BLEND)
blendFunc(BlendFactor.SRC_ALPHA,BlendFactor.ONE_MINUS_SRC_ALPHA)


### Build and compile shader program
let appDir = getAppDir()
let shader = createAndLinkProgram(appDir&"/shaders/blending.vert",appDir&"/shaders/blending.frag")


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

let transparentVertices = 
  @[
    0.0'f32,  0.5'f32,  0.0'f32,  0.0'f32,  0.0'f32,
    0.0'f32, -0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,
    1.0'f32, -0.5'f32,  0.0'f32,  1.0'f32,  1.0'f32,

    0.0'f32,  0.5'f32,  0.0'f32,  0.0'f32,  0.0'f32,
    1.0'f32, -0.5'f32,  0.0'f32,  1.0'f32,  1.0'f32,
    1.0'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32
  ]
    
# Cube
let cubeVAO = genBindVertexArray()
let cubeVBO = genBindBufferData(BufferTarget.ARRAY_BUFFER,cubeVertices,BufferDataUsage.STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
unBindVertexArray()

# Plane
let planeVAO = genBindVertexArray()
let planeVBO = genBindBufferData(BufferTarget.ARRAY_BUFFER,planeVertices,BufferDataUsage.STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())


# Transparent VAO
let transparentVAO = genBindVertexArray()
let transparentVBO = genBindBufferData(BufferTarget.ARRAY_BUFFER,transparentVertices,BufferDataUsage.STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
unBindVertexArray()


let cubeTexture = loadTextureWithMips(appDir&"/textures/marble.jpg")
let floorTexture = loadTextureWithMips(appDir&"/textures/metal.png")
let transparentTexture = loadTextureWithMips(appDir&"/textures/window.png")

var windows :seq[Vec3f] = @[
  vec3(-1.5'f32,0.0'f32,-0.48'f32),
  vec3(1.5'f32,0.0'f32,0.51'f32),
  vec3(0.0'f32,0.0'f32,0.7'f32),
  vec3(-0.3'f32,0.0'f32,-2.3'f32),
  vec3(-0.5'f32,0.0'f32,0.6'f32)
]

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
  easygl.clear(BufferMask.COLOR_BUFFER_BIT, 
         BufferMask.DEPTH_BUFFER_BIT)
  

  shader.use()
  var model = mat4(1.0'f32)    
  var view = camera.getViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shader.setMat4("view",view)
  shader.setMat4("projection",projection)


  # cubes
  bindVertexArray(cubeVAO)
  activeTexture(TextureUnit.TEXTURE0)
  bindTexture(TextureTarget.TEXTURE_2D, cubeTexture)
  model = translate(model,vec3(-1.0'f32,0.0'f32,-1.0'f32))
  shader.setMat4("model",model)
  drawArrays(DrawMode.TRIANGLES,0,36)
  model = mat4(1.0'f32)
  model = translate(model,vec3(2.0'f32,0.0'f32,0.0'f32))
  shader.setMat4("model",model)
  drawArrays(DrawMode.TRIANGLES,0,36)
 
  # floor  
  bindVertexArray(planeVAO)  
  bindTexture(TextureTarget.TEXTURE_2D,floorTexture)  
  shader.setMat4("model",model)
  drawArrays(DrawMode.TRIANGLES,0,6)
    
  # windows
  bindVertexArray(transparentVAO)
  bindTexture(TextureTarget.TEXTURE_2D,transparentTexture)

  # we use a less verbose method of sorting vs learnOpenGL
  windows.sort(proc(a,b:Vec3f) : int =            
    # Compute squared distance which is faster and sufficient
    let aDistSq = dot(a-camera.Position,a-camera.Position)
    let bDistSq = dot(b-camera.Position,b-camera.Position)
    # reverse order
    cmp(bDistSq,aDistSq)
    )
    
  for w in windows:
    model = mat4(1.0'f32)
    model = translate(model,w)
    shader.setMat4("model",model)
    drawArrays(DrawMode.TRIANGLES,0,6)
    
  window.glSwapWindow()


destroy window

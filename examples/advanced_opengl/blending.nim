
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
Enable(Capability.BLEND)
BlendFunc(BlendFactor.SRC_ALPHA,BlendFactor.ONE_MINUS_SRC_ALPHA)


### Build and compile shader program
let appDir = getAppDir()
let shader = CreateAndLinkProgram(appDir&"/shaders/blending.vert",appDir&"/shaders/blending.frag")


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


# Transparent VAO
let transparentVAO = GenBindVertexArray()
let transparentVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,transparentVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),3*float32.sizeof())
UnbindVertexArray()


let cubeTexture = LoadTextureWithMips(appDir&"/textures/marble.jpg")
let floorTexture = LoadTextureWithMips(appDir&"/textures/metal.png")
let transparentTexture = LoadTextureWithMips(appDir&"/textures/window.png")

var windows :seq[Vec3f] = @[
  vec3(-1.5'f32,0.0'f32,-0.48'f32),
  vec3(1.5'f32,0.0'f32,0.51'f32),
  vec3(0.0'f32,0.0'f32,0.7'f32),
  vec3(-0.3'f32,0.0'f32,-2.3'f32),
  vec3(-0.5'f32,0.0'f32,0.6'f32)
]

shader.Use()
shader.SetInt("texture1",0)

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,4.0'f32))

var currentTime,prevTime:float
prevTime=cpuTime()

while run:
  
  let error = GetGLError()
  if (error != ErrorType.NO_ERROR):
    echo "Error:" & $error

  let keyState = getKeyboardState()
  currentTime = cpuTime()
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
    
  # windows
  BindVertexArray(transparentVAO)
  BindTexture(TextureTarget.TEXTURE_2D,transparentTexture)

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
    shader.SetMat4("model",model)
    DrawArrays(DrawMode.TRIANGLES,0,6)
    
  window.glSwapWindow()


destroy window

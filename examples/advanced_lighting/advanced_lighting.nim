# OpenGL example using SDL2

import 
    sdl2,
    opengl,
    easygl,
    easygl.utils,
    stb_image/read as stbi,
    glm,
   ../utils/camera_util,
   times,
   os
  
discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 1280
var screenHeight: cint = 720
var blinn = false
var blinnKeyPress = false;

let window = createWindow("Float", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()


Enable(Capability.DEPTH_TEST)
Enable(Capability.BLEND)
BlendFunc(BlendFactor.SRC_ALPHA,BlendFactor.ONE_MINUS_SRC_ALPHA)


### Build and compile shader program
let appDir = getAppDir()
let shader = CreateAndLinkProgram(appDir&"/shaders/advanced_lighting.vert",appDir&"/shaders/advanced_lighting.frag")



# Set up vertex data
let planeVertices : seq[float32]  = 
  @[   
     # positions                     #normals                    # texcoords
     10.0'f32, -0.5'f32,  10.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,  10.0'f32,  0.0'f32,
    -10.0'f32, -0.5'f32,  10.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,   0.0'f32,  0.0'f32,
    -10.0'f32, -0.5'f32, -10.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,   0.0'f32, 10.0'f32,

     10.0'f32, -0.5'f32,  10.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,  10.0'f32,  0.0'f32,
    -10.0'f32, -0.5'f32, -10.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,   0.0'f32, 10.0'f32,
     10.0'f32, -0.5'f32, -10.0'f32,  0.0'f32, 1.0'f32, 0.0'f32,  10.0'f32, 10.0'f32]

let planeVAO = GenBindVertexArray()
let planeVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,planeVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,8*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,8*float32.sizeof(),3*float32.sizeof())
EnableVertexAttribArray(2)
VertexAttribPointer(2,2,VertexAttribType.FLOAT,false,8*float32.sizeof(),6*float32.sizeof())
UnbindVertexArray()

let floorTexture = LoadTextureWithMips(appDir&"/textures/wood.png")

var lightPos = vec3(0.0'f32,0.0'f32,0.0'f32)

shader.Use()
shader.SetInt("texture1",0)

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,3.0'f32))

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


  # toggle blinn
  if keyState[SDL_SCANCODE_B.uint8] != 0:
    blinnKeyPress = true 
  else:
    if blinnKeyPress:
        blinn = not blinn
        echo "Blinn:" & $blinn
        blinnKeyPress = false
    
  

  let error = GetGLError()
  if error != ErrorType.NO_ERROR:
    echo $error

  # Render
  ClearColor(0.1,0.1,0.1,1.0)
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

  

  shader.Use()
  var projection = perspective(radians(camera.Zoom), screenWidth.float32 / screenHeight.float32,0.1'f32,1000.0'f32)
  var view = camera.GetViewMatrix()
  
  shader.SetMat4("projection",projection)
  shader.SetMat4("view",view)
  # set light uniforms  
  shader.SetVec3("viewPos",camera.Position)
  shader.SetVec3("lightPos",lightPos)
  shader.SetInt("blinn", if blinn: 1 else: 0)

  # floor
  BindVertexArray(planeVAO)
  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_2D,floorTexture)
  DrawArrays(DrawMode.Triangles,0,6)

   
  

  window.glSwapWindow()


destroy window
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

let window = createWindow("Float", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

Enable(Capability.DEPTH_TEST)


### Build and compile shader program
let appDir = getAppDir()
let shader = CreateAndLinkProgram(appDir&"/shaders/geometry_shader.vert",appDir&"/shaders/geometry_shader.frag",appDir&"/shaders/geometry_shader.geom")

let points = @[
  -0.5'f32,  0.5'f32, 1.0'f32, 0.0'f32, 0.0'f32, # top-left
  0.5'f32,  0.5'f32, 0.0'f32, 1.0'f32, 0.0'f32,  # top-right
  0.5'f32, -0.5'f32, 0.0'f32, 0.0'f32, 1.0'f32,  # bottom-right
 -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 0.0f      # bottom-left
]



# cube VAO
let VBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,points,BufferDataUsage.STATIC_DRAW)
let VAO = GenBindVertexArray()
EnableVertexAttribArray(0)
VertexAttribPointer(0,2,VertexAttribType.FLOAT,false,5*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,2*float32.sizeof(),0)
UnbindVertexArray()

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

  let error = GetGLError()
  if error != ErrorType.NO_ERROR:
    echo $error

  # Render
  ClearColor(0.1,0.1,0.1,1.0)
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

  shader.Use()
  BindVertexArray(VAO)
  DrawArrays(DrawMode.POINTS,0,4)
      
  window.glSwapWindow()


destroy window
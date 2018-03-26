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

enable(GL_DEPTH_TEST)


### Build and compile shader program
let appDir = getAppDir()
let shader = createAndLinkProgram(appDir&"/shaders/geometry_shader.vert",appDir&"/shaders/geometry_shader.frag",appDir&"/shaders/geometry_shader.geom")

let points = @[
  -0.5'f32,  0.5'f32, 1.0'f32, 0.0'f32, 0.0'f32, # top-left
  0.5'f32,  0.5'f32, 0.0'f32, 1.0'f32, 0.0'f32,  # top-right
  0.5'f32, -0.5'f32, 0.0'f32, 0.0'f32, 1.0'f32,  # bottom-right
 -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 0.0f      # bottom-left
]



# cube VAO
let VBO = genBindBufferData(GL_ARRAY_BUFFER,points,GL_STATIC_DRAW)
let VAO = genBindVertexArray()
enableVertexAttribArray(0)
vertexAttribPointer(0,2,cGL_FLOAT,false,5*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,3,cGL_FLOAT,false,2*float32.sizeof(),0)
unBindVertexArray()

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

  let error = getGLError()
  if error != GL_NO_ERROR:
    echo $error.int32

  # Render
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  shader.use()
  bindVertexArray(VAO)
  drawArrays(GL_POINTS,0,4)
      
  window.glSwapWindow()


destroy window
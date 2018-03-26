
# OpenGL example using SDL2

import 
  sdl2,
  opengl,
  easygl,
  easygl.utils,
  easygl.model,
  stb_image/read as stbi,
  glm,
  ../utils/camera_util,
  times,
  os

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Model Loading", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let ourShader = createAndLinkProgram(appDir&"/shaders/model_loading.vert",appDir&"/shaders/model_loading.frag")
let ourModel = loadModel(appDir&"/models/nanosuit.obj")

#PolygonMode(PolygonFace.FRONT_AND_BACK,PolygonModeEnum.LINE)

enable(GL_DEPTH_TEST)

# Set up vertex data

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,3.0'f32))

var currentTime,prevTime:float
prevTime=epochTime()
while run:
  let keystate = getKeyboardState()
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
  clearColor(0.05,0.05,0.05,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

 
  ourShader.use()  
  

  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  var view = camera.getViewMatrix()
  ourShader.setMat4("projection",projection)
  ourShader.setMat4("view",view)
  
  var model = mat4(1.0'f32)
  model = translate(model,vec3(0.0'f32,-1.75'f32,0.0'f32))
  model = scale(model,vec3(0.2'f32,0.2'f32,0.2'f32))  
  ourShader.setMat4("model",model)
  ourModel.draw(ourShader)

  
  window.glSwapWindow()

destroy window

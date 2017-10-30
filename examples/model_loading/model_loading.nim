
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
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let ourShader = CreateAndLinkProgram(appDir&"/shaders/model_loading.vert",appDir&"/shaders/model_loading.frag")
let ourModel = LoadModel(appDir&"/models/nanosuit.obj")

#PolygonMode(PolygonFace.FRONT_AND_BACK,PolygonModeEnum.LINE)

Enable(Capability.DEPTH_TEST)

# Set up vertex data

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,3.0'f32))

var currentTime,prevTime:float
prevTime=cpuTime()
while run:
  let keystate = getKeyboardState()
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
  ClearColor(0.05,0.05,0.05,1.0)
  easygl.Clear(ClearBufferMask.COLOR_BUFFER_BIT, ClearBufferMask.DEPTH_BUFFER_BIT)

 
  ourShader.UseProgram()  
  

  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  var view = camera.GetViewMatrix()
  ourShader.SetMat4("projection",projection)
  ourShader.SetMat4("view",view)
  
  var model = mat4(1.0'f32)
  model = translate(model,vec3(0.0'f32,-1.75'f32,0.0'f32))
  model = scale(model,vec3(0.2'f32,0.2'f32,0.2'f32))  
  ourShader.SetMat4("model",model)
  ourModel.Draw(ourShader)

  
  window.glSwapWindow()

destroy window

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
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let shader = CreateAndLinkProgram(appDir&"/shaders/cubemaps.vert",appDir&"/shaders/cubemaps.frag")
let skyboxShader = CreateAndLinkProgram(appDir&"/shaders/skybox.vert",appDir&"/shaders/skybox.frag")

Enable(Capability.DEPTH_TEST)

# Set up vertex data
let cubeVertices : seq[float32]  = 
  @[   
    # positions           # normals
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,

    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,

    -0.5'f32,  0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,

     0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,

    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,

    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32]

let skyboxVertices = 
    @[
      # positions          
      -1.0'f32,  1.0'f32, -1.0'f32,
      -1.0'f32, -1.0'f32, -1.0'f32,
       1.0'f32, -1.0'f32, -1.0'f32,
       1.0'f32, -1.0'f32, -1.0'f32,
       1.0'f32,  1.0'f32, -1.0'f32,
      -1.0'f32,  1.0'f32, -1.0'f32,

      -1.0'f32, -1.0'f32,  1.0'f32,
      -1.0'f32, -1.0'f32, -1.0'f32,
      -1.0'f32,  1.0'f32, -1.0'f32,
      -1.0'f32,  1.0'f32, -1.0'f32,
      -1.0'f32,  1.0'f32,  1.0'f32,
      -1.0'f32, -1.0'f32,  1.0'f32,

       1.0'f32, -1.0'f32, -1.0'f32,
       1.0'f32, -1.0'f32,  1.0'f32,
       1.0'f32,  1.0'f32,  1.0'f32,
       1.0'f32,  1.0'f32,  1.0'f32,
       1.0'f32,  1.0'f32, -1.0'f32,
       1.0'f32, -1.0'f32, -1.0'f32,

      -1.0'f32, -1.0'f32,  1.0'f32,
      -1.0'f32,  1.0'f32,  1.0'f32,
       1.0'f32,  1.0'f32,  1.0'f32,
       1.0'f32,  1.0'f32,  1.0'f32,
       1.0'f32, -1.0'f32,  1.0'f32,
      -1.0'f32, -1.0'f32,  1.0'f32,

      -1.0'f32,  1.0'f32, -1.0'f32,
       1.0'f32,  1.0'f32, -1.0'f32,
       1.0'f32,  1.0'f32,  1.0'f32,
       1.0'f32,  1.0'f32,  1.0'f32,
      -1.0'f32,  1.0'f32,  1.0'f32,
      -1.0'f32,  1.0'f32, -1.0'f32,

      -1.0'f32, -1.0'f32, -1.0'f32,
      -1.0'f32, -1.0'f32,  1.0'f32,
       1.0'f32, -1.0'f32, -1.0'f32,
       1.0'f32, -1.0'f32, -1.0'f32,
      -1.0'f32, -1.0'f32,  1.0'f32,
       1.0'f32, -1.0'f32,  1.0'f32]

# cube VAO
let cubeVAO = GenBindVertexArray()
let cubeVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,cubeVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),3*float32.sizeof())

# skybox VAO
let skyboxVAO = GenBindVertexArray()
let skyboxVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,skyboxVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,3*float32.sizeof(),0)

let faces = [
  appDir&"/textures/right.jpg",
  appDir&"/textures/left.jpg",
  appDir&"/textures/top.jpg",
  appDir&"/textures/bottom.jpg",
  appDir&"/textures/back.jpg",
  appDir&"/textures/front.jpg"]

let cubemapTexture = LoadCubemap(faces)

shader.Use()
shader.SetInt("skybox",0)
skyboxShader.Use()
skyboxShader.SetInt("skybox",0)

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
  easygl.Clear(ClearBufferMask.COLOR_BUFFER_BIT, ClearBufferMask.DEPTH_BUFFER_BIT)
  
  shader.Use()
  var model = mat4(1.0'f32)    
  var view = camera.GetViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shader.SetMat4("model",model)
  shader.SetMat4("view",view)
  shader.SetMat4("projection",projection)
  shader.SetVec3("cameraPos",camera.Position)

  # cubes
  BindVertexArray(cubeVAO)
  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_CUBE_MAP,cubemapTexture)
  DrawArrays(DrawMode.TRIANGLES,0,36)
  UnbindVertexArray()
    
  # draw skybox
  
  DepthFunc(AlphaFunc.LEQUAL)
  skyboxShader.Use()  
  view[3][0] = 0
  view[3][1] = 0
  view[3][2] = 0      
  skyboxShader.SetMat4("view",view)
  skyboxShader.SetMat4("projection",projection)
  # skybox cube
  BindVertexArray(skyboxVAO)
  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_CUBE_MAP,cubemapTexture)
  DrawArrays(DrawMode.TRIANGLES,0,36)
  UnBindVertexArray()
  DepthFunc(AlphaFunc.LESS)
  
  
  window.glSwapWindow()


destroy window
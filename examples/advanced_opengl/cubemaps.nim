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

### Build and compile shader program
let appDir = getAppDir()
let shader = createAndLinkProgram(appDir&"/shaders/cubemaps.vert",appDir&"/shaders/cubemaps.frag")
let skyboxShader = createAndLinkProgram(appDir&"/shaders/skybox.vert",appDir&"/shaders/skybox.frag")

enable(Capability.DEPTH_TEST)

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
let cubeVAO = genBindVertexArray()
let cubeVBO = genBindBufferData(BufferTarget.ARRAY_BUFFER,cubeVertices,BufferDataUsage.STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),3*float32.sizeof())

# skybox VAO
let skyboxVAO = genBindVertexArray()
let skyboxVBO = genBindBufferData(BufferTarget.ARRAY_BUFFER,skyboxVertices,BufferDataUsage.STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,VertexAttribType.FLOAT,false,3*float32.sizeof(),0)

let faces = [
  appDir&"/textures/right.jpg",
  appDir&"/textures/left.jpg",
  appDir&"/textures/top.jpg",
  appDir&"/textures/bottom.jpg",
  appDir&"/textures/back.jpg",
  appDir&"/textures/front.jpg"]

let cubemapTexture = loadCubemap(faces)

shader.use()
shader.setInt("skybox",0)
skyboxShader.use()
skyboxShader.setInt("skybox",0)

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
  if error != ErrorType.NO_ERROR:
    echo $error
  # Render
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)
  
  shader.use()
  var model = mat4(1.0'f32)    
  var view = camera.getViewMatrix()
  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  shader.setMat4("model",model)
  shader.setMat4("view",view)
  shader.setMat4("projection",projection)
  shader.setVec3("cameraPos",camera.Position)

  # cubes
  bindVertexArray(cubeVAO)
  activeTexture(TextureUnit.TEXTURE0)
  bindTexture(TextureTarget.TEXTURE_CUBE_MAP,cubemapTexture)
  drawArrays(DrawMode.TRIANGLES,0,36)
  unBindVertexArray()
    
  # draw skybox
  
  depthFunc(AlphaFunc.LEQUAL)
  skyboxShader.use()  
  view[3][0] = 0
  view[3][1] = 0
  view[3][2] = 0      
  skyboxShader.setMat4("view",view)
  skyboxShader.setMat4("projection",projection)
  # skybox cube
  bindVertexArray(skyboxVAO)
  activeTexture(TextureUnit.TEXTURE0)
  bindTexture(TextureTarget.TEXTURE_CUBE_MAP,cubemapTexture)
  drawArrays(DrawMode.TRIANGLES,0,36)
  unBindVertexArray()
  depthFunc(AlphaFunc.LESS)
  
  
  window.glSwapWindow()


destroy window
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
var gamma = false
var gammaKeyPress = false;

let window = createWindow("Float", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()


enable(GL_DEPTH_TEST)
enable(GL_BLEND)
blendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)


### Build and compile shader program
let appDir = getAppDir()
let shader = createAndLinkProgram(appDir&"/shaders/advanced_lighting.vert",appDir&"/shaders/advanced_lighting.frag")



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

let planeVAO = genBindVertexArray()
let planeVBO = genBindBufferData(GL_ARRAY_BUFFER,planeVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,cGL_FLOAT,false,8*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,3,cGL_FLOAT,false,8*float32.sizeof(),3*float32.sizeof())
enableVertexAttribArray(2)
vertexAttribPointer(2,2,cGL_FLOAT,false,8*float32.sizeof(),6*float32.sizeof())
unBindVertexArray()

let floorTexture = loadTextureWithMips(appDir&"/textures/wood.png")

var lightPos = vec3(0.0'f32,0.0'f32,0.0'f32)

shader.use()
shader.setInt("texture1",0)

var
  evt = sdl2.defaultEvent
  run = true

viewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
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


  # toggle gamma
  if keyState[SDL_SCANCODE_B.uint8] != 0:
    gammaKeyPress = true 
  else:
    if gammaKeyPress:
        gamma = not gamma
        echo "gamma:" & $gamma
        gammaKeyPress = false
    
  

  let error = getGLError()
  if error != GL_NO_ERROR:
    echo $error.int32

  # Render
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  

  shader.use()
  var projection = perspective(radians(camera.Zoom), screenWidth.float32 / screenHeight.float32,0.1'f32,1000.0'f32)
  var view = camera.getViewMatrix()
  
  shader.setMat4("projection",projection)
  shader.setMat4("view",view)
  # set light uniforms  
  shader.setVec3("viewPos",camera.Position)
  shader.setVec3("lightPos",lightPos)
  shader.setInt("gamma", if gamma: 1 else: 0)

  # floor
  bindVertexArray(planeVAO)
  activeTexture(GL_TEXTURE0)
  bindTexture(GL_TEXTURE_2D,floorTexture)
  drawArrays(GL_TRIANGLES,0,6)

   
  

  window.glSwapWindow()


destroy window
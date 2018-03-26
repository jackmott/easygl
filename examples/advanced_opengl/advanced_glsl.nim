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
let shaderRed = createAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/red.frag")
let shaderGreen = createAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/green.frag")
let shaderBlue = createAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/blue.frag")
let shaderYellow = createAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/yellow.frag")


enable(GL_DEPTH_TEST)

# Set up vertex data
let cubeVertices : seq[float32]  = 
  @[   
    # positions              
    -0.5'f32, -0.5'f32, -0.5'f32, 
     0.5'f32, -0.5'f32, -0.5'f32,  
     0.5'f32,  0.5'f32, -0.5'f32,  
     0.5'f32,  0.5'f32, -0.5'f32,  
    -0.5'f32,  0.5'f32, -0.5'f32, 
    -0.5'f32, -0.5'f32, -0.5'f32, 

    -0.5'f32, -0.5'f32,  0.5'f32, 
     0.5'f32, -0.5'f32,  0.5'f32,  
     0.5'f32,  0.5'f32,  0.5'f32,  
     0.5'f32,  0.5'f32,  0.5'f32,  
    -0.5'f32,  0.5'f32,  0.5'f32, 
    -0.5'f32, -0.5'f32,  0.5'f32, 

    -0.5'f32,  0.5'f32,  0.5'f32, 
    -0.5'f32,  0.5'f32, -0.5'f32, 
    -0.5'f32, -0.5'f32, -0.5'f32, 
    -0.5'f32, -0.5'f32, -0.5'f32, 
    -0.5'f32, -0.5'f32,  0.5'f32, 
    -0.5'f32,  0.5'f32,  0.5'f32, 

     0.5'f32,  0.5'f32,  0.5'f32,  
     0.5'f32,  0.5'f32, -0.5'f32,  
     0.5'f32, -0.5'f32, -0.5'f32,  
     0.5'f32, -0.5'f32, -0.5'f32,  
     0.5'f32, -0.5'f32,  0.5'f32,  
     0.5'f32,  0.5'f32,  0.5'f32,  

    -0.5'f32, -0.5'f32, -0.5'f32, 
     0.5'f32, -0.5'f32, -0.5'f32,  
     0.5'f32, -0.5'f32,  0.5'f32,  
     0.5'f32, -0.5'f32,  0.5'f32,  
    -0.5'f32, -0.5'f32,  0.5'f32, 
    -0.5'f32, -0.5'f32, -0.5'f32, 

    -0.5'f32,  0.5'f32, -0.5'f32, 
     0.5'f32,  0.5'f32, -0.5'f32,  
     0.5'f32,  0.5'f32,  0.5'f32,  
     0.5'f32,  0.5'f32,  0.5'f32,  
    -0.5'f32,  0.5'f32,  0.5'f32, 
    -0.5'f32,  0.5'f32, -0.5'f32, ]


# cube VAO
let cubeVAO = genBindVertexArray()
let cubeVBO = genBindBufferData(GL_ARRAY_BUFFER,cubeVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,cGL_FLOAT,false,3*float32.sizeof(),0)

# configure a uniform buffer object
# ---------------------------------
# first. We get the relevant block indices
let uniformBlockIndexRed = getUniformBlockIndex(shaderRed,"Matrices")
let uniformBlockIndexGreen = getUniformBlockIndex(shaderGreen,"Matrices")
let uniformBlockIndexBlue = getUniformBlockIndex(shaderBlue,"Matrices")
let uniformBlockIndexYellow = getUniformBlockIndex(shaderYellow,"Matrices")
uniformBlockBinding(shaderRed,uniformBlockIndexRed,0)
uniformBlockBinding(shaderGreen,uniformBlockIndexGreen,0)
uniformBlockBinding(shaderBlue,uniformBlockIndexBlue,0)
uniformBlockBinding(shaderYellow,uniformBlockIndexYellow,0)

# now actually create the buffer
let uboMatrices = genBindBuffer(GL_UNIFORM_BUFFER)
bufferData(GL_UNIFORM_BUFFER,2*Mat4f.sizeof(),GL_STATIC_DRAW)
unbindBuffer(GL_UNIFORM_BUFFER)
# define the range of the buffer that links to a uniform binding point
bindBufferRange(GL_UNIFORM_BUFFER,0,uboMatrices,0,(2*Mat4f.sizeof()).int32)

# store the projection matrix (we only do this once now) (note: we're not using zoom anymore by changing the FoV)
let projection = perspective(45.0'f32,screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
bindBuffer(GL_UNIFORM_BUFFER,uboMatrices)
bufferSubData(GL_UNIFORM_BUFFER,0,Mat4f.sizeof(),projection.arr)
unbindBuffer(GL_UNIFORM_BUFFER)


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

  let view = camera.getViewMatrix()
  bindBuffer(GL_UNIFORM_BUFFER,uboMatrices)
  bufferSubData(GL_UNIFORM_BUFFER,Mat4f.sizeof(),Mat4f.sizeof(),view.arr)
  unbindBuffer(GL_UNIFORM_BUFFER)
  
  bindVertexArray(cubeVAO)
  shaderRed.use()
  var model = mat4(1.0'f32)
  model = translate(model,vec3(-0.75'f32,0.75'f32,0.0'f32))
  shaderRed.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)

  bindVertexArray(cubeVAO)
  shaderGreen.use()
  model = mat4(1.0'f32)
  model = translate(model,vec3(0.75'f32,0.75'f32,0.0'f32))
  shaderGreen.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)

  bindVertexArray(cubeVAO)
  shaderYellow.use()
  model = mat4(1.0'f32)
  model = translate(model,vec3(-0.75'f32,-0.75'f32,0.0'f32))
  shaderYellow.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)

  bindVertexArray(cubeVAO)
  shaderBlue.use()
  model = mat4(1.0'f32)
  model = translate(model,vec3(0.75'f32,-0.75'f32,0.0'f32))
  shaderBlue.setMat4("model",model)
  drawArrays(GL_TRIANGLES,0,36)
    
  window.glSwapWindow()


destroy window
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
let shaderRed = CreateAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/red.frag")
let shaderGreen = CreateAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/green.frag")
let shaderBlue = CreateAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/blue.frag")
let shaderYellow = CreateAndLinkProgram(appDir&"/shaders/advanced_glsl.vert",appDir&"/shaders/yellow.frag")


Enable(Capability.DEPTH_TEST)

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
let cubeVAO = GenBindVertexArray()
let cubeVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,cubeVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,3*float32.sizeof(),0)

# configure a uniform buffer object
# ---------------------------------
# first. We get the relevant block indices
let uniformBlockIndexRed = GetUniformBlockIndex(shaderRed,"Matrices")
let uniformBlockIndexGreen = GetUniformBlockIndex(shaderGreen,"Matrices")
let uniformBlockIndexBlue = GetUniformBlockIndex(shaderBlue,"Matrices")
let uniformBlockIndexYellow = GetUniformBlockIndex(shaderYellow,"Matrices")
UniformBlockBinding(shaderRed,uniformBlockIndexRed,0)
UniformBlockBinding(shaderGreen,uniformBlockIndexGreen,0)
UniformBlockBinding(shaderBlue,uniformBlockIndexBlue,0)
UniformBlockBinding(shaderYellow,uniformBlockIndexYellow,0)

# now actually create the buffer
let uboMatrices = GenBindBuffer(BufferTarget.UNIFORM_BUFFER)
BufferData(BufferTarget.UNIFORM_BUFFER,2*Mat4f.sizeof(),BufferDataUsage.STATIC_DRAW)
UnbindBuffer(BufferTarget.UNIFORM_BUFFER)
# define the range of the buffer that links to a uniform binding point
BindBufferRange(BufferRangeTarget.UNIFORM_BUFFER,0,uboMatrices,0,(2*Mat4f.sizeof()).int32)

# store the projection matrix (we only do this once now) (note: we're not using zoom anymore by changing the FoV)
let projection = perspective(45.0'f32,screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
BindBuffer(BufferTarget.UNIFORM_BUFFER,uboMatrices)
BufferSubData(BufferTarget.UNIFORM_BUFFER,0,Mat4f.sizeof(),projection.arr)
UnbindBuffer(BufferTarget.UNIFORM_BUFFER)


var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,3.0'f32))

var currentTime,prevTime:float
prevTime=cpuTime()
while run:  
  currentTime = cpuTime()
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

  let view = camera.GetViewMatrix()
  BindBuffer(BufferTarget.UNIFORM_BUFFER,uboMatrices)
  BufferSubData(BufferTarget.UNIFORM_BUFFER,Mat4f.sizeof(),Mat4f.sizeof(),view.arr)
  UnbindBuffer(BufferTarget.UNIFORM_BUFFER)
  
  BindVertexArray(cubeVAO)
  shaderRed.Use()
  var model = mat4(1.0'f32)
  model = translate(model,vec3(-0.75'f32,0.75'f32,0.0'f32))
  shaderRed.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)

  BindVertexArray(cubeVAO)
  shaderGreen.Use()
  model = mat4(1.0'f32)
  model = translate(model,vec3(0.75'f32,0.75'f32,0.0'f32))
  shaderGreen.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)

  BindVertexArray(cubeVAO)
  shaderYellow.Use()
  model = mat4(1.0'f32)
  model = translate(model,vec3(-0.75'f32,-0.75'f32,0.0'f32))
  shaderYellow.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)

  BindVertexArray(cubeVAO)
  shaderBlue.Use()
  model = mat4(1.0'f32)
  model = translate(model,vec3(0.75'f32,-0.75'f32,0.0'f32))
  shaderBlue.SetMat4("model",model)
  DrawArrays(DrawMode.TRIANGLES,0,36)
    
  window.glSwapWindow()


destroy window
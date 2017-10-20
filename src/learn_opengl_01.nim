# OpenGL example using SDL2

import sdl2
import opengl
import easygl


discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

var window = createWindow("Learn OpenGL 01", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
var context = window.glCreateContext()

# Initialize OpenGL
loadExtensions()

let vertices : array[9,float32]  = 
  [ -0.5'f32,-0.5'f32,0.0'f32,
    0.5'f32,-0.5'f32,0.0'f32,
    0.0'f32,0.5'f32,0.0'f32]
 

let vertexShader = CreateShader(ShaderType.VERTEX_SHADER)
ShaderSource(vertexShader, readFile("shaders/logl01.vert"))
CompileShader(vertexShader)

if not GetShaderCompileStatus(vertexShader):
  echo "Shader Error:" 
  echo GetShaderInfoLog(vertexShader)


let fragmentShader = CreateShader(ShaderType.FRAGMENT_SHADER)
ShaderSource(fragmentShader,readFile("shaders/logl01.frag"))
CompileShader(fragmentShader)

if not GetShaderCompileStatus(fragmentShader):
  echo "Shader Error:" 
  echo GetShaderInfoLog(fragmentShader)

let program = CreateAndLinkProgram(vertexShader,fragmentShader)
if not GetProgramLinkStatus(program):
  echo "Link Error:"
  echo GetProgramInfoLog(program)
  
DeleteShader(fragmentShader)
DeleteShader(vertexShader)

let VAO = GenVertexArrays(1)
let VBO = GenBuffers(1)
BindVertexArray(VAO)
BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
BufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,3*float32.sizeof(),nil)
EnableVertexAttribArray(0)
BindBuffer(BufferTarget.ARRAY_BUFFER,0.BufferId)
BindVertexArray(0.VertexArrayId)


var
  evt = sdl2.defaultEvent
  runGame = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
  
while runGame:
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break
    if evt.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(evt))
      if windowEvent.event == WindowEvent_Resized:
        let newWidth = windowEvent.data1
        let newHeight = windowEvent.data2
        glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window
        
  glClearColor(0.2,0.3,0.3,1.0)
  Clear(ClearBufferMask.COLOR_BUFFER_BIT)
  UseProgram(program)
  BindVertexArray(VAO)
  DrawArrays(DrawMode.TRIANGLES,0,3)
  window.glSwapWindow()

destroy window
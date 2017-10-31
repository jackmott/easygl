
# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import easygl.utils
import stb_image/read as stbi
import glm
import ../utils/camera_util
import times
import os

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Light Casters", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let lightingShader = CreateAndLinkProgram(appDir&"/shaders/light_casters.vert",appDir&"/shaders/light_casters.frag")

Enable(Capability.DEPTH_TEST)

# Set up vertex data
let vertices : seq[float32]  =
  @[
    # positions                    # normals           # texture coords
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,  1.0'f32,  1.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,  1.0'f32,  1.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,  0.0'f32,  1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,  0.0'f32,  0.0'f32,

    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,  1.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,  1.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,  1.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,  0.0'f32,

    -0.5'f32,  0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,

     0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,

    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,

    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,  1.0'f32,  1.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,  0.0'f32,  1.0'f32]


let cubePositions : seq[Vec3f] =
  @[
    vec3( 0.0'f32,  0.0'f32,  0.0'f32),
    vec3( 2.0'f32,  5.0'f32, -15.0'f32),
    vec3(-1.5'f32, -2.2'f32, -2.5'f32),
    vec3(-3.8'f32, -2.0'f32, -12.3'f32),
    vec3( 2.4'f32, -0.4'f32, -3.5'f32),
    vec3(-1.7'f32,  3.0'f32, -7.5'f32),
    vec3( 1.3'f32, -2.0'f32, -2.5'f32),
    vec3( 1.5'f32,  2.0'f32, -2.5'f32),
    vec3( 1.5'f32,  0.2'f32, -1.5'f32),
    vec3(-1.3'f32,  1.0'f32, -1.5'f32)
  ]

let cubeVAO = GenVertexArray()
let VBO = GenBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).HH
BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
BufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)

BindVertexArray(cubeVAO)

VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,8*float32.sizeof(),0)
EnableVertexAttribArray(0)
VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,8*float32.sizeof(),3*float32.sizeof())
EnableVertexAttribArray(1)
VertexAttribPointer(2,2,VertexAttribType.FLOAT,false,8*float32.sizeof(),6*float32.sizeof())
EnableVertexAttribArray(2);

let lightVAO = GenVertexArray()
BindVertexArray(lightVAO)
BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,8*float32.sizeof(),0)
EnableVertexAttribArray(0)

let diffuseMap = LoadTextureWithMips(appDir&"/textures/container2.png")
let specularMap = LoadTextureWithMips(appDir&"/textures/container2_specular.png")

lightingShader.Use()
lightingShader.SetInt("diffuse",0)
lightingShader.SetInt("specular",1)

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

  # Render
  ClearColor(0.1,0.1,0.1,1.0)
  easygl.Clear(ClearBufferMask.COLOR_BUFFER_BIT, ClearBufferMask.DEPTH_BUFFER_BIT)

 
  lightingShader.Use()  
  lightingShader.SetVec3("light.position", camera.Position)
  lightingShader.SetVec3("light.direction",camera.Front)  
  lightingShader.SetFloat("light.cutOff",cos(radians(12.5'f32)))
  lightingShader.SetFloat("light.outerCutOff",cos(radians(17.5'f32)))
  lightingShader.SetVec3("viewPos",camera.Position)

  # light properties
  lightingShader.SetVec3("light.ambient",0.1'f32,0.1'f32,0.1'f32)
  lightingShader.SetVec3("light.diffuse",0.8'f32,0.8'f32,0.8'f32)
  lightingShader.SetVec3("light.specular",1.0'f32,1.0'f32,1.0'f32)
  lightingShader.SetFloat("light.constant",1.0'f32)
  lightingShader.SetFloat("light.linear",0.09'f32)
  lightingShader.SetFloat("light.quadratic",0.032'f32)
  lightingShader.SetFloat("material.shininess", 64.0'f32)
  

  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  var view = camera.GetViewMatrix()

  lightingShader.SetMat4("projection",projection)
  lightingShader.SetMat4("view",view)
  
  var model = mat4(1.0'f32)
  lightingShader.SetMat4("model",model)

  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_2D,diffuseMap)

  ActiveTexture(TextureUnit.TEXTURE1)
  BindTexture(TextureTarget.TEXTURE_2D,specularMap)  

  BindVertexArray(cubeVAO)

  for i,cubePos in cubePositions:
    var model = mat4(1.0'f32)
    model = translate(model,cubePos)
    let angle = 20.0'f32 * i.float32
    model = rotate(model,radians(angle),vec3(1.0'f32,0.3'f32,0.5'f32))
    lightingShader.SetMat4("model",model)
    DrawArrays(DrawMode.TRIANGLES,0,36)
  
  
  window.glSwapWindow()

DeleteVertexArray(cubeVAO)
DeleteVertexArray(lightVAO)
DeleteBuffer(VBO)
destroy window

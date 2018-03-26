
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
import random


discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Multiple Lights", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let lightingShader = createAndLinkProgram(appDir&"/shaders/multiple_lights.vert",appDir&"/shaders/multiple_lights.frag")
let lampShader = createAndLinkProgram(appDir&"/shaders/lamp.vert",appDir&"/shaders/lamp.frag")

enable(GL_DEPTH_TEST)

# Set up vertex data
let vertices =
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


let cubePositions =
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

var pointLightPositions  =
  @[
    vec3( 0.7'f32,  0.2'f32,  2.0'f32),
    vec3( 2.3'f32, -3.3'f32, -4.0'f32),
    vec3(-4.0'f32,  2.0'f32, -12.0'f32),
    vec3( 0.0'f32,  0.0'f32, -3.0'f32)
  ]

let cubeVAO = genVertexArray()
let VBO = genBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).HH
bindBuffer(GL_ARRAY_BUFFER,VBO)
bufferData(GL_ARRAY_BUFFER,vertices,GL_STATIC_DRAW)

bindVertexArray(cubeVAO)

vertexAttribPointer(0,3,cGL_FLOAT,false,8*float32.sizeof(),0)
enableVertexAttribArray(0)
vertexAttribPointer(1,3,cGL_FLOAT,false,8*float32.sizeof(),3*float32.sizeof())
enableVertexAttribArray(1)
vertexAttribPointer(2,2,cGL_FLOAT,false,8*float32.sizeof(),6*float32.sizeof())
enableVertexAttribArray(2);

let lightVAO = genVertexArray()
bindVertexArray(lightVAO)
bindBuffer(GL_ARRAY_BUFFER,VBO)
vertexAttribPointer(0,3,cGL_FLOAT,false,8*float32.sizeof(),0)
enableVertexAttribArray(0)

let diffuseMap = loadTextureWithMips(appDir&"/textures/container2.png")
let specularMap = loadTextureWithMips(appDir&"/textures/container2_specular.png")

lightingShader.use()
lightingShader.setInt("diffuse",0)
lightingShader.setInt("specular",1)

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

  # Render
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

 
  lightingShader.use()  
  lightingShader.setVec3("viewPos",camera.Position)
  lightingShader.setFloat("material.shininess", 32.0'f32)

  lightingShader.setVec3("dirLight.direction",-0.2'f32,-1'f32,-0.3'f32)
  lightingShader.setVec3("dirLight.ambient",0.05'f32,0.05'f32,0.05'f32)
  lightingShader.setVec3("dirLight.diffuse",0.4'f32,0.4'f32,0.4'f32)
  lightingShader.setVec3("ditLight.specular",0.5'f32,0.5'f32,0.5'f32)  

  # Doing this a bit different than learnopengl.com
  # Because this is like 10x less typing
  for i,pointLight in pointLightPositions.mpairs:
    let prefix = "pointLights[" & $i & "]."

    var 
      ambient = vec3(0.05'f32)              
      diffuse = vec3(0.8'f32,0.8'f32,0.8'f32)
      specular = vec3(1.0'f32) 
      constant = 1.0'f32
      linear = 0.09'f32 
      quadratic = 0.032'f32

    lightingShader.setVec3(prefix&"position",pointLight)
    lightingShader.setVec3(prefix&"ambient",ambient);
    lightingShader.setVec3(prefix&"diffuse",diffuse);
    lightingShader.setVec3(prefix&"specular",specular);
    lightingShader.setFloat(prefix&"constant",constant);
    lightingShader.setFloat(prefix&"linear",linear);
    lightingShader.setFloat(prefix&"quadratic",quadratic);


  lightingShader.setVec3("spotLight.position", camera.Position)
  lightingShader.setVec3("spotLight.direction",camera.Front)  
  lightingShader.setVec3("spotLight.ambient",0.0'f32,0.0'f32,0.0'f32)
  lightingShader.setVec3("spotLight.diffuse",1'f32,1'f32,1'f32)
  lightingShader.setVec3("spotLight.specular",1.0'f32,1.0'f32,1.0'f32)
  lightingShader.setFloat("spotLight.constant",1.0'f32)
  lightingShader.setFloat("spotLight.linear",0.09'f32)
  lightingShader.setFloat("spotLight.quadratic",0.032'f32)
  lightingShader.setFloat("spotLight.cutOff",cos(radians(12.5'f32)))
  lightingShader.setFloat("spotLight.outerCutOff",cos(radians(15.5'f32)))   
  
  

  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  var view = camera.getViewMatrix()

  lightingShader.setMat4("projection",projection)
  lightingShader.setMat4("view",view)
  
  var model = mat4(1.0'f32)
  lightingShader.setMat4("model",model)

  activeTexture(GL_TEXTURE0)
  bindTexture(GL_TEXTURE_2D,diffuseMap)

  activeTexture(GL_TEXTURE1)
  bindTexture(GL_TEXTURE_2D,specularMap)  

  bindVertexArray(cubeVAO)

  for i,cubePos in cubePositions:
    var model = mat4(1.0'f32)
    model = translate(model,cubePos)
    let angle = 20.0'f32 * i.float32
    model = rotate(model,radians(angle),vec3(1.0'f32,0.3'f32,0.5'f32))
    lightingShader.setMat4("model",model)
    drawArrays(GL_TRIANGLES,0,36)
  
  lampShader.use()
  lampShader.setMat4("projection",projection)
  lampShader.setMat4("view",view)  

  bindVertexArray(lightVAO)
  for i,lightPos in pointLightPositions.mpairs:
    var model = mat4(1.0'f32)
    model = translate(model,lightPos)
    model = scale(model,vec3(0.2'f32))
    lampShader.setMat4("model",model)
    drawArrays(GL_TRIANGLES,0,36)
  
  window.glSwapWindow()

deleteVertexArray(cubeVAO)
deleteVertexArray(lightVAO)
deleteBuffer(VBO)
destroy window

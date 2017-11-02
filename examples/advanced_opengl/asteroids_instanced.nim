
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
  os,
  random


discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Float", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

Enable(Capability.DEPTH_TEST)


### Build and compile shader program
let appDir = getAppDir()
let asteroidShader = CreateAndLinkProgram(appDir&"/shaders/asteroids.vert",appDir&"/shaders/asteroids.frag")
let planetShader = CreateAndLinkProgram(appDir&"/shaders/planet.vert",appDir&"/shaders/planet.frag")

let rock = LoadModel(appDir & "/models/rock/rock.obj")
let planet = LoadModel(appDir & "/models/planet/planet.obj")

let amount = 100_000
var modelMatrices = newSeq[Mat4f](amount)
let radius = 175.0'f32
let offset = 75.0'f32
for i in 0..<amount:
  var model = mat4(1.0'f32)
  # 1. translation: displace along circle with 'radius' in range [-offset, offset]
  let angle = i.float32 / amount.float32 * 360.0'f32
  var displacement = random((2*offset*100).int).float32 / 100.0'f32 - offset
  let x = sin(angle) * radius + displacement
  displacement = random((2*offset*100).int).float32 / 100.0'f32 - offset
  let y = displacement * 0.4'f32
  displacement = random((2*offset*100).int).float32 / 100.0'f32 - offset
  let z = cos(angle) * radius + displacement
  model = translate(model,vec3(x,y,z))

  # 2. scale: Scale between 0.05 and 0.25f
  let scale = random(20).float32 / 100.0'f32 + 0.05'f32
  model = scale(model,vec3(scale))

  # 3. rotation: add random rotation around a (semi)randomly picked rotation axis vector
  let rotAngle = random(360).float32
  model = rotate(model,radians(rotAngle),vec3(0.4'f32,0.6'f32,0.8'f32))

  # add to seq of matrices
  modelMatrices[i] = model

# configure instanced array
let buffer = GenBindBuffer(BufferTarget.ARRAY_BUFFER) 
BufferData(BufferTarget.ARRAY_BUFFER, amount * Mat4f.sizeof(), modelMatrices[0].addr,BufferDataUsage.STATIC_DRAW)
 

# set transformation matrices as an instance vertex attribute (with divisor 1)
# note: we're cheating a little by taking the, now publicly declared, VAO of the model's mesh(es) and adding new vertexAttribPointers
# normally you'd want to do this in a more organized fashion, but for learning purposes this will do.
# -----------------------------------------------------------------------------------------------------------------------------------
for mesh in rock.meshes:   
  BindVertexArray(mesh.VAO)
  EnableVertexAttribArray(3)  
  VertexAttribPointer(3,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),0)
  EnableVertexAttribArray(4)
  VertexAttribPointer(4,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),Vec4f.sizeof())
  EnableVertexAttribArray(5)
  VertexAttribPointer(5,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),2*Vec4f.sizeof())
  EnableVertexAttribArray(6)
  VertexAttribPointer(6,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),3*Vec4f.sizeof())
  
  VertexAttribDivisor(3,1)
  VertexAttribDivisor(4,1)
  VertexAttribDivisor(5,1)
  VertexAttribDivisor(6,1)

  UnbindVertexArray()
  

var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,155.0'f32))

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
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

  # configure transform matrices
  var projection = perspective(radians(45.0'f32),screenWidth.float32/screenHeight.float32,0.1'f32,1000.0'f32)
  var view = camera.GetViewMatrix()
  asteroidShader.Use()
  asteroidShader.SetMat4("projection",projection)
  asteroidShader.SetMat4("view",view)
  planetShader.Use()
  planetShader.SetMat4("projection",projection)
  planetShader.SetMat4("view",view)

  # draw planet
  var model = mat4(1.0'f32)
  model = translate(model,vec3(0.0'f32,-3.0'f32,0.0'f32))
  model = scale(model,vec3(4.0'f32,4.0'f32,4.0'f32))  
  planetShader.SetMat4("model",model)
  planet.Draw(planetShader)

  # draw asteroids
  asteroidShader.Use()
  asteroidShader.SetInt("TextureDiffuse1",0)
  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_2D,rock.textures_loaded[0].id)
  for mesh in rock.meshes:
    BindVertexArray(mesh.VAO)
    DrawElementsInstanced(DrawMode.TRIANGLES,mesh.indices.len,IndexType.UNSIGNED_INT,amount)
    UnbindVertexArray()
  
  window.glSwapWindow()

destroy window

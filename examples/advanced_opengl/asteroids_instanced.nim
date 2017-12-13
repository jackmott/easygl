
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

enable(Capability.DEPTH_TEST)


### Build and compile shader program
let appDir = getAppDir()
let asteroidShader = createAndLinkProgram(appDir&"/shaders/asteroids.vert",appDir&"/shaders/asteroids.frag")
let planetShader = createAndLinkProgram(appDir&"/shaders/planet.vert",appDir&"/shaders/planet.frag")

let rock = loadModel(appDir & "/models/rock/rock.obj")
let planet = loadModel(appDir & "/models/planet/planet.obj")

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
  model = rotate(model,vec3(0.4'f32,0.6'f32,0.8'f32),radians(rotAngle))

  # add to seq of matrices
  modelMatrices[i] = model

# configure instanced array
let buffer = genBindBuffer(BufferTarget.ARRAY_BUFFER) 
bufferData(BufferTarget.ARRAY_BUFFER, amount * Mat4f.sizeof(), modelMatrices[0].addr,BufferDataUsage.STATIC_DRAW)
 

# set transformation matrices as an instance vertex attribute (with divisor 1)
# note: we're cheating a little by taking the, now publicly declared, VAO of the model's mesh(es) and adding new vertexAttribPointers
# normally you'd want to do this in a more organized fashion, but for learning purposes this will do.
# -----------------------------------------------------------------------------------------------------------------------------------
for mesh in rock.meshes:   
  bindVertexArray(mesh.VAO)
  enableVertexAttribArray(3)  
  vertexAttribPointer(3,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),0)
  enableVertexAttribArray(4)
  vertexAttribPointer(4,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),Vec4f.sizeof())
  enableVertexAttribArray(5)
  vertexAttribPointer(5,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),2*Vec4f.sizeof())
  enableVertexAttribArray(6)
  vertexAttribPointer(6,4,VertexAttribType.FLOAT,false,Mat4f.sizeof(),3*Vec4f.sizeof())
  
  vertexAttribDivisor(3,1)
  vertexAttribDivisor(4,1)
  vertexAttribDivisor(5,1)
  vertexAttribDivisor(6,1)

  unBindVertexArray()
  

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
  clearColor(0.05,0.05,0.05,1.0)
  easygl.clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

  # configure transform matrices
  var projection = perspective(radians(45.0'f32),screenWidth.float32/screenHeight.float32,0.1'f32,1000.0'f32)
  var view = camera.getViewMatrix()
  asteroidShader.use()
  asteroidShader.setMat4("projection",projection)
  asteroidShader.setMat4("view",view)
  planetShader.use()
  planetShader.setMat4("projection",projection)
  planetShader.setMat4("view",view)

  # draw planet
  var model = mat4(1.0'f32)
  model = translate(model,vec3(0.0'f32,-3.0'f32,0.0'f32))
  model = scale(model,vec3(4.0'f32,4.0'f32,4.0'f32))  
  planetShader.setMat4("model",model)
  planet.draw(planetShader)

  # draw asteroids
  asteroidShader.use()
  asteroidShader.setInt("TextureDiffuse1",0)
  activeTexture(TextureUnit.TEXTURE0)
  bindTexture(TextureTarget.TEXTURE_2D,rock.textures_loaded[0].id)
  for mesh in rock.meshes:
    bindVertexArray(mesh.VAO)
    drawElementsInstanced(DrawMode.TRIANGLES,mesh.indices.len,IndexType.UNSIGNED_INT,amount)
    unBindVertexArray()
  
  window.glSwapWindow()

destroy window

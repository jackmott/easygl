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
let shader = CreateAndLinkProgram(appDir&"/shaders/anti_aliasing.vert",appDir&"/shaders/anti_aliasing.frag")
let screenShader = CreateAndLinkProgram(appDir&"/shaders/aa_post.vert",appDir&"/shaders/aa_post.frag")


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


let quadVertices = @[
  # positions         # texCoords
  -1.0'f32,  1.0'f32,  0.0'f32, 1.0'f32,
  -1.0'f32, -1.0'f32,  0.0'f32, 0.0'f32,
    1.0'f32, -1.0'f32,  1.0'f32, 0.0'f32,

  -1.0'f32,  1.0'f32,  0.0'f32, 1.0'f32,
    1.0'f32, -1.0'f32,  1.0'f32, 0.0'f32,
    1.0'f32,  1.0'f32,  1.0'f32, 1.0'f32
]


# cube VAO
let cubeVAO = GenBindVertexArray()
let cubeVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER,cubeVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,3*float32.sizeof(),0)

# screen vao
let quadVAO = GenBindVertexArray()
let quadVBO = GenBindBufferData(BufferTarget.ARRAY_BUFFER, quadVertices,BufferDataUsage.STATIC_DRAW)
EnableVertexAttribArray(0)
VertexAttribPointer(0,2,VertexAttribType.FLOAT,false,4*float32.sizeof(),0)
EnableVertexAttribArray(1)
VertexAttribPointer(1,2,VertexAttribType.FLOAT,false,4*float32.sizeof(),2*float32.sizeof())

# configure MSAA framebuffer
let framebuffer = GenBindFramebuffer(FramebufferTarget.FRAMEBUFFER)
# create a multismaples color attachment texture
let textureColorBufferMultisampled = GenBindTexture(TextureTarget.TEXTURE_2D_MULTISAMPLE)
TexImage2DMultisample(TexImageMultisampleTarget.TEXTURE_2D_MULTISAMPLE,4,TextureInternalFormat.RGB,screenWidth,screenHeight,true)
UnBindTexture(TextureTarget.TEXTURE_2D_MULTISAMPLE)
FramebufferTexture2D(FramebufferTarget.FRAMEBUFFER,FramebufferAttachment.COLOR_ATTACHMENT0,FramebufferTextureTarget.TEXTURE_2D_MULTISAMPLE,textureColorBufferMultisampled,0)
# create a (also multisampled) renderbuffer object for depth and stencil attachments
let rbo = GenBindRenderbuffer()
RenderBufferStorageMultisample(4,RenderBufferFormat.DEPTH24_STENCIL8,screenWidth,screenHeight)
UnBindRenderBuffer()
FramebufferRenderBuffer(FramebufferTarget.FRAMEBUFFER,FramebufferAttachment.DEPTH_STENCIL_ATTACHMENT,rbo)

if CheckFramebufferStatus(FramebufferTarget.FRAMEBUFFER) != FramebufferStatus.FRAMEBUFFER_COMPLETE:
  echo "Framebuffer not complete"

# configure second post-processing framebuffer 
let intermediateFBO = GenBindFramebuffer(FramebufferTarget.FRAMEBUFFER)
# create a color attachment texture
let screenTexture = GenBindTexture(TextureTarget.TEXTURE_2D)
TexImage2D(TexImageTarget.TEXTURE_2D,0,TextureInternalFormat.RGB,screenWidth,screenHeight,PixelDataFormat.RGB,PixelDataType.UNSIGNED_BYTE)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
TexParameteri(TextureTarget.TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)
FramebufferTexture2D(FramebufferTarget.FRAMEBUFFER,FrameBufferAttachment.COLOR_ATTACHMENT0,FramebufferTextureTarget.TEXTURE_2D,screenTexture,0)
  
if CheckFramebufferStatus(FramebufferTarget.FRAMEBUFFER) != FramebufferStatus.FRAMEBUFFER_COMPLETE:
  echo "Framebuffer not complete"

UnBindFramebuffer(FramebufferTarget.FRAMEBUFFER)
 
# shader config
shader.Use()
screenShader.SetInt("screenTexture",0)

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
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

  # 1. draw scene as normal in multisampled buffers
  BindFramebuffer(FramebufferTarget.FRAMEBUFFER,framebuffer)
  ClearColor(0.1,0.1,0.1,1.0)
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)
  Enable(Capability.DEPTH_TEST)

  shader.Use()
  var projection = perspective(radians(camera.Zoom), screenWidth.float32 / screenHeight.float32,0.1'f32,1000.0'f32)
  var view = camera.GetViewMatrix()
  var model = mat4(1.0'f32)
  shader.SetMat4("projection",projection)
  shader.SetMat4("view",view)
  shader.SetMat4("model",model)
 
  BindVertexArray(cubeVAO)
  DrawArrays(DrawMode.TRIANGLES,0,36)

  # 2. now blit multisampled buffer(s) to normal colorbuffer of intermediate FBO. Image is stored in screenTexture
  BindFramebuffer(FramebufferTarget.READ_FRAMEBUFFER,framebuffer)
  BindFramebuffer(FramebufferTarget.DRAW_FRAMEBUFFER,intermediateFBO)
  BlitFramebuffer(0,0,screenWidth,screenHeight,0,0,screenWidth,screenHeight,BufferMask.COLOR_BUFFER_BIT,BlitFilter.NEAREST)

  # 3.now render quad with scene's visuals as its texture image
  UnBindFramebuffer(FramebufferTarget.FRAMEBUFFER)
  ClearColor(1.0,1.0,1.0,1.0)
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT)
  Disable(Capability.DEPTH_TEST)

  # draw Screen quads
  screenShader.Use()
  BindVertexArray(quadVAO)
  ActiveTexture(TextureUnit.TEXTURE0)
  BindTexture(TextureTarget.TEXTURE_2D,screenTexture)
  DrawArrays(DrawMode.TRIANGLES,0,6)
  

  window.glSwapWindow()


destroy window
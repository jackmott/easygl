# OpenGL example using SDL2
## TODO this one has a bug, whole screen is green. don't know what.
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
let shader = createAndLinkProgram(appDir&"/shaders/anti_aliasing.vert",appDir&"/shaders/anti_aliasing.frag")
let screenShader = createAndLinkProgram(appDir&"/shaders/aa_post.vert",appDir&"/shaders/aa_post.frag")


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
let cubeVAO = genBindVertexArray()
let cubeVBO = genBindBufferData(GL_ARRAY_BUFFER,cubeVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,3,cGL_FLOAT,false,3*float32.sizeof(),0)

# screen vao
let quadVAO = genBindVertexArray()
let quadVBO = genBindBufferData(GL_ARRAY_BUFFER, quadVertices,GL_STATIC_DRAW)
enableVertexAttribArray(0)
vertexAttribPointer(0,2,cGL_FLOAT,false,4*float32.sizeof(),0)
enableVertexAttribArray(1)
vertexAttribPointer(1,2,cGL_FLOAT,false,4*float32.sizeof(),2*float32.sizeof())

# configure MSAA framebuffer
let framebuffer = genBindFramebuffer(GL_FRAMEBUFFER)
# create a multismaples color attachment texture
let textureColorBufferMultisampled = genBindTexture(GL_TEXTURE_2D_MULTISAMPLE)
texImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE,4,GL_RGB,screenWidth,screenHeight,true)
unBindTexture(GL_TEXTURE_2D_MULTISAMPLE)
framebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D_MULTISAMPLE,textureColorBufferMultisampled,0)
# create a (also multisampled) renderbuffer object for depth and stencil attachments
let rbo = genBindRenderbuffer()
renderBufferStorageMultisample(4,GL_DEPTH24_STENCIL8,screenWidth,screenHeight)
unBindRenderBuffer()
framebufferRenderBuffer(GL_FRAMEBUFFER,GL_DEPTH_STENCIL_ATTACHMENT,rbo)

if checkFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE:
  echo "Framebuffer not complete"

# configure second post-processing framebuffer 
let intermediateFBO = genBindFramebuffer(FrameGL_FRAMEBUFFER)
# create a color attachment texture
let screenTexture = genBindTexture(GL_TEXTURE_2D)
texImage2D(TexImageTarget.TEXTURE_2D,0,TextureInternalFormat.RGB,screenWidth,screenHeight,PixelDataFormat.RGB,PixelDataType.UNSIGNED_BYTE)
texParameteri(GL_TEXTURE_2D,TextureParameter.TEXTURE_MIN_FILTER,GL_LINEAR)
texParameteri(GL_TEXTURE_2D,TextureParameter.TEXTURE_MAG_FILTER,GL_LINEAR)
framebufferTexture2D(FrameGL_FRAMEBUFFER,FrameBufferAttachment.COLOR_ATTACHMENT0,FramebufferGL_TEXTURE_2D,screenTexture,0)
  
if checkFramebufferStatus(FrameGL_FRAMEBUFFER) != FramebufferStatus.FRAMEBUFFER_COMPLETE:
  echo "Framebuffer not complete"

unBindFramebuffer(FrameGL_FRAMEBUFFER)
 
# shader config
shader.use()
screenShader.setInt("screenTexture",0)

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
    echo $error

  # Render
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  # 1. draw scene as normal in multisampled buffers
  bindFramebuffer(FrameGL_FRAMEBUFFER,framebuffer)
  clearColor(0.1,0.1,0.1,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  enable(GL_DEPTH_TEST)

  shader.use()
  var projection = perspective(radians(camera.Zoom), screenWidth.float32 / screenHeight.float32,0.1'f32,1000.0'f32)
  var view = camera.getViewMatrix()
  var model = mat4(1.0'f32)
  shader.setMat4("projection",projection)
  shader.setMat4("view",view)
  shader.setMat4("model",model)
 
  bindVertexArray(cubeVAO)
  drawArrays(GL_TRIANGLES,0,36)

  # 2. now blit multisampled buffer(s) to normal colorbuffer of intermediate FBO. Image is stored in screenTexture
  bindFramebuffer(FrameGL_READ_FRAMEBUFFER,framebuffer)
  bindFramebuffer(FrameGL_DRAW_FRAMEBUFFER,intermediateFBO)
  blitFramebuffer(0,0,screenWidth,screenHeight,0,0,screenWidth,screenHeight,GL_COLOR_BUFFER_BIT,BlitFilter.NEAREST)

  # 3.now render quad with scene's visuals as its texture image
  unBindFramebuffer(FrameGL_FRAMEBUFFER)
  clearColor(1.0,1.0,1.0,1.0)
  easygl.clear(GL_COLOR_BUFFER_BIT)
  disable(GL_DEPTH_TEST)

  # draw Screen quads
  screenShader.use()
  bindVertexArray(quadVAO)
  activeTexture(GL_TEXTURE0)
  bindTexture(GL_TEXTURE_2D,screenTexture)
  drawArrays(GL_TRIANGLES,0,6)
  

  window.glSwapWindow()


destroy window
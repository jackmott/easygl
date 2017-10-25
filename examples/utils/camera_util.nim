import glm

type CameraMovement* = enum
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT

let YAW = -90.0'f32
let PITCH = 0.0'f32
let SPEED = 20.5'f32
let SENSITIVITY = 0.1'f32
let ZOOM = 45.0'f32

type Camera* = ref object
    Position*,Front*,Up*,Right*,WorldUp*:Vec3f
    Yaw*,Pitch*,MovementSpeed*,MouseSensitivity*,Zoom*:float32

proc UpdateCameraVectors(camera: Camera) = 
    camera.Front.x = cos(radians(camera.Yaw)) * cos(radians(camera.Pitch))
    camera.Front.y = sin(radians(camera.Pitch))
    camera.Front.z = sin(radians(camera.Yaw)) * cos(radians(camera.Pitch))
    camera.Front = normalize(camera.Front);
    camera.Right = normalize(cross(camera.Front, camera.WorldUp))
    camera.Up    = normalize(cross(camera.Right, camera.Front))

proc newCamera*(position:Vec3f = vec3(0.0'f32),up:Vec3f = vec3(0.0'f32,1.0'f32,0.0'f32),yaw:float32 = YAW,pitch:float32 = PITCH) : Camera = 
    var camera = Camera(
        Position : position,
        WorldUp : up,
        Yaw : yaw,
        MovementSpeed : SPEED,
        MouseSensitivity :SENSITIVITY,
        Zoom : ZOOM,
        Front: vec3(0.0'f32,0.0'f32,-1.0'f32))
    camera.UpdateCameraVectors()
    camera

proc GetViewMatrix*(camera:Camera) : Mat4f =
    lookAt(camera.Position, camera.Position + camera.Front, camera.Up)

proc ProcessKeyboard*(camera:Camera,direction:CameraMovement, deltaTime:float32) =
    let velocity = camera.MovementSpeed*deltaTime
    case direction:
        of FORWARD:
            camera.Position = camera.Position + camera.Front * velocity
        of BACKWARD:
            camera.Position = camera.Position - camera.Front * velocity
        of LEFT:
            camera.Position = camera.Position - camera.Right * velocity
        of RIGHT:    
            camera.Position = camera.Position + camera.Right * velocity

proc ProcessMouseMovement*(camera:Camera, xoffset: float32, yoffset:float32, constrainPitch: bool = true) =
    let adjustedXOffset = xoffset * camera.MouseSensitivity
    let adjustedYOffset = yoffset * camera.MouseSensitivity

    camera.Yaw = camera.Yaw + adjustedXOffset
    camera.Pitch = camera.Pitch - adjustedYOffset

    if constrainPitch:
        if camera.Pitch > 89.0'f32:
            camera.Pitch = 89.0'f32
        elif camera.Pitch < -89.0'f32:
            camera.Pitch = -89.0'f32
    
    UpdateCameraVectors(camera)

proc ProcessMouseScroll*(camera:Camera, yoffset:float32) =
    if camera.Zoom >= 1.0'f32 and camera.Zoom <= 45.0'f32:
        camera.Zoom = camera.Zoom - yoffset
    if camera.Zoom <= 1.0f:
        camera.Zoom = 1.0'f32
    elif camera.Zoom >= 45.0'f32:
        camera.Zoom = 45.0'f32
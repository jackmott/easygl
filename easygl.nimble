# Package

version       = "0.1.0"
author        = "Jack Mott"
description   = "type safe opengl wrapper"
license       = "MIT"

srcDir        = "src"

# Dependencies

requires "nim >= 0.17.0"
requires "sdl2"
requires "opengl"
requires "stb_image"
requires "glm"

task hello_triangle, "Runs hello triangle":
  exec "nim c -r examples/hello_triangle"

task shaders, "Runs shaders":
  exec "nim c -r examples/shaders"

task textures, "Runs textures":
  exec "nim c -r examples/textures"

task transformations, "Runs transformations":
  exec "nim c -r examples/transformations"

task coordinate_systems, "Runs coordinate systems":
  exec "nim c -r examples/coordinate_systems"


task camera, "Runs camera":
  exec "nim c -r examples/camera"
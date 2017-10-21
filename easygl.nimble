# Package

version       = "0.1.0"
author        = "Jack Mott"
description   = "type safe opengl wrapper"
license       = "MIT"

bin           = @["hello_triangle"]
srcDir        = "src"

# Dependencies

requires "nim >= 0.17.0"
requires "sdl2"
requires "opengl"
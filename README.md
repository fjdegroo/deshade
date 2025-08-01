# deshade

deshade is a library that allows you to dump and replace the shaders of
any OpenGL or Vulkan application, which includes: GL2 + extensions, GL3,
GL4, EGL, GLES2, GLES3, GLvnd, and Vulkan without recompiling the
application for Linux.

# Building
To build just run make. Can also install through make file
```
make
sudo make install
```

# Running
Deshade dumps an application's shaders to directory `deshade`. Shaders will
be replaced if shader file by same name as dumped shader is found in
`deshade/replace' directory.

## OpenGL
To dump and or replace the shaders of an OpenGL application, preload
the deshade shared object with `LD_PRELOAD` like so:

```
mkdir shaders
LD_PRELOAD=./deshade.so application
```

## Vulkan
To dump and or replace the shaders of a Vulkan application, the
`deshade.json` and `deshade.so` need to be installed as an implicit layer
with Vulkan inside `~/.local/share/vulkan/implicit_layer.d/` for the
current user. This is unnecessary if installing globally through makefile.
To modify shaders, will need both vulkan_sdk and spirv-cross installed.

To dump shaders to `deshade` directory:
```
VK_INSTANCE_LAYERS=VK_LAYER_deshade [application]
```

Once dumped, to modify and replace shader of name `123456_fs.spv`:
```
cd deshade/replace
spirv-cross ../123456_fs.spv --version 450 > 123456_fs.frag
#modify 123456_fs.frag file
glslangValidator -V 123456_fs.frag -o 123456_fs.spv
cd ../..

VK_INSTANCE_LAYERS=VK_LAYER_deshade [application]
```

The shaders will be written to the `deshade` directory, their names
will be the hash of their contents, with the following extension scheme:
`_vs.{glsl,spv}` for vertex shaders, `_fs.{glsl,spv}` for fragment shaders,
`_gs.{glsl,spv}` for geometry shaders, `_cs.{glsl,spv}` for compute shaders,
`_tcs.{glsl,spv}` for tesselleation control shaders and `_tes.{glsl,spv}`
for tesselation evaluation, and `_ks.spv` for Vulkan kernel shaders.

## Replacing Shaders
Modifying the contents of one of the dumpped shaders in the `deshade`
directory will take effect the next time the application is launched
with deshade.

## Debug Output
A debug log is also written to `deshade.txt` containing introspection
information, if deshade fails to work check this for more information.

# How it works

## OpenGL
There are several ways OpenGL can be loaded.

* application dlopens `libGL.so`
* application dlopens `libGLX_{vendor}.so`, where vendor can be `nvidia`, `intel`, `amd`, `mesa`, etc
* application fetches OpenGL functions with `glXGetProcAddress` or `glXGetProcAddressARB`
* application links directly with `-lGL`
  * this loads functions through GLX
  * or, this loads functions through `__glx_Main` imports if using `GLvnd`

deshade attempts to supplement all of these so that regardless of how
the application acquires an OpenGL context this should work.

## Vulkan
Vulkan standardized a mechanism for doing these things called layers,
deshade supplements some Vulkan functionality and and registers itself
through the layer interface.

# Known bugs
Applications which use multiple OpenGL contexts per thread may fail to
work due to the way deshade only maintains one set of function pointers
for the first context. Support for multiple contexts per thread would
require supplementing the `glXCreateContext`, `glXDestroyContext` and
`glXMakeCurrent` functions.

deshade exploits internal glibc dynamic linker functions to replace the
dynamic linker itself to handle any applications that get OpenGL
through `dlopen`, as a result this library is glibc specific and will
not work on BSDs or musl based distributions.

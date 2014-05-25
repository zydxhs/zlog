
INCLUDE(CMakeForceCompiler)

# the name of the target operating system
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR ia64)
set(LINKER_FLAGS "-Wl,--allow-multiple-definition -Wl,--itanium")
SET(CMAKE_INSTALL_PREFIX "/usr/local/${CMAKE_SYSTEM_PROCESSOR}-linux" CACHE STRING "" FORCE)

# which compilers to use for C and C++
SET(CMAKE_C_COMPILER ${CMAKE_SYSTEM_PROCESSOR}-linux-gcc)
SET(CMAKE_CXX_COMPILER ${CMAKE_SYSTEM_PROCESSOR}-linux-g++)

#SET(CMAKE_C_FLAGS "-std=gnu99" CACHE STRING "" FORCE)
SET(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "" FORCE)
SET(CMAKE_SHARED_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "" FORCE)
SET(CMAKE_MODULE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "" FORCE)

# here is the target environment located
SET(CMAKE_FIND_ROOT_PATH ${CMAKE_INSTALL_PREFIX})

# adjust the default behaviour of the FIND_XXX() commands:
# search headers and libraries in the target environment, search 
# programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)


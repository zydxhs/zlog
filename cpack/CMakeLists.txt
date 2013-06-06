# create by lsm <lsm@skybility.com>

#======================================
# vendor info
#======================================
SET(CPACK_PACKAGE_VENDOR "zlog")
SET(CPACK_PACKAGE_CONTACT "HardySimpson1984@gmail.com")
SET(CPACK_RPM_PACKAGE_LICENSE "LGPL")

#======================================
# default install prefix.
#======================================
SET(CPACK_PACKAGING_INSTALL_PREFIX "/usr/local")
SET(CPACK_RPM_PACKAGE_GROUP "System Environment/Base")

#=================================
# set platform.
#=================================
message(STATUS "system process is ${CMAKE_SYSTEM_PROCESSOR}")
IF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
    SET(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} MATCHES "powerpc64|ppc64")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE powerpc64)
    SET(CPACK_RPM_PACKAGE_ARCHITECTURE "ppc64")
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} MATCHES "powerpc|ppc")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE powerpc)
    SET(CPACK_RPM_PACKAGE_ARCHITECTURE "ppc")
ELSE()
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
    SET(CPACK_RPM_PACKAGE_ARCHITECTURE i386)
ENDIF()
SET(CPACK_SYSTEM_NAME  "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
SET(CPACK_TOPLEVEL_TAG "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")

#======================================
# generator setting.
#======================================
SET(CPACK_CMAKE_GENERATOR "Unix Makefiles")
SET(CPACK_GENERATOR "RPM;DEB")

#======================================
# package.
#======================================
add_subdirectory(zlog)

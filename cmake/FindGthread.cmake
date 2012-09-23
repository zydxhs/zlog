# - Try to find GThread2 
# Find GThread headers, libraries and the answer to all questions.
#
#  Gthread_FOUND               True if Gthread got found
#  Gthread_INCLUDE_DIRS        Location of Gthread headers 
#  Gthread_LIBRARIES           List of libraries to use Gthread 
#
#  Copyright (c) 2008 Bjoern Ricks <bjoern.ricks@googlemail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

INCLUDE( FindPkgConfig )

IF ( Gthread_FIND_REQUIRED )
	SET( _pkgconfig_REQUIRED "REQUIRED" )
ELSE( Gthread_FIND_REQUIRED )
	SET( _pkgconfig_REQUIRED "" )	
ENDIF ( Gthread_FIND_REQUIRED )

IF ( Gthread_MIN_VERSION )
	PKG_SEARCH_MODULE( Gthread ${_pkgconfig_REQUIRED} gthread-2.0>=${Gthread_MIN_VERSION} )
ELSE ( Gthread_MIN_VERSION )
	PKG_SEARCH_MODULE( Gthread ${_pkgconfig_REQUIRED} gthread-2.0 )
ENDIF ( Gthread_MIN_VERSION )


IF( NOT Gthread_FOUND AND NOT PKG_CONFIG_FOUND )
	FIND_PATH( Gthread_INCLUDE_DIRS gthread.h PATH_SUFFIXES glib-2.0/glib GLib.framework/Headers/glib )
	IF ( APPLE ) 
		FIND_LIBRARY( Gthread_LIBRARIES glib )
	ELSE ( APPLE )
		FIND_LIBRARY( Gthread_LIBRARIES gthread-2.0 )
	ENDIF ( APPLE )
	
	MESSAGE( STATUS "Gthread headers: ${Gthread_INCLUDE_DIRS}" )
	MESSAGE( STATUS "Gthread libs: ${Gthread_LIBRARIES}" )
	
	# Report results
	IF ( Gthread_LIBRARIES AND Gthread_INCLUDE_DIRS )	
		SET( Gthread_FOUND 1 )
		IF ( NOT Gthread_FIND_QUIETLY )
			MESSAGE( STATUS "Found Gthread: ${Gthread_LIBRARIES} ${Gthread_INCLUDE_DIRS}" )
		ENDIF ( NOT Gthread_FIND_QUIETLY )
	ELSE ( Gthread_LIBRARIES AND Gthread_INCLUDE_DIRS )	
		IF ( Gthread_FIND_REQUIRED )
			MESSAGE( SEND_ERROR "Could NOT find Gthread" )
		ELSE ( Gthread_FIND_REQUIRED )
			IF ( NOT Gthread_FIND_QUIETLY )
				MESSAGE( STATUS "Could NOT find Gthread" )	
			ENDIF ( NOT Gthread_FIND_QUIETLY )
		ENDIF ( Gthread_FIND_REQUIRED )
	ENDIF ( Gthread_LIBRARIES AND Gthread_INCLUDE_DIRS )
ENDIF( NOT Gthread_FOUND AND NOT PKG_CONFIG_FOUND )

MARK_AS_ADVANCED( Gthread_LIBRARIES Gthread_INCLUDE_DIRS )


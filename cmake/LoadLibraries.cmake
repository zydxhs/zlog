
#=======================================================
# support multi thread.
# usage:
# target_link_libraries(xxx ${CMAKE_THREAD_PREFER_PTHREAD})
#=======================================================
if(Need_THREAD)
find_package(Threads REQUIRED)
if(NOT CMAKE_THREAD_PREFER_PTHREAD) 
    set(CMAKE_THREAD_PREFER_PTHREAD ${CMAKE_THREAD_LIBS_INIT})
endif()
endif(Need_THREAD)


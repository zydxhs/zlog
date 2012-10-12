
#================================================================
# generate zlog lib
#================================================================
aux_source_directory(. SRCS)
list(REMOVE_ITEM SRCS ./zlog-chk-conf.c)

add_library(zlog
    SHARED
    ${SRCS}
    )
target_link_libraries(zlog
    ${CMAKE_THREAD_PREFER_PTHREAD}
    )
set_target_properties(zlog PROPERTIES VERSION ${zlog_ver} SOVERSION ${zlog_so_ver})

add_library(zlog_s
    STATIC
    ${SRCS}
    )
target_link_libraries(zlog_s 
    ${CMAKE_THREAD_PREFER_PTHREAD}
    )
set_target_properties(zlog_s PROPERTIES OUTPUT_NAME zlog)

#================================================================
# generate zlog-chk-conf
#================================================================
add_executable(zlog-chk-conf zlog-chk-conf.c)
target_link_libraries(zlog-chk-conf zlog)

#================================================================
# install
#================================================================
install(TARGETS 
    zlog zlog_s zlog-chk-conf
    COMPONENT zlog
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    )

install(FILES
    zlog.h
    COMPONENT zlog
    DESTINATION include
    )

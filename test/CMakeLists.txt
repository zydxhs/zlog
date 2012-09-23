
include_directories("${CMAKE_HOME_DIRECTORY}/src")

file(GLOB SRCS . *.c) 
set(not_auto_add_test 
    test_hello
    test_bitmap
    test_hex
    test_leak
    test_press_syslog
    test_press_write
    test_press_write2
    test_press_zlog
    test_press_zlog2
    test_syslog
    )

foreach(test_src ${SRCS})
    string(REGEX MATCH "^.*/([^/]+)[.]c$" test_name ${test_src})
    set(test_name ${CMAKE_MATCH_1})

    message(STATUS "${test_name} ${test_src}")

    add_executable("${test_name}" "${test_src}")
    target_link_libraries(${test_name} zlog)

    list(FIND not_auto_add_test ${test_name} not_auto_test)
    if (not_auto_test EQUAL -1)
        add_test("${test_name}" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${test_name}")
    endif()
endforeach(test_src)

add_test(test_hello "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test_hello" hello_output 3)
add_test(test_bitmap "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test_bitmap" 0xaa55 0x66)

file(GLOB CONF_FILES . *.conf) 
file(COPY
    ${CONF_FILES} hello_output
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )


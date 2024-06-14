cmake_minimum_required(VERSION 3.4.1)

add_library(
    hash-lib
    SHARED
    hash.c
)

target_include_directories(
    hash-lib
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    /usr/bin/openssl
)

target_link_libraries(
        hash-lib
        PRIVATE
        ssl
        crypto
)
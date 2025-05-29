cmake_minimum_required(VERSION 3.5.0)

# Force iOS as CMAKE_SYSTEM_NAME again to ensure it's not changed
set(CMAKE_SYSTEM_NAME iOS CACHE STRING "iOS System Name" FORCE)

project(AVEngine)

# Enable Objective-C++ support
enable_language(OBJCXX)

# Option to choose between simulator and device
set(IOS_PLATFORM "DEVICE" CACHE STRING "iOS platform (SIMULATOR or DEVICE)")
set(IOS_DEPLOYMENT_TARGET "18.4" CACHE STRING "iOS deployment target version")
message(STATUS "CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT}")
message(STATUS "IOS_PLATFORM: ${IOS_PLATFORM}")

if(IOS_PLATFORM STREQUAL "SIMULATOR")
    set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "iphonesimulator")
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
    add_compile_options(-target arm64-apple-ios${IOS_DEPLOYMENT_TARGET}-simulator)
    add_link_options(-target arm64-apple-ios${IOS_DEPLOYMENT_TARGET}-simulator)
else()
    set(CMAKE_OSX_ARCHITECTURES "arm64")
endif()

set(CMAKE_C_FLAGS "-fPIC -ffast-math -Wno-deprecated-declarations")
set(CMAKE_CXX_FLAGS "-std=c++2b -fPIC -ffast-math -Wno-deprecated-declarations")
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")

# Use arm64 for both simulator and device
set(CMAKE_OSX_ARCHITECTURES "arm64")
set(CMAKE_OSX_DEPLOYMENT_TARGET ${IOS_DEPLOYMENT_TARGET})
set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET ${IOS_DEPLOYMENT_TARGET})
set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "YES")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++17")
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")

# Enable Objective-C++ support
set(CMAKE_OBJCXX_EXTENSION ".mm")
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD_REQUIRED ON)

# Set additional properties for building a framework
set(CMAKE_MACOSX_RPATH 1)
set(BUILD_SHARED_LIBS ON)
set(CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "")

add_definitions(-DOS_IOS)

set(ROOT_DIR ${CMAKE_SOURCE_DIR})
set(SRC_DIR ${ROOT_DIR})
set(LIB_DIR ${ROOT_DIR}/lib)

include_directories(
    ${ROOT_DIR}/include
    ${ROOT_DIR}/include/ffmpeg
)

# Create header list for public API
set(PUBLIC_HEADERS
    ${SRC_DIR}/AVEngine.h
)

# Create framework target
add_library(${PROJECT_NAME} SHARED
    ${SRC_DIR}/AVEngine.cpp
    ${SRC_DIR}/AVEngine.mm
)

# Set framework properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    FRAMEWORK TRUE
    FRAMEWORK_VERSION A
    MACOSX_FRAMEWORK_IDENTIFIER com.hui.AVEngine
    VERSION 1.0.0
    SOVERSION 1.0.0
    PUBLIC_HEADER "${PUBLIC_HEADERS}"
    XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
    XCODE_ATTRIBUTE_SKIP_INSTALL "NO"
    XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
    XCODE_ATTRIBUTE_DEFINES_MODULE "YES"
    XCODE_ATTRIBUTE_CLANG_ENABLE_MODULES "YES"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
)

target_link_libraries(${PROJECT_NAME}
    ${LIB_DIR}/libffmpeg_all.a
    ${LIB_DIR}/libiconv.a
    ${LIB_DIR}/libbluray.a
    ${LIB_DIR}/libcrypto.a
    ${LIB_DIR}/libdav1d.a
    ${LIB_DIR}/libdvdread.a
    ${LIB_DIR}/libopus.a
    ${LIB_DIR}/libsmb2.a
    ${LIB_DIR}/libssl.a
    ${LIB_DIR}/libuavs3d.a
    ${LIB_DIR}/libxml2.a
    z
    c
    bz2
    "-framework Foundation"
    "-framework OpenGLES"
    "-framework CoreGraphics"
    "-framework IOKit"
    "-framework CoreFoundation"
    "-framework UIKit"
    "-framework QuartzCore"
    "-framework AudioToolbox"
    "-framework CoreMedia"
    "-framework CoreVideo"
    "-framework Security"
    "-framework VideoToolbox"
    "-framework CoreText"
    "-liconv")

# Copy module.modulemap to the Modules directory
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/Headers
    COMMAND ${CMAKE_COMMAND} -E copy
        ${SRC_DIR}/AVEngine.h
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/Headers/
    COMMAND ${CMAKE_COMMAND} -E make_directory
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/Modules
    COMMAND ${CMAKE_COMMAND} -E copy
        ${SRC_DIR}/module.modulemap
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/Modules/module.modulemap
)

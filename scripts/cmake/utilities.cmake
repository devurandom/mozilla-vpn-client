
# Sets Defaults like `-Wall -Werror` if we know it will not
# explode on that target + compiler
function(mz_target_handle_warnings MZ_TARGET)
    if(MSVC OR IOS)
        return()
    endif()
    # Just don't for wasm
    if( ${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
        return()
    endif()
    # Check if the target is an interface lib
    get_target_property(target_type ${MZ_TARGET} TYPE)
    if (${target_type} STREQUAL "INTERFACE_LIBRARY")
        set(scope "INTERFACE")
    else()
        set(scope "PRIVATE")
    endif()

    target_compile_options( ${MZ_TARGET} ${scope} -Wall -Werror -Wno-conversion)
endfunction()

# MZ_ADD_NEW_MODULE: A utility function for adding a new module to this project.
#
# Usage:
# MZ_ADD_NEW_MODULE(
#     TARGET_NAME <target_name>
#     [INCLUDE_DIRECTORIES <include_directories>]
#     [GENERATED_SOURCES <generated_sources>]
#     [SOURCES <sources>]
#     [IOS_SOURCES <ios_sources>]
#     [ANDROID_SOURCES <android_sources>]
#     [MACOS_SOURCES <macos_sources>]
#     [LINUX_SOURCES <linux_sources>]
#     [WINDOWS_SOURCES <windows_sources>]
#     [WASM_SOURCES <wasm_sources>]
#     [DUMMY_SOURCES <dummy_sources>]
#     [TEST_SOURCES <test_sources>]
#     [QT_DEPENDENCIES <qt_dependencies>]
#     [MZ_DEPENDENCIES <mz_dependencies>]
#     [RUST_DEPENDENCIES <rust_dependencies>]
#     [EXTRA_DEPENDENCIES <extra_dependencies>]
#     [TEST_DEPENDENCIES <test_dependencies>]
# )
#
# Parameters:
# - TARGET_NAME: The name of the target module.
# - INCLUDE_DIRECTORIES: (Optional) List of additional include directories for the module.
# - GENERATED_SOURCES: (Optional) List of generated source files for the module.
# - SOURCES: (Optional) List of source files for the module.
# - IOS_SOURCES: (Optional) List of iOS-specific source files for the module.
# - ANDROID_SOURCES: (Optional) List of Android-specific source files for the module.
# - MACOS_SOURCES: (Optional) List of macOS-specific source files for the module.
# - LINUX_SOURCES: (Optional) List of Linux-specific source files for the module.
# - WINDOWS_SOURCES: (Optional) List of Windows-specific source files for the module.
# - WASM_SOURCES: (Optional) List of WebAssembly-specific source files for the module.
# - DUMMY_SOURCES: (Optional) List of dummy sources for the module.
# - TEST_SOURCES: (Optional) List of test source files for the module.
# - QT_DEPENDENCIES: (Optional) List of Qt dependencies for the module.
# - MZ_DEPENDENCIES: (Optional) List of custom module dependencies for the module.
# - RUST_DEPENDENCIES: (Optional) List of Rust dependencies for the module.
# - EXTRA_DEPENDENCIES: (Optional) List of additional dependencies for the module.
# - TEST_DEPENDENCIES: (Optional) List of test-only dependencies.
#   If the name of the dependency starts with `replace-<targetname>`
#   it will replace <targetname> dependency for tests.
#
# Example:
# MZ_ADD_NEW_MODULE(
#     TARGET_NAME MyModule
#     INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include
#     GENERATED_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/generated_sources.cpp
#     SOURCES src/file1.cpp src/file2.cpp
#     TEST_SOURCES tests/test_file.cpp
#     MZ_DEPENDENCIES mz_module
# )
function(mz_add_new_module)
    cmake_parse_arguments(
        MZ_ADD_NEW_MODULE # prefix
        "" # options
        "" # single-value args
        "TARGET_NAME;INCLUDE_DIRECTORIES;GENERATED_SOURCES;SOURCES;IOS_SOURCES;ANDROID_SOURCES;MACOS_SOURCES;LINUX_SOURCES;WINDOWS_SOURCES;WASM_SOURCES;EXTRA_DEPENDENCIES;DUMMY_SOURCES;TEST_SOURCES;QT_DEPENDENCIES;MZ_DEPENDENCIES;RUST_DEPENDENCIES;TEST_DEPENDENCIES" # multi-value args
        ${ARGN})

    # Create a target for the new module
    add_library(${MZ_ADD_NEW_MODULE_TARGET_NAME} STATIC)
    mz_target_handle_warnings(${MZ_ADD_NEW_MODULE_TARGET_NAME})
    target_compile_definitions(${MZ_ADD_NEW_MODULE_TARGET_NAME} PRIVATE
        "MZ_$<UPPER_CASE:${MZ_PLATFORM_NAME}>"
        "$<$<CONFIG:Debug>:MZ_DEBUG>"
    )

    # Get list of required Qt dependencies
    find_package(Qt6 REQUIRED COMPONENTS ${MZ_ADD_NEW_MODULE_QT_DEPENDENCIES})
    set(QT_LINK_LIBRARIES)
    foreach(QT_DEPENDENCY ${MZ_ADD_NEW_MODULE_QT_DEPENDENCIES})
        list(APPEND QT_LINK_LIBRARIES "Qt6::${QT_DEPENDENCY}")
    endforeach()

    # Build Rust creates and add to list of linkd targets.
    foreach(RUST_CRATE_PATH ${MZ_ADD_NEW_MODULE_RUST_DEPENDENCIES})
        # The name of the crate target is expected to be the name of the crate folder
        get_filename_component(CRATE_NAME ${RUST_CRATE_PATH} NAME)

        include(${CMAKE_SOURCE_DIR}/scripts/cmake/rustlang.cmake)
        add_rust_library(${CRATE_NAME}
            PACKAGE_DIR ${RUST_CRATE_PATH}
            BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}
            CRATE_NAME ${CRATE_NAME}
        )

        list(APPEND MZ_ADD_NEW_MODULE_EXTRA_DEPENDENCIES ${CRATE_NAME})
    endforeach()

    set(ALL_DEPENDENCIES
        ${QT_LINK_LIBRARIES}
        ${MZ_ADD_NEW_MODULE_MZ_DEPENDENCIES}
        ${MZ_ADD_NEW_MODULE_EXTRA_DEPENDENCIES}
    )
    target_link_libraries(${MZ_ADD_NEW_MODULE_TARGET_NAME}
        PRIVATE ${ALL_DEPENDENCIES}
    )
    # Expose to linking libraries, what are the dependencies.
    set_property(TARGET ${MZ_ADD_NEW_MODULE_TARGET_NAME} APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES ${ALL_DEPENDENCIES}
    )

    target_include_directories(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
        ${MZ_ADD_NEW_MODULE_INCLUDE_DIRECTORIES}
    )

    # Set the sources
    target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC
        ${MZ_ADD_NEW_MODULE_SOURCES}
    )
    if(${MZ_PLATFORM_NAME} STREQUAL "ios")
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_IOS_SOURCES})
    elseif(${MZ_PLATFORM_NAME} STREQUAL "android")
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_ANDROID_SOURCES})
    elseif(${MZ_PLATFORM_NAME} STREQUAL "macos")
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_MACOS_SOURCES})
    elseif(${MZ_PLATFORM_NAME} STREQUAL "linux")
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_LINUX_SOURCES})
    elseif(${MZ_PLATFORM_NAME} STREQUAL "windows")
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_WINDOWS_SOURCES})
    elseif(${MZ_PLATFORM_NAME} STREQUAL "wasm")
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_WASM_SOURCES})
    else()
        target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_DUMMY_SOURCES})
    endif()

    # Create separate targets for each test,
    # one target that builds all tests from this module
    # and finally add this module's tests to the build_tests target which builds all tests.
    if(MZ_ADD_NEW_MODULE_TEST_SOURCES)
        find_package(Qt6 REQUIRED COMPONENTS Test)
        add_custom_target(${MZ_ADD_NEW_MODULE_TARGET_NAME}-alltests)
        set_target_properties(${MZ_ADD_NEW_MODULE_TARGET_NAME}-alltests PROPERTIES
            EXCLUDE_FROM_ALL TRUE
        )

        add_dependencies(build_tests ${MZ_ADD_NEW_MODULE_TARGET_NAME}-alltests)

        set(CPP_TEST_FILES ${MZ_ADD_NEW_MODULE_TEST_SOURCES})
        set(QRC_TEST_FILES ${MZ_ADD_NEW_MODULE_TEST_SOURCES})

        # Generate list of test dependencies
        set(ALL_DEPENDENCIES_WITHOUT_REPLACED ${ALL_DEPENDENCIES})
        set(REPLACER_DEPENDENCIES ${MZ_ADD_NEW_MODULE_TEST_DEPENDENCIES})
        list(FILTER REPLACER_DEPENDENCIES INCLUDE REGEX "^\\r\\e\\p\\l\\a\\c\\e\\-")
        foreach(REPLACER_DEPENDENCY ${REPLACER_DEPENDENCIES})
            # Get the name of the original dependency
            string(REPLACE "replace-" "" ORIGINAL_DEPENDENCY ${REPLACER_DEPENDENCY})
            # Remove it  from the list
            list(REMOVE_ITEM ALL_DEPENDENCIES_WITHOUT_REPLACED ${ORIGINAL_DEPENDENCY})
        endforeach()

        list(FILTER QRC_TEST_FILES INCLUDE REGEX "(.*)\\q\\r\\c$")
        list(FILTER CPP_TEST_FILES INCLUDE REGEX "(.*)\\c\\p\\p$")
        foreach(TEST_FILE ${CPP_TEST_FILES})
            # The test executable name will be the name of the test file
            # + the name of the parent target as a prefix.
            get_filename_component(TEST_NAME ${TEST_FILE} NAME_WE)
            set(TEST_TARGET_NAME "${MZ_ADD_NEW_MODULE_TARGET_NAME}-${TEST_NAME}")

            mz_add_test_target(
                TARGET_NAME
                    ${TEST_TARGET_NAME}
                TEST_COMMAND
                    ${TEST_TARGET_NAME}
                PARENT_TARGET
                    ${MZ_ADD_NEW_MODULE_TARGET_NAME}
                SOURCES
                    ${TEST_FILE}
                    ${QRC_TEST_FILES}
                    ${MZ_ADD_NEW_MODULE_SOURCES}
                DEPENDENCIES
                    ${ALL_DEPENDENCIES_WITHOUT_REPLACED}
                    ${MZ_ADD_NEW_MODULE_TEST_DEPENDENCIES}
            )

            get_filename_component(TEST_DIRECTORY ${TEST_FILE} DIRECTORY)
            target_include_directories(${TEST_TARGET_NAME} PRIVATE
                ${CMAKE_CURRENT_SOURCE_DIR}
                ${CMAKE_CURRENT_BINARY_DIR}
                ${CMAKE_SOURCE_DIR}/src
                ${TEST_DIRECTORY}
            )

            # Check if the corresponding header file exists
            string(REGEX REPLACE ".cpp$" ".h" HEADER_FILE ${TEST_FILE})
            if(EXISTS ${HEADER_FILE})
                # Add the header file to the executable if it exists.
                target_sources(${TEST_TARGET_NAME} PRIVATE ${TEST_FILE})
            endif()
        endforeach()
    endif()
endfunction()

function(mz_add_test_target)
    cmake_parse_arguments(
        MZ_ADD_TEST # prefix
        "" # options
        "" # single-value args
        "TARGET_NAME;TEST_COMMAND;PARENT_TARGET;SOURCES;DEPENDENCIES" # multi-value args
        ${ARGN})

    # Test targets are executable targets.
    qt_add_executable(${MZ_ADD_TEST_TARGET_NAME}
        ${MZ_ADD_TEST_SOURCES}
    )
    set_target_properties(${MZ_ADD_TEST_TARGET_NAME} PROPERTIES
        EXCLUDE_FROM_ALL TRUE
    )

    add_test(
        NAME ${MZ_ADD_TEST_TARGET_NAME}
        COMMAND ${MZ_ADD_TEST_TEST_COMMAND}
    )

    target_compile_definitions(${MZ_ADD_TEST_TARGET_NAME} PRIVATE
        UNIT_TEST
        "MZ_$<UPPER_CASE:${MZ_PLATFORM_NAME}>"
        "$<$<CONFIG:Debug>:MZ_DEBUG>"
    )

    add_dependencies(${MZ_ADD_TEST_PARENT_TARGET}-alltests ${MZ_ADD_TEST_TARGET_NAME})

    target_link_libraries(${MZ_ADD_TEST_TARGET_NAME} PRIVATE Qt6::Test)
    target_link_libraries(${MZ_ADD_TEST_TARGET_NAME} PUBLIC ${MZ_ADD_TEST_DEPENDENCIES})
endfunction()

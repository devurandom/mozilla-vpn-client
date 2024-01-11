
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

# Creates a new module.
#
# This function assumes ${MZ_PLATFORM_NAME} is set in the environment.
function(mz_add_new_module)
    cmake_parse_arguments(
        MZ_ADD_NEW_MODULE # prefix
        "" # options
        "" # single-value args
        "TARGET_NAME;INCLUDE_DIRECTORIES;SOURCES;IOS_SOURCES;ANDROID_SOURCES;MACOS_SOURCES;LINUX_SOURCES;WINDOWS_SOURCES;WASM_SOURCES;EXTRA_DEPENDENCIES;DUMMY_SOURCES;TEST_SOURCES;QT_DEPENDENCIES;MZ_DEPENDENCIES;RUST_DEPENDENCIES;" # multi-value args
        ${ARGN})

    # Create a target for the new module
    add_library(${MZ_ADD_NEW_MODULE_TARGET_NAME} STATIC)
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

    target_link_libraries(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC
        ${QT_LINK_LIBRARIES}
        ${MZ_ADD_NEW_MODULE_MZ_DEPENDENCIES}
        ${MZ_ADD_NEW_MODULE_EXTRA_DEPENDENCIES}
    )

    target_include_directories(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
        ${MZ_ADD_NEW_MODULE_INCLUDE_DIRECTORIES}
    )

    # Set the sources
    target_sources(${MZ_ADD_NEW_MODULE_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_SOURCES})
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

        set(CPP_ONLY_SOURCES ${MZ_ADD_NEW_MODULE_TEST_SOURCES})
        list(FILTER CPP_ONLY_SOURCES INCLUDE REGEX "(.*)\\c\\p\\p$")
        foreach(TEST_FILE ${CPP_ONLY_SOURCES})
            # The test executable name will be the name of the test file
            # + the name of the parent target as a prefix.
            get_filename_component(TEST_NAME ${TEST_FILE} NAME_WE)
            set(TEST_TARGET_NAME "${MZ_ADD_NEW_MODULE_TARGET_NAME}-${TEST_NAME}")

            # Create a separate executable per test.
            qt_add_executable(${TEST_TARGET_NAME} ${TEST_FILE})
            set_target_properties(${TEST_TARGET_NAME} PROPERTIES
                EXCLUDE_FROM_ALL TRUE
            )

            target_compile_definitions(${TEST_TARGET_NAME} PRIVATE
                UNIT_TEST
                "MZ_$<UPPER_CASE:${MZ_PLATFORM_NAME}>"
                "$<$<CONFIG:Debug>:MZ_DEBUG>"
            )

            # Add this executable to the <target>-alltests executable
            add_dependencies(${MZ_ADD_NEW_MODULE_TARGET_NAME}-alltests ${TEST_TARGET_NAME})

            target_link_libraries(${TEST_TARGET_NAME} PRIVATE Qt6::Test)
            target_link_libraries(${TEST_TARGET_NAME} PUBLIC ${MZ_ADD_NEW_MODULE_TARGET_NAME})

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

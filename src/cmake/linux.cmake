# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

option(BUILD_FLATPAK "Build for Flatpak distribution" OFF)

find_package(Qt6 REQUIRED COMPONENTS DBus)
target_link_libraries(mozillavpn PRIVATE Qt6::DBus)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libsecret REQUIRED IMPORTED_TARGET libsecret-1)
target_link_libraries(mozillavpn PRIVATE PkgConfig::libsecret)

# Linux platform source files
target_sources(mozillavpn PRIVATE
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/backendlogsobserver.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/backendlogsobserver.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxappimageprovider.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxappimageprovider.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxapplistprovider.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxapplistprovider.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxdependencies.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxdependencies.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxnetworkwatcher.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxnetworkwatcher.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxnetworkwatcherworker.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxnetworkwatcherworker.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxpingsender.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxpingsender.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxsystemtraynotificationhandler.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxsystemtraynotificationhandler.h
)

if(NOT BUILD_FLATPAK)
    pkg_check_modules(libcap REQUIRED IMPORTED_TARGET libcap)
    target_link_libraries(mozillavpn PRIVATE PkgConfig::libcap)

    target_sources(mozillavpn PRIVATE
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxcontroller.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxcontroller.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/dbusclient.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/dbusclient.h
    )

    # Linux daemon source files
    target_sources(mozillavpn PRIVATE
        ${CMAKE_SOURCE_DIR}/3rdparty/wireguard-tools/contrib/embeddable-wg-library/wireguard.c
        ${CMAKE_SOURCE_DIR}/3rdparty/wireguard-tools/contrib/embeddable-wg-library/wireguard.h
        ${CMAKE_SOURCE_DIR}/src/daemon/daemon.cpp
        ${CMAKE_SOURCE_DIR}/src/daemon/daemon.h
        ${CMAKE_SOURCE_DIR}/src/daemon/dnsutils.h
        ${CMAKE_SOURCE_DIR}/src/daemon/iputils.h
        ${CMAKE_SOURCE_DIR}/src/daemon/wireguardutils.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/apptracker.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/apptracker.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/dbusservice.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/dbusservice.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/dbustypeslinux.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/dnsutilslinux.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/dnsutilslinux.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/iputilslinux.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/iputilslinux.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/linuxdaemon.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/wireguardutilslinux.cpp
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/wireguardutilslinux.h
    )

    target_compile_options(mozillavpn PRIVATE -DPROTOCOL_VERSION=\"1\")

    set(DBUS_GENERATED_SOURCES)
    qt_add_dbus_interface(DBUS_GENERATED_SOURCES
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/org.mozilla.vpn.dbus.xml dbus_interface)
    qt_add_dbus_adaptor(DBUS_GENERATED_SOURCES
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/org.mozilla.vpn.dbus.xml
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/dbusservice.h
        ""
        dbus_adaptor)
    target_sources(mozillavpn PRIVATE ${DBUS_GENERATED_SOURCES})

    include(${CMAKE_SOURCE_DIR}/scripts/cmake/golang.cmake)
    add_go_library(netfilter ${CMAKE_SOURCE_DIR}/linux/netfilter/netfilter.go)
    target_link_libraries(mozillavpn PRIVATE netfilter)
else()
    # Linux source files for sandboxed builds
    target_compile_definitions(mozillavpn PRIVATE MZ_FLATPAK)

    # Network Manager controller - experimental
    pkg_check_modules(libnm REQUIRED IMPORTED_TARGET libnm)
    target_link_libraries(mozillavpn PRIVATE PkgConfig::libnm)
    target_sources(mozillavpn PRIVATE
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/networkmanagercontroller.h
        ${CMAKE_SOURCE_DIR}/src/platforms/linux/networkmanagercontroller.cpp
    )
endif()
include(GNUInstallDirs)
install(TARGETS mozillavpn)

configure_file(${CMAKE_SOURCE_DIR}/linux/extra/org.mozilla.vpn.desktop.in
    ${CMAKE_CURRENT_BINARY_DIR}/org.mozilla.vpn.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.mozilla.vpn.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)

install(FILES ${CMAKE_SOURCE_DIR}/linux/extra/icons/16x16/mozillavpn.png
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/16x16/apps)

install(FILES ${CMAKE_SOURCE_DIR}/linux/extra/icons/32x32/mozillavpn.png
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/32x32/apps)

install(FILES ${CMAKE_SOURCE_DIR}/linux/extra/icons/48x48/mozillavpn.png
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps)

add_definitions(-DMVPN_ICON_PATH=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/icons/hicolor/64x64/apps/mozillavpn.png\")
install(FILES ${CMAKE_SOURCE_DIR}/linux/extra/icons/64x64/mozillavpn.png
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/64x64/apps)

install(FILES ${CMAKE_SOURCE_DIR}/linux/extra/icons/128x128/mozillavpn.png
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/128x128/apps)

if(NOT BUILD_FLATPAK)
    ## TODO: We need another solution for sandboxed applications to request
    ## startup at boot. See "org.freedesktop.portal.Background" for the portal
    ## to use for this.
    configure_file(${CMAKE_SOURCE_DIR}/linux/extra/org.mozilla.vpn-startup.desktop.in
        ${CMAKE_CURRENT_BINARY_DIR}/org.mozilla.vpn-startup.desktop)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.mozilla.vpn-startup.desktop
        DESTINATION /etc/xdg/autostart)

    install(FILES ${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/org.mozilla.vpn.conf
        DESTINATION /usr/share/dbus-1/system.d)

    configure_file(${CMAKE_SOURCE_DIR}/src/platforms/linux/daemon/org.mozilla.vpn.dbus.service.in
        ${CMAKE_CURRENT_BINARY_DIR}/org.mozilla.vpn.dbus.service)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.mozilla.vpn.dbus.service
        DESTINATION /usr/share/dbus-1/system-services)

    pkg_check_modules(SYSTEMD systemd)
    if("${SYSTEMD_FOUND}" EQUAL 1)
        pkg_get_variable(SYSTEMD_UNIT_DIR systemd systemdsystemunitdir)
    else()
        set(SYSTEMD_UNIT_DIR /lib/systemd/system)
    endif()
    configure_file(${CMAKE_SOURCE_DIR}/linux/mozillavpn.service.in
        ${CMAKE_CURRENT_BINARY_DIR}/mozillavpn.service)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/mozillavpn.service
        DESTINATION ${SYSTEMD_UNIT_DIR})
endif()

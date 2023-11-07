# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

find_package(PkgConfig REQUIRED)
pkg_check_modules(libsecret REQUIRED IMPORTED_TARGET libsecret-1)
pkg_check_modules(libcap REQUIRED IMPORTED_TARGET libcap)
target_link_libraries(mozillavpn PRIVATE PkgConfig::libsecret PkgConfig::libcap)
target_link_libraries(mozillavpn PRIVATE PkgConfig::libsecret)

# Linux platform source files
target_sources(mozillavpn PRIVATE
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/backendlogsobserver.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/backendlogsobserver.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/dbusclient.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/dbusclient.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxappimageprovider.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxappimageprovider.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxapplistprovider.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxapplistprovider.h
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxcontroller.cpp
    ${CMAKE_SOURCE_DIR}/src/platforms/linux/linuxcontroller.h
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

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/daemon)
target_link_libraries(mozillavpn PRIVATE mozillavpn_daemon)

include(${CMAKE_SOURCE_DIR}/scripts/cmake/golang.cmake)
add_go_library(netfilter ${CMAKE_SOURCE_DIR}/linux/netfilter/netfilter.go)
target_link_libraries(mozillavpn PRIVATE netfilter)

include(GNUInstallDirs)
install(TARGETS mozillavpn)

configure_file(${CMAKE_SOURCE_DIR}/linux/extra/mozillavpn.desktop.in
    ${CMAKE_CURRENT_BINARY_DIR}/mozillavpn.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/mozillavpn.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)

configure_file(${CMAKE_SOURCE_DIR}/linux/extra/mozillavpn-startup.desktop.in
    ${CMAKE_CURRENT_BINARY_DIR}/mozillavpn-startup.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/mozillavpn-startup.desktop
    DESTINATION /etc/xdg/autostart)

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

install(FILES ${CMAKE_SOURCE_DIR}/src/daemon/platforms/linux/org.mozilla.vpn.conf
    DESTINATION /usr/share/dbus-1/system.d)

configure_file(${CMAKE_SOURCE_DIR}/src/daemon/platforms/linux/org.mozilla.vpn.dbus.service.in
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

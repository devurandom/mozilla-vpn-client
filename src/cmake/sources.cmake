# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Group the core client sources together into an interface library.
# This allows us to pull them into multiple builds like the dummy client.
add_library(mozillavpn-sources INTERFACE)

if(NOT MSVC AND NOT IOS)
  target_compile_options(mozillavpn-sources INTERFACE -Wall -Werror -Wno-conversion)
endif()

# VPN client include paths
set_property(TARGET mozillavpn-sources PROPERTY INTERFACE_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/addons
    ${CMAKE_CURRENT_SOURCE_DIR}/composer
    ${CMAKE_CURRENT_SOURCE_DIR}/hacl-star
    ${CMAKE_CURRENT_SOURCE_DIR}/hacl-star/kremlin
    ${CMAKE_CURRENT_SOURCE_DIR}/hacl-star/kremlin/minimal
    ${CMAKE_CURRENT_SOURCE_DIR}/glean
    ${CMAKE_CURRENT_BINARY_DIR}
)

# VPN Client source files
target_sources(mozillavpn-sources INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/accessiblenotification.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/featurelistcallback.h
    ${CMAKE_CURRENT_SOURCE_DIR}/featurelist.h
    ${CMAKE_CURRENT_SOURCE_DIR}/appimageprovider.h
    ${CMAKE_CURRENT_SOURCE_DIR}/applistprovider.h
    ${CMAKE_CURRENT_SOURCE_DIR}/apppermission.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/apppermission.h
    ${CMAKE_CURRENT_SOURCE_DIR}/settingslist.h
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportal.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportal.h
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportaldetection.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportaldetection.h
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportaldetectionimpl.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportaldetectionimpl.h
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportalnotifier.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportalnotifier.h
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportalrequest.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportalrequest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportalrequesttask.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/captiveportal/captiveportalrequesttask.h
    ${CMAKE_CURRENT_SOURCE_DIR}/command.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/command.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commandlineparser.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commandlineparser.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandactivate.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandactivate.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commanddeactivate.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commanddeactivate.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commanddevice.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commanddevice.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandexcludeip.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandexcludeip.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandlogin.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandlogin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandlogout.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandlogout.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandselect.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandselect.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandservers.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandservers.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandstatus.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandstatus.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandui.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandui.h
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandwgconf.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/commands/commandwgconf.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktask.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktask.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktaskping.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktaskping.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktasksentinel.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktasktransfer.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/benchmarktasktransfer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/connectionbenchmark.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/connectionbenchmark.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/uploaddatagenerator.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionbenchmark/uploaddatagenerator.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionhealth.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionhealth.h
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionmanager.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/connectionmanager.h
    ${CMAKE_CURRENT_SOURCE_DIR}/constants.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/constants.h
    ${CMAKE_CURRENT_SOURCE_DIR}/controller.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/controller.h
    ${CMAKE_CURRENT_SOURCE_DIR}/controllerimpl.h
    ${CMAKE_CURRENT_SOURCE_DIR}/dnshelper.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/dnshelper.h
    ${CMAKE_CURRENT_SOURCE_DIR}/dnspingsender.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/dnspingsender.h
    ${CMAKE_CURRENT_SOURCE_DIR}/extrastrings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/imageproviderfactory.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imageproviderfactory.h
    ${CMAKE_CURRENT_SOURCE_DIR}/interfaceconfig.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/interfaceconfig.h
    ${CMAKE_CURRENT_SOURCE_DIR}/ipaddresslookup.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/ipaddresslookup.h
    ${CMAKE_CURRENT_SOURCE_DIR}/keyregenerator.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/keyregenerator.h
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/device.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/device.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/devicemodel.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/devicemodel.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/keys.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/keys.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/location.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/location.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/recentconnections.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/recentconnections.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/recommendedlocationmodel.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/recommendedlocationmodel.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/server.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/server.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/servercity.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/servercity.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/servercountry.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/servercountry.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/servercountrymodel.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/servercountrymodel.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/serverdata.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/serverdata.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/subscriptiondata.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/subscriptiondata.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/supportcategorymodel.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/supportcategorymodel.h
    ${CMAKE_CURRENT_SOURCE_DIR}/models/user.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/models/user.h
    ${CMAKE_CURRENT_SOURCE_DIR}/mozillavpn_p.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/mozillavpn_p.h
    ${CMAKE_CURRENT_SOURCE_DIR}/mozillavpn.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/mozillavpn.h
    ${CMAKE_CURRENT_SOURCE_DIR}/networkwatcher.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/networkwatcher.h
    ${CMAKE_CURRENT_SOURCE_DIR}/networkwatcherimpl.h
    ${CMAKE_CURRENT_SOURCE_DIR}/notificationhandler.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/notificationhandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/pinghelper.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/pinghelper.h
    ${CMAKE_CURRENT_SOURCE_DIR}/pingsender.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/pingsender.h
    ${CMAKE_CURRENT_SOURCE_DIR}/pingsenderfactory.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/pingsenderfactory.h
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/dummy/dummyapplistprovider.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/dummy/dummyapplistprovider.h
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/dummy/dummynetworkwatcher.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/dummy/dummynetworkwatcher.h
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/dummy/dummypingsender.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/dummy/dummypingsender.h
    ${CMAKE_CURRENT_SOURCE_DIR}/productshandler.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/productshandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/profileflow.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/profileflow.h
    ${CMAKE_CURRENT_SOURCE_DIR}/purchasehandler.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/purchasehandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/purchaseiaphandler.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/purchaseiaphandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/purchasewebhandler.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/purchasewebhandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/releasemonitor.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/releasemonitor.h
    ${CMAKE_CURRENT_SOURCE_DIR}/serveri18n.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/serveri18n.h
    ${CMAKE_CURRENT_SOURCE_DIR}/serverlatency.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/serverlatency.h
    ${CMAKE_CURRENT_SOURCE_DIR}/settingswatcher.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/settingswatcher.h
    ${CMAKE_CURRENT_SOURCE_DIR}/statusicon.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/statusicon.h
    ${CMAKE_CURRENT_SOURCE_DIR}/subscriptionmonitor.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/subscriptionmonitor.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/account/taskaccount.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/account/taskaccount.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/adddevice/taskadddevice.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/adddevice/taskadddevice.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/captiveportallookup/taskcaptiveportallookup.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/captiveportallookup/taskcaptiveportallookup.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/controlleraction/taskcontrolleraction.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/controlleraction/taskcontrolleraction.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/createsupportticket/taskcreatesupportticket.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/createsupportticket/taskcreatesupportticket.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/getlocation/taskgetlocation.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/getlocation/taskgetlocation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/getsubscriptiondetails/taskgetsubscriptiondetails.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/getsubscriptiondetails/taskgetsubscriptiondetails.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/heartbeat/taskheartbeat.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/heartbeat/taskheartbeat.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/ipfinder/taskipfinder.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/ipfinder/taskipfinder.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/products/taskproducts.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/products/taskproducts.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/release/taskrelease.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/release/taskrelease.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/removedevice/taskremovedevice.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/removedevice/taskremovedevice.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/servers/taskservers.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tasks/servers/taskservers.h
    ${CMAKE_CURRENT_SOURCE_DIR}/telemetry.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/telemetry.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tutorialvpn.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tutorialvpn.h
    ${CMAKE_CURRENT_SOURCE_DIR}/update/updater.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/update/updater.h
    ${CMAKE_CURRENT_SOURCE_DIR}/update/versionapi.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/update/versionapi.h
    ${CMAKE_CURRENT_SOURCE_DIR}/update/webupdater.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/update/webupdater.h
)

# VPN Client UI resources
target_sources(mozillavpn-sources INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/ui/resources.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/ui/ui.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/certs/certs.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/public_keys/public_keys.qrc
)

# Sources for desktop platforms.
if(NOT CMAKE_CROSSCOMPILING)
     target_sources(mozillavpn-sources INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/systemtraynotificationhandler.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/systemtraynotificationhandler.h
        ${CMAKE_CURRENT_SOURCE_DIR}/extension/extensionconnection.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/extension/extensionconnection.h
        ${CMAKE_CURRENT_SOURCE_DIR}/extension/extensionhandler.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/extension/extensionhandler.h
       )
endif()

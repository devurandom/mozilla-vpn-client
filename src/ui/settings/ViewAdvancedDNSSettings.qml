/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import QtQuick.Layouts 1.14
import Mozilla.VPN 1.0
import "../components"
import "../components/forms"
import "../themes/themes.js" as Theme

import org.mozilla.Glean 0.15
import telemetry 0.15


Item {
    id: root

    StackView.onDeactivating: root.opacity = 0

    Behavior on opacity {
        PropertyAnimation {
            duration: 100
        }
    }

    Component.onCompleted: {
        tabButtonList.append({"buttonLabel":VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsDefaultToggle)})
        tabButtonList.append({"buttonLabel":VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAdvancedToggle)})



    }

    VPNMenu {
        id: menu
        objectName: "settingsAdvancedDNSSettingsBackButton"

        title: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsDnsNavItem)
        isSettingsView: true
    }

    VPNTabNavigation {
        // hacks to circumvent the fact that we can't send
        // "scripts" as property values through ListModel/ListElement

        id: tabs
        width: root.width
        anchors.top: menu.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.height - menu.height

        tabList: ListModel {
              id: tabButtonList
        }

        ButtonGroup {
            id: radioButtonGroup
        }

        stackContent: [
            VPNViewDNSSettings {
                settingsListModel: ListModel {
                    id:defaultTabListModel
                }
                Component.onCompleted: {
                    defaultTabListModel.append({
                                                settingValue: VPNSettings.Gateway,
                                                settingTitle: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsDefaultRadioHeader),
                                                settingDescription: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsDefaultRadioBody),
                                                showDNSInput: false,
                    })
                }
            },
            VPNViewDNSSettings {
                settingsListModel: ListModel{
                    id:advancedListModel
                }
                Component.onCompleted: {
                    advancedListModel.append({
                                                 settingValue: VPNSettings.BlockAds,
                                                 settingTitle: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAdblockRadioHeader),
                                                 settingDescription: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAdblockRadioBody),
                                                 showDNSInput: false})
                    advancedListModel.append({   settingValue: VPNSettings.BlockTracking,
                                                 settingTitle: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAntitrackRadioHeader),
                                                 settingDescription: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAntitrackRadioBody),
                                                 showDNSInput: false})
                    advancedListModel.append({   settingValue: VPNSettings.BlockAll,
                                                 settingTitle: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAdblockAntiTrackRadioHeader),
                                                 settingDescription: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsAdblockAntiTrackRadioBody),
                                                 showDNSInput: false})
                    advancedListModel.append({   settingValue: VPNSettings.Custom,
                                                 settingTitle: VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsCustomDNSRadioHeader),
                                                 settingDescription:  VPNl18n.tr(VPNl18n.CustomDNSSettingsDnsCustomDNSRadioBody),
                                                 showDNSInput: true})
                }
            }

        ]
    }
}


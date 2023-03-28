/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Mozilla.Shared 1.0
import components 0.1

MZViewBase {
    _menuTitle: MZI18n.GetHelpLinkTitle
    _menuOnBackClicked: () => MZNavigator.requestPreviousScreen()
    _viewContentData: Column {

        objectName: "getHelpLinks"
        spacing: MZTheme.theme.windowMargin

        Layout.fillWidth: true

        MZExternalLinkListItem {
            objectName: "helpCenter"

            accessibleName: MZI18n.GetHelpHelpCenter
            title: MZI18n.GetHelpHelpCenter
            iconSource: "qrc:/nebula/resources/externalLink.svg"
            backgroundColor: MZTheme.theme.clickableRowBlue
            width: parent.width - MZTheme.theme.windowMargin
            onClicked: {
                MZGleanDeprecated.recordGleanEvent("helpMenuHelpCenterOpened");
                Glean.sample.helpMenuHelpCenterOpened.record();
                MZUrlOpener.openUrlLabel("sumo")
            }
        }

        MZExternalLinkListItem {
            objectName: "inAppSupport"

            accessibleName: MZI18n.InAppSupportWorkflowSupportNavLinkText
            title: MZI18n.InAppSupportWorkflowSupportNavLinkText
            iconSource: "qrc:/nebula/resources/chevron.svg"
            iconMirror: MZLocalizer.isRightToLeft
            backgroundColor: MZTheme.theme.iconButtonLightBackground
            width: parent.width - MZTheme.theme.windowMargin
            onClicked: {
                MZGleanDeprecated.recordGleanEvent("helpContactSupportOpened");
                Glean.sample.helpContactSupportOpened.record();
                getHelpStackView.push("qrc:/nebula/screens/getHelp/contactUs/ViewContactUsForm.qml");
            }
        }

        MZExternalLinkListItem {
            objectName: "viewLogs"

            accessibleName: MZI18n.GetHelpViewLogs
            title: MZI18n.GetHelpViewLogs
            iconSource: MZFeatureList.get("shareLogs").isSupported ? "qrc:/nebula/resources/externalLink.svg" : "qrc:/nebula/resources/chevron.svg"
            iconMirror: !MZFeatureList.get("shareLogs").isSupported && MZLocalizer.isRightToLeft
            backgroundColor: MZFeatureList.get("shareLogs").isSupported ?MZTheme.theme.clickableRowBlue : MZTheme.theme.iconButtonLightBackground
            width: parent.width - MZTheme.theme.windowMargin
            onClicked: {
                MZGleanDeprecated.recordGleanEvent("helpMenuViewLogsOpened");
                Glean.sample.helpMenuViewLogsOpened.record();
                MZLog.requestViewLogs()
            }
        }

        MZSettingsItem {
            objectName: "developer"

            width: parent.width - MZTheme.theme.windowMargin
            spacing: MZTheme.theme.listSpacing
            anchors.horizontalCenter: parent.horizontalCenter

            settingTitle: MZI18n.GetHelpDeveloperOptions
            imageLeftSrc: "qrc:/nebula/resources/developer.svg"
            imageRightSrc: "qrc:/nebula/resources/chevron.svg"
            imageRightMirror: MZLocalizer.isRightToLeft
            visible: MZSettings.developerUnlock
            onClicked: getHelpStackView.push(MZTheme.theme.developerMenuQrc)
        }

    }
}
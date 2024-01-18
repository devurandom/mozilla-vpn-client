/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "dbusclient.h"

#include <QCoreApplication>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>

#include "interfaceconfig.h"
#include "ipaddress.h"
#include "logging/logger.h"
#include "models/device.h"
#include "models/keys.h"
#include "models/server.h"
#include "mozillavpn.h"
#include "settings/settingsholder.h"
#include "utilities/leakdetector.h"

constexpr const char* DBUS_SERVICE = "org.mozilla.vpn.dbus";
constexpr const char* DBUS_PATH = "/";

namespace {
Logger logger("DBusClient");
}

DBusClient::DBusClient(QObject* parent) : QObject(parent) {
  MZ_COUNT_CTOR(DBusClient);

  m_dbus = new OrgMozillaVpnDbusInterface(DBUS_SERVICE, DBUS_PATH,
                                          QDBusConnection::systemBus(), this);

  connect(m_dbus, &OrgMozillaVpnDbusInterface::connected, this,
          &DBusClient::connected);
  connect(m_dbus, &OrgMozillaVpnDbusInterface::disconnected, this,
          &DBusClient::disconnected);
}

DBusClient::~DBusClient() { MZ_COUNT_DTOR(DBusClient); }

// static
bool DBusClient::checkCurrentVersion() {
  DBusClient* dbus = new DBusClient(nullptr);
  QDBusPendingCallWatcher* watcher = dbus->version();

  bool completed = false;
  bool value = false;
  QObject::connect(
      watcher, &QDBusPendingCallWatcher::finished, watcher,
      [completed = &completed, value = &value](QDBusPendingCallWatcher* call) {
        *completed = true;

        QDBusPendingReply<QString> reply = *call;
        if (reply.isError()) {
          logger.error() << "DBus message received - error";
          *value = false;
          return;
        }

        QString version = reply.argumentAt<0>();
        *value = version == PROTOCOL_VERSION;

        logger.debug() << "DBus message received - daemon version:" << version
                       << " - current version:" << PROTOCOL_VERSION;
      });

  while (!completed) {
    QCoreApplication::processEvents();
  }

  delete dbus;
  return value;
}

QDBusPendingCallWatcher* DBusClient::version() {
  logger.debug() << "Version via DBus";
  QDBusPendingReply<QString> reply = m_dbus->version();
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);
  QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher,
                   &QDBusPendingCallWatcher::deleteLater);
  return watcher;
}

QDBusPendingCallWatcher* DBusClient::activate(const InterfaceConfig& config) {
  logger.debug() << "Activate via DBus";
  QJsonObject obj = config.toJson();
  QByteArray json = QJsonDocument(obj).toJson(QJsonDocument::Compact);
  QDBusPendingReply<bool> reply = m_dbus->activate(QString::fromUtf8(json));
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);
  QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher,
                   &QDBusPendingCallWatcher::deleteLater);
  return watcher;
}

QDBusPendingCallWatcher* DBusClient::deactivate() {
  logger.debug() << "Deactivate via DBus";
  QDBusPendingReply<bool> reply = m_dbus->deactivate();
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);
  QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher,
                   &QDBusPendingCallWatcher::deleteLater);
  return watcher;
}

QDBusPendingCallWatcher* DBusClient::status() {
  logger.debug() << "Status via DBus";
  QDBusPendingReply<QString> reply = m_dbus->status();
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);
  QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher,
                   &QDBusPendingCallWatcher::deleteLater);
  return watcher;
}

QDBusPendingCallWatcher* DBusClient::getLogs() {
  logger.debug() << "Get logs via DBus";
  QDBusPendingReply<QString> reply = m_dbus->getLogs();
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);
  QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher,
                   &QDBusPendingCallWatcher::deleteLater);
  return watcher;
}

QDBusPendingCallWatcher* DBusClient::cleanupLogs() {
  logger.debug() << "Cleanup logs via DBus";
  QDBusPendingReply<QString> reply = m_dbus->cleanupLogs();
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);
  QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher,
                   &QDBusPendingCallWatcher::deleteLater);
  return watcher;
}

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef NETWORKWATCHERIMPL_H
#define NETWORKWATCHERIMPL_H

#include <QObject>


class NetworkWatcherImpl : public QObject {
  Q_OBJECT
  Q_DISABLE_COPY_MOVE(NetworkWatcherImpl)

 public:
  NetworkWatcherImpl(QObject* parent) : QObject(parent) {}

  virtual ~NetworkWatcherImpl() = default;

  virtual void initialize() = 0;

  virtual void start() { m_active = true; }
  virtual void stop() { m_active = false; }

  bool isActive() const { return m_active; }

  enum TransportType {
    TransportType_Unknown = 0,
    TransportType_Ethernet,
    TransportType_WiFi,
    TransportType_Cellular,
    TransportType_Other
  };

  // Returns the current type of Network Connection
  virtual TransportType getTransportType() const { return TransportType_Unknown; }
  // Returns the current type of Network Connection
  virtual void checkTransportChange(){};

 signals:
  // Fires when the Device Connects to an unsecured Network
  void unsecuredNetwork(const QString& networkName, const QString& networkId);
  // Fires on when the connected WIFI Changes
  // TODO: Only windows-networkwatcher has this, the other plattforms should
  // too.
  void networkChanged(QString newBSSID);

  // Fired when the Device changed the Type of Transport
  void transportChanged(TransportType transportType);


 private:
  bool m_active = false;
};

#endif  // NETWORKWATCHERIMPL_H

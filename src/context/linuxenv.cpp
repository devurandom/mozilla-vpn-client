/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "linuxenv.h"

#include <QDBusInterface>
#include <QProcess>

QString LinuxEnv::gnomeShellVersion() {
  QDBusInterface iface("org.gnome.Shell", "/org/gnome/Shell",
                       "org.gnome.Shell");
  if (!iface.isValid()) {
    return QString();
  }

  QVariant shellVersion = iface.property("ShellVersion");
  if (!shellVersion.isValid()) {
    return QString();
  }
  return shellVersion.toString();
}

QString LinuxEnv::kdeFrameworkVersion() {
  QProcess proc;
  proc.start("kf5-config", QStringList{"--version"}, QIODeviceBase::ReadOnly);
  if (!proc.waitForFinished()) {
    return QString();
  }

  QByteArray result = proc.readAllStandardOutput();
  for (const QByteArray& line : result.split('\n')) {
    if (line.startsWith("KDE Frameworks: ")) {
      return QString::fromUtf8(line.last(line.size() - 16));
    }
  }

  return QString();
}

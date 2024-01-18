/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef LINUXUTILS_H
#define LINUXUTILS_H

#include <QObject>

namespace LinuxUtils {
void showAlert(const QString& message);
QString findCgroupPath(const QString& type);
QString findCgroup2Path();
QString desktopFileId(const QString& path);
};  // namespace LinuxUtils

#endif  // LINUXUTILS_H

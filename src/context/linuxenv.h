/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef LINUXENV_H
#define LINUXENV_H

#include <QObject>

namespace LinuxEnv {
  QString gnomeShellVersion();
  QString kdeFrameworkVersion();
};

#endif  // LINUXENV_H

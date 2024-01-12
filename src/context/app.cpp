/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "app.h"

#include <QCoreApplication>

#include "logging/logger.h"
#include "settings/settingsholder.h"
#include "settings/settingsmanager.h"
#include "taskscheduler/taskscheduler.h"
#include "utilities/leakdetector.h"

namespace {
Logger logger("App");
}

#ifdef UNIT_TEST
// static
App* App::instance() {
  static App* app = nullptr;

  if (!app) {
    app = new App(qApp);
  }

  return app;
}
#endif

App::App(QObject* parent) : QObject(parent) { MZ_COUNT_CTOR(App); }

App::~App() { MZ_COUNT_DTOR(App); }

int App::state() const { return m_state; }

App::UserState App::userState() const { return m_userState; }

void App::setState(int state) {
  logger.debug() << "Set state:" << state;

  m_state = state;
  emit stateChanged();
}

void App::setUserState(UserState state) {
  logger.debug() << "User authentication state:" << state;
  if (m_userState != state) {
    m_userState = state;
    emit userStateChanged();
  }
}

// static
QByteArray App::authorizationHeader() {
  if (SettingsHolder::instance()->token().isEmpty()) {
    logger.error() << "INVALID TOKEN! This network request is going to fail.";
    Q_ASSERT(false);
  }

  QByteArray authorizationHeader = "Bearer ";
  authorizationHeader.append(SettingsHolder::instance()->token().toLocal8Bit());
  return authorizationHeader;
}

void App::quit() {
  logger.debug() << "quit";
  TaskScheduler::forceDeleteTasks();

#if QT_VERSION < 0x060300
  // Qt5Compat.GraphicalEffects makes the app crash on shutdown. Let's do a
  // quick exit. See: https://bugreports.qt.io/browse/QTBUG-100687

  SettingsManager::instance()->sync();
  exit(0);
#endif

  qApp->quit();
}

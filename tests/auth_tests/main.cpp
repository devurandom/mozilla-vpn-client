/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <QCoreApplication>
#include <QDateTime>
#include <QRandomGenerator>
#include <QtTest/QtTest>

#include "authenticationinapp/authenticationinapp.h"
#include "context/app.h"
#include "context/constants.h"
#include "logging/loghandler.h"
#include "networking/simplenetworkmanager.h"
#include "settings/settingsholder.h"
#include "telemetry/glean/mzglean.h"
#include "testemailvalidation.h"
#include "testpasswordvalidation.h"
#include "testsignupandin.h"
#include "utilities/leakdetector.h"

// static
App* App::instance() {
  qFatal("This method should not be called!");
  return nullptr;
}

int main(int argc, char* argv[]) {
#ifdef MZ_DEBUG
  LeakDetector leakDetector;
  Q_UNUSED(leakDetector);
#endif

  SettingsHolder settingsHolder;
  Constants::setStaging();

  QCoreApplication a(argc, argv);

  SimpleNetworkManager snm;

  settingsHolder.setFeaturesFlippedOn(QStringList{
      "inAppAccountCreate", "inAppAuthentication", "accountDeletion"});

  LogHandler::setStderr(true);
  MZGlean::registerLogHandler(LogHandler::rustMessageHandler);

  QString nonce = QString::number(QDateTime::currentSecsSinceEpoch());

  for (uint16_t i = 0; i < 10; ++i) {
    nonce.append(static_cast<QChar>(
        'a' + static_cast<char>(QRandomGenerator::global()->generate() % 10)));
  }

  qDebug() << "Nonce:" << nonce;

  int failures = 0;
  TestEmailValidation tev;
  failures += QTest::qExec(&tev);

  TestPasswordValidation tpv(nonce);
  failures += QTest::qExec(&tpv);

  TestSignUpAndIn tsuTotp(nonce, "vpn.auth.test.", true /* totp creation */);
  failures += QTest::qExec(&tsuTotp);

  TestSignUpAndIn tsu(nonce, "vpn.auth.test.");
  failures += QTest::qExec(&tsu);

  TestSignUpAndIn tsuBlocked(nonce, "block.vpn.auth.test.");
  failures += QTest::qExec(&tsuBlocked);

  TestSignUpAndIn tsuSync(nonce, "sync.vpn.auth.test.");
  failures += QTest::qExec(&tsuSync);

  return failures;
}

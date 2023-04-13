/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "recommendedlocationmodel.h"

#include <QCoreApplication>

#include "leakdetector.h"
#include "location.h"
#include "logger.h"
#include "mozillavpn.h"
#include "servercountrymodel.h"
#include "serverlatency.h"

namespace {
Logger logger("RecommendedLocationModel");

constexpr int REFRESH_TIMER_MSEC = 2000;
constexpr unsigned int DEFAULT_ENTRIES = 5;
}  // namespace

// static
RecommendedLocationModel* RecommendedLocationModel::instance() {
  static RecommendedLocationModel* s_instance = nullptr;
  if (!s_instance) {
    s_instance = new RecommendedLocationModel(qApp);
  }
  return s_instance;
}

RecommendedLocationModel::RecommendedLocationModel(QObject* parent)
    : QAbstractListModel(parent) {
  MZ_COUNT_CTOR(RecommendedLocationModel);
}

RecommendedLocationModel::~RecommendedLocationModel() {
  MZ_COUNT_DTOR(RecommendedLocationModel);
}

void RecommendedLocationModel::initialize() {
  m_timer.setSingleShot(true);
  connect(&m_timer, &QTimer::timeout, this,
          &RecommendedLocationModel::refreshModel);

  connect(MozillaVPN::instance()->serverLatency(),
          &ServerLatency::progressChanged, this,
          &RecommendedLocationModel::maybeRefreshModel);
}

void RecommendedLocationModel::refreshModel() {
  logger.debug() << "Model refresh";

  QList<const ServerCity*> cities = recommendedLocations(DEFAULT_ENTRIES);
  if (m_recommendedCities.length() != cities.length()) {
    beginResetModel();
    m_recommendedCities.swap(cities);
    endResetModel();
    return;
  }

  m_recommendedCities.swap(cities);
  emit dataChanged(createIndex(0, 0),
                   createIndex(m_recommendedCities.length() - 1, 0));
}

// static
QList<const ServerCity*> RecommendedLocationModel::recommendedLocations(
    unsigned int maxResults) {
  double latencyScale = MozillaVPN::instance()->serverLatency()->avgLatency();
  if (latencyScale < 100.0) {
    latencyScale = 100.0;
  }

  QVector<const ServerCity*> cityResults;
  QVector<double> rankResults;
  cityResults.reserve(maxResults + 1);
  rankResults.reserve(maxResults + 1);

  for (const ServerCity& city :
       MozillaVPN::instance()->serverCountryModel()->cities()) {
    double cityRanking = city.connectionScore() * 256.0;

    // For tiebreaking, use the geographic distance and latency.
    double distance = MozillaVPN::instance()->location()->distance(
        city.latitude(), city.longitude());
    cityRanking -= city.latency() / latencyScale;
    cityRanking -= distance;

    // Insert into the result list
    qsizetype i;
    for (i = 0; i < rankResults.count(); i++) {
      if (rankResults[i] < cityRanking) {
        break;
      }
    }
    if (i < static_cast<qsizetype>(maxResults)) {
      rankResults.insert(i, cityRanking);
      cityResults.insert(i, &city);
    }
    if (rankResults.count() > static_cast<qsizetype>(maxResults)) {
      rankResults.resize(maxResults);
      cityResults.resize(maxResults);
    }
  }

  return cityResults;
}

QHash<int, QByteArray> RecommendedLocationModel::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[CityRole] = "city";
  return roles;
}

QVariant RecommendedLocationModel::data(const QModelIndex& index,
                                        int role) const {
  if (!index.isValid() || index.row() >= m_recommendedCities.length()) {
    return QVariant();
  }

  switch (role) {
    case CityRole:
      return QVariant::fromValue(m_recommendedCities.at(index.row()));

    default:
      return QVariant();
  }
}

void RecommendedLocationModel::maybeRefreshModel() {
  if (!MozillaVPN::instance()->serverLatency()->isActive()) {
    if (m_timer.isActive()) {
      m_timer.stop();
      refreshModel();
    }
    return;
  }

  if (!m_timer.isActive()) {
    m_timer.start(REFRESH_TIMER_MSEC);
  }
}

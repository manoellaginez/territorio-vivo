import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/alert_engine.dart';
import '../data/models/alert.dart';
import '../data/models/indicator.dart';
import '../data/models/thresholds.dart';
import '../data/repositories/territory_repository.dart';
import '../data/services/storage_service.dart';
import '../data/services/synthetic_data_service.dart';
import '../data/services/weather_service.dart';

enum LoadStatus { loading, ready, error }

/// População sintética usada apenas para estimar benefício social.
const int kPopulationEstimate = 25000;

/// Estado global do território: indicadores, alertas e decisões humanas.
class TerritoryProvider extends ChangeNotifier {
  TerritoryProvider(this._storage) {
    _repository = TerritoryRepository(WeatherService(_storage), SyntheticDataService());
    _loadDecisions();
  }

  static const _decisionsKey = 'alert_decisions';

  final StorageService _storage;
  late final TerritoryRepository _repository;

  LoadStatus status = LoadStatus.loading;
  String? errorMessage;
  List<Indicator> indicators = [];
  List<TerritoryAlert> alerts = [];
  DataSourceStatus climateSource = DataSourceStatus.live;
  DateTime? lastSync;
  Thresholds _thresholds = const Thresholds();
  Map<String, Decision> _decisions = {};

  /// Chamado uma vez pela tela inicial com os limiares salvos.
  Future<void> init(Thresholds thresholds) {
    _thresholds = thresholds;
    return load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      status = LoadStatus.loading;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final data = await _repository.load();
      indicators = data.indicators;
      climateSource = data.climateSource;
      lastSync = DateTime.now();
      _recompute();
      status = LoadStatus.ready;
    } catch (_) {
      status = LoadStatus.error;
      errorMessage = 'Não foi possível carregar os dados do território.';
    }
    notifyListeners();
  }

  void setThresholds(Thresholds t) {
    _thresholds = t;
    _recompute();
    notifyListeners();
  }

  void _recompute() => alerts = AlertEngine.generate(indicators, _thresholds);

  Indicator? indicatorById(String id) {
    for (final i in indicators) {
      if (i.id == id) return i;
    }
    return null;
  }

  TerritoryAlert? alertById(String id) {
    for (final a in alerts) {
      if (a.id == id) return a;
    }
    return null;
  }

  List<TerritoryAlert> alertsFor(String indicatorId) =>
      alerts.where((a) => a.indicatorId == indicatorId).toList();

  Decision decisionFor(String alertId) => _decisions[alertId] ?? Decision.pending;

  int get pendingAlertCount =>
      alerts.where((a) => decisionFor(a.id) == Decision.pending).length;

  Future<void> decide(String alertId, Decision decision) async {
    if (decision == Decision.pending) {
      _decisions.remove(alertId);
    } else {
      _decisions[alertId] = decision;
    }
    notifyListeners();
    await _saveDecisions();
  }

  Future<void> clearDecisions() async {
    _decisions = {};
    notifyListeners();
    await _storage.remove(_decisionsKey);
  }

  // ---- Indicadores de benefício social (estimativas, ver README) ----

  int get actedCount => _decisions.values.where((d) => d == Decision.acted).length;

  /// Água que deixaria de ser consumida por dia se o consumo voltasse à média.
  double get potentialWaterSavingM3PerDay {
    final w = indicatorById('water');
    if (w == null || !w.hasEnoughData) return 0;
    final n = w.history.length;
    final excess = AlertEngine.mean(w.history.sublist(n - 3)) -
        AlertEngine.mean(w.history.sublist(0, n - 3));
    return excess > 0 ? excess * kPopulationEstimate / 1000 : 0;
  }

  void _loadDecisions() {
    final raw = _storage.getString(_decisionsKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _decisions = {
        for (final e in map.entries)
          e.key: Decision.values.firstWhere((d) => d.name == e.value,
              orElse: () => Decision.pending),
      };
    } catch (_) {
      _decisions = {};
    }
  }

  Future<void> _saveDecisions() => _storage.setString(
        _decisionsKey,
        jsonEncode({for (final e in _decisions.entries) e.key: e.value.name}),
      );
}

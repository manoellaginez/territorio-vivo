import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/models/thresholds.dart';
import '../data/services/storage_service.dart';

/// Estado global de preferências: consentimento, tema e limiares de alerta.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage) {
    _consent = _storage.getBool('consent') ?? false;
    _highContrast = _storage.getBool('highContrast') ?? false;
    _themeMode = switch (_storage.getString('themeMode')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final raw = _storage.getString('thresholds');
    if (raw != null) {
      try {
        _thresholds = Thresholds.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _thresholds = const Thresholds();
      }
    }
  }

  final StorageService _storage;
  bool _consent = false;
  bool _highContrast = false;
  ThemeMode _themeMode = ThemeMode.system;
  Thresholds _thresholds = const Thresholds();

  bool get consent => _consent;
  bool get highContrast => _highContrast;
  ThemeMode get themeMode => _themeMode;
  Thresholds get thresholds => _thresholds;

  Future<void> setConsent(bool value) async {
    _consent = value;
    notifyListeners();
    await _storage.setBool('consent', value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storage.setString('themeMode', mode.name);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    await _storage.setBool('highContrast', value);
  }

  Future<void> saveThresholds(Thresholds t) async {
    _thresholds = t;
    notifyListeners();
    await _storage.setString('thresholds', jsonEncode(t.toJson()));
  }
}

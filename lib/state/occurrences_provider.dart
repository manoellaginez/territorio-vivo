import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/models/occurrence.dart';
import '../data/services/storage_service.dart';

/// Estado global das ocorrências anônimas registradas por cidadãos (persistidas).
class OccurrencesProvider extends ChangeNotifier {
  OccurrencesProvider(this._storage) {
    final raw = _storage.getString(_key);
    if (raw != null) {
      try {
        _items = (jsonDecode(raw) as List)
            .map((e) => Occurrence.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
  }

  static const _key = 'occurrences';
  final StorageService _storage;
  List<Occurrence> _items = [];

  List<Occurrence> get items => List.unmodifiable(_items);

  Future<void> add({
    required String category,
    required String description,
    required String location,
    required int severity,
  }) async {
    _items.insert(
      0,
      Occurrence(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: category,
        description: description.trim(),
        location: location.trim(),
        severity: severity,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((o) => o.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await _storage.remove(_key);
  }

  Future<void> _save() =>
      _storage.setString(_key, jsonEncode(_items.map((o) => o.toJson()).toList()));
}

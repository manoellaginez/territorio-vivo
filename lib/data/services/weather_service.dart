import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/indicator.dart';
import 'storage_service.dart';

class ClimateResult {
  const ClimateResult(this.indicators, {required this.fromCache});
  final List<Indicator> indicators;
  final bool fromCache;
}

/// Dados reais de clima via Open-Meteo (gratuita, sem chave de API).
/// Salva a última resposta em cache para o app funcionar offline.
class WeatherService {
  WeatherService(this._storage, {http.Client? client}) : _client = client ?? http.Client();

  final StorageService _storage;
  final http.Client _client;

  static const _cacheKey = 'weather_cache';
  static const _pastDays = 15; // 14 dias passados + hoje
  static final _uri = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=-23.5614&longitude=-46.6559'
    '&daily=temperature_2m_max,precipitation_sum'
    '&past_days=14&forecast_days=4&timezone=America%2FSao_Paulo',
  );

  /// Lança exceção se não houver rede nem cache.
  Future<ClimateResult> fetch() async {
    try {
      final response = await _client.get(_uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final result = _parse(response.body, fromCache: false);
      await _storage.setString(_cacheKey, response.body);
      return result;
    } catch (_) {
      final cached = _storage.getString(_cacheKey);
      if (cached == null) rethrow;
      return _parse(cached, fromCache: true);
    }
  }

  List<double> _doubles(dynamic raw) =>
      (raw as List).map((e) => (e as num?)?.toDouble() ?? 0.0).toList();

  ClimateResult _parse(String body, {required bool fromCache}) {
    final daily = (jsonDecode(body) as Map<String, dynamic>)['daily'] as Map<String, dynamic>;
    final times = (daily['time'] as List).cast<String>();
    final temps = _doubles(daily['temperature_2m_max']);
    final rain = _doubles(daily['precipitation_sum']);
    if (times.length <= _pastDays || temps.length != times.length || rain.length != times.length) {
      throw const FormatException('Resposta inesperada da API');
    }
    final first = DateTime.parse(times.first);
    final start = DateTime(first.year, first.month, first.day);
    return ClimateResult(
      [
        Indicator(
          id: 'temp',
          name: 'Temperatura máxima',
          unit: '°C',
          category: IndicatorCategory.climate,
          history: temps.sublist(0, _pastDays),
          forecast: temps.sublist(_pastDays),
          startDate: start,
          source: 'Open-Meteo',
        ),
        Indicator(
          id: 'rain',
          name: 'Chuva diária',
          unit: 'mm',
          category: IndicatorCategory.climate,
          history: rain.sublist(0, _pastDays),
          forecast: rain.sublist(_pastDays),
          startDate: start,
          source: 'Open-Meteo',
          chartStyle: ChartStyle.bar,
        ),
      ],
      fromCache: fromCache,
    );
  }
}

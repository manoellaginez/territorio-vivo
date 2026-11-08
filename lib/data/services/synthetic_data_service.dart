import 'dart:math';

import '../models/indicator.dart';

/// API simulada: gera séries sintéticas reprodutíveis (seed fixa) para o território
/// "Bela Vista, São Paulo". Simula latência de rede.
class SyntheticDataService {
  static const int days = 30;
  static const String sourceName = 'Sintético (demonstração)';

  DateTime _start() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (days - 1));
  }

  Future<List<Indicator>> fetchIndicators() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final start = _start();
    return [
      _series('water', 'Consumo de água', 'L/hab/dia', IndicatorCategory.resources,
          base: 165, weekend: 1.05, noise: 0.04, spike: 1.32, seed: 1, start: start),
      _series('energy', 'Consumo de energia', 'MWh/dia', IndicatorCategory.resources,
          base: 420, weekend: 0.92, noise: 0.03, spike: 1.24, seed: 2, start: start),
      _series('waste', 'Resíduos coletados', 't/dia', IndicatorCategory.services,
          base: 85, weekend: 0.9, noise: 0.05, spike: 1.45, seed: 3, start: start,
          style: ChartStyle.bar),
      _series('demand', 'Demanda por serviços', 'chamados/dia', IndicatorCategory.services,
          base: 310, weekend: 0.8, noise: 0.06, spike: 1.04, seed: 4, start: start),
    ];
  }

  /// Clima sintético, usado quando a API real e o cache estão indisponíveis.
  List<Indicator> climateFallback() {
    final rnd = Random(7);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 14);
    final temps = [for (var i = 0; i < 15; i++) 26 + rnd.nextDouble() * 5];
    final rain = [for (var i = 0; i < 15; i++) rnd.nextDouble() * 6];
    return [
      Indicator(
        id: 'temp',
        name: 'Temperatura máxima',
        unit: '°C',
        category: IndicatorCategory.climate,
        history: temps,
        forecast: const [33.5, 34.2, 31.0],
        startDate: start,
        source: sourceName,
      ),
      Indicator(
        id: 'rain',
        name: 'Chuva diária',
        unit: 'mm',
        category: IndicatorCategory.climate,
        history: rain,
        forecast: const [12.0, 25.0, 18.0],
        startDate: start,
        source: sourceName,
        chartStyle: ChartStyle.bar,
      ),
    ];
  }

  Indicator _series(
    String id,
    String name,
    String unit,
    IndicatorCategory category, {
    required double base,
    required double weekend,
    required double noise,
    required double spike,
    required int seed,
    required DateTime start,
    ChartStyle style = ChartStyle.line,
  }) {
    final rnd = Random(seed);
    final values = <double>[];
    for (var i = 0; i < days; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      var v = base * (1 + (rnd.nextDouble() * 2 - 1) * noise);
      if (date.weekday >= 6) v *= weekend;
      if (i >= days - 3) v *= spike;
      values.add(double.parse(v.toStringAsFixed(1)));
    }
    return Indicator(
      id: id,
      name: name,
      unit: unit,
      category: category,
      history: values,
      startDate: start,
      source: sourceName,
      chartStyle: style,
    );
  }
}

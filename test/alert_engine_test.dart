import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/data/alert_engine.dart';
import 'package:territorio_vivo/data/models/alert.dart';
import 'package:territorio_vivo/data/models/indicator.dart';
import 'package:territorio_vivo/data/models/thresholds.dart';

Indicator _ind(String id, List<double> history,
        {List<double> forecast = const [], String source = 'Open-Meteo'}) =>
    Indicator(
      id: id,
      name: id,
      unit: 'u',
      category: (id == 'temp' || id == 'rain')
          ? IndicatorCategory.climate
          : IndicatorCategory.resources,
      history: history,
      forecast: forecast,
      startDate: DateTime(2026, 1, 1),
      source: source,
    );

List<double> _series(double base, double recent) =>
    [...List.filled(27, base), recent, recent, recent];

void main() {
  const t = Thresholds();
  final now = DateTime(2026, 11, 6);

  test('gera alerta quando a média recente passa do limiar', () {
    final alerts = AlertEngine.generate([_ind('water', _series(100, 130))], t, now: now);
    expect(alerts, hasLength(1));
    expect(alerts.single.id, 'water_deviation');
    expect(alerts.single.severity, Severity.medium);
    expect(alerts.single.confidence, greaterThan(0.8));
  });

  test('não gera alerta dentro do limiar', () {
    final alerts = AlertEngine.generate([_ind('water', _series(100, 105))], t, now: now);
    expect(alerts, isEmpty);
  });

  test('severidade alta com desvio igual ou maior que 2x o limiar', () {
    final alerts = AlertEngine.generate([_ind('waste', _series(100, 145))], t, now: now);
    expect(alerts.single.severity, Severity.high);
  });

  test('ignora séries com poucos dados', () {
    final alerts =
        AlertEngine.generate([_ind('water', [100, 100, 100, 200, 200])], t, now: now);
    expect(alerts, isEmpty);
  });

  test('alerta de calor por previsão', () {
    final temp = _ind('temp', List.filled(15, 28.0), forecast: [34, 35, 33]);
    final alerts = AlertEngine.generate([temp], t, now: now);
    expect(alerts.single.id, 'temp_heat');
    expect(alerts.single.confidence, lessThan(0.8));
  });

  test('alerta de chuva por previsão acumulada', () {
    final rain = _ind('rain', List.filled(15, 2.0), forecast: [20, 25, 10]);
    final alerts = AlertEngine.generate([rain], t, now: now);
    expect(alerts.single.id, 'rain_heavy');
  });

  test('dados sintéticos reduzem a confiança de alertas de clima', () {
    final real = _ind('temp', List.filled(15, 28.0), forecast: [34, 35, 33]);
    final synth = _ind('temp', List.filled(15, 28.0),
        forecast: [34, 35, 33], source: 'Sintético (demonstração)');
    final a = AlertEngine.generate([real], t, now: now).single;
    final b = AlertEngine.generate([synth], t, now: now).single;
    expect(b.confidence, lessThan(a.confidence));
  });

  test('ordena alertas por severidade', () {
    final alerts = AlertEngine.generate([
      _ind('water', _series(100, 122)),
      _ind('waste', _series(100, 145)),
    ], t, now: now);
    expect(alerts.first.id, 'waste_deviation');
  });

  test('limiar maior elimina o alerta', () {
    const strict = Thresholds(deviationPct: 50);
    final alerts =
        AlertEngine.generate([_ind('water', _series(100, 130))], strict, now: now);
    expect(alerts, isEmpty);
  });
}

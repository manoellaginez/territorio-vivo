import 'dart:math' as math;

import 'models/alert.dart';
import 'models/indicator.dart';
import 'models/thresholds.dart';

/// Gera alertas explicáveis a partir de regras estatísticas simples.
/// Lógica pura (sem Flutter) para ser testável.
class AlertEngine {
  static double mean(List<double> v) =>
      v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

  static double stdDev(List<double> v, double m) {
    if (v.length < 2) return 0;
    final s = v.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b);
    return math.sqrt(s / (v.length - 1));
  }

  static String _f(double v, [int d = 1]) => v.toStringAsFixed(d).replaceAll('.', ',');

  static List<TerritoryAlert> generate(
    List<Indicator> indicators,
    Thresholds t, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final alerts = <TerritoryAlert>[];
    for (final i in indicators) {
      if (!i.hasEnoughData) continue;
      if (i.category == IndicatorCategory.climate) {
        final a = _climateAlert(i, t, at);
        if (a != null) alerts.add(a);
      } else {
        final a = _deviationAlert(i, t, at);
        if (a != null) alerts.add(a);
      }
    }
    alerts.sort((a, b) {
      final s = b.severity.index.compareTo(a.severity.index);
      return s != 0 ? s : b.confidence.compareTo(a.confidence);
    });
    return alerts;
  }

  static TerritoryAlert? _deviationAlert(Indicator i, Thresholds t, DateTime at) {
    final n = i.history.length;
    final base = i.history.sublist(0, n - 3);
    final recent = i.history.sublist(n - 3);
    final m = mean(base);
    if (m == 0) return null;
    final sd = stdDev(base, m);
    final rMean = mean(recent);
    final dev = (rMean - m) / m * 100;
    if (dev < t.deviationPct) return null;

    final severity = dev >= 2 * t.deviationPct
        ? Severity.high
        : dev >= 1.5 * t.deviationPct
            ? Severity.medium
            : Severity.low;
    final z = sd == 0 ? 0.0 : (rMean - m) / sd;
    final sampleFactor = math.min(1.0, base.length / 21);
    final cv = sd / m;
    final stability = 1 - math.min(cv, 0.4);
    var confidence = (sampleFactor * stability).clamp(0.2, 0.95).toDouble();
    if (i.isSynthetic) confidence = math.min(confidence, 0.9);

    return TerritoryAlert(
      id: '${i.id}_deviation',
      indicatorId: i.id,
      title: '${i.name} acima do padrão',
      severity: severity,
      justification:
          'A média dos últimos 3 dias (${_f(rMean)} ${i.unit}) está ${_f(dev)}% acima '
          'da média dos ${base.length} dias anteriores (${_f(m)} ${i.unit}). '
          'O desvio equivale a ${_f(z)} desvios-padrão. Limiar configurado: ${_f(t.deviationPct, 0)}%.',
      confidence: confidence,
      limitations:
          'Compara apenas janelas curtas e não separa sazonalidade semanal, feriados '
          'ou falhas de medição. ${i.isSynthetic ? 'Os dados são sintéticos (demonstração).' : 'Fonte: ${i.source}.'}',
      suggestion:
          'Verificar possíveis causas locais (vazamentos, picos de uso, falhas de coleta) '
          'antes de agir. A decisão sobre medidas é do gestor.',
      createdAt: at,
    );
  }

  static TerritoryAlert? _climateAlert(Indicator i, Thresholds t, DateTime at) {
    if (i.forecast.isEmpty) return null;
    final synthPenalty = i.isSynthetic ? 0.15 : 0.0;
    final limitSource = i.isSynthetic
        ? 'Dados de clima sintéticos (sem conexão com a API).'
        : 'Fonte: ${i.source}.';

    if (i.id == 'temp') {
      final peak = i.forecast.reduce(math.max);
      if (peak < t.heatC) return null;
      final severity = peak >= t.heatC + 4
          ? Severity.high
          : peak >= t.heatC + 2
              ? Severity.medium
              : Severity.low;
      return TerritoryAlert(
        id: 'temp_heat',
        indicatorId: i.id,
        title: 'Calor intenso previsto',
        severity: severity,
        justification:
            'A previsão indica máxima de ${_f(peak)} °C nos próximos ${i.forecast.length} dias, '
            'acima do limiar de ${_f(t.heatC, 0)} °C. Média dos últimos dias: ${_f(mean(i.history))} °C.',
        confidence: (0.65 - synthPenalty).clamp(0.2, 0.95).toDouble(),
        limitations:
            'Previsões de poucos dias têm incerteza, que cresce com o prazo. '
            'Não considera microclima de ruas, ilhas de calor nem sensação térmica. $limitSource',
        suggestion:
            'Avaliar divulgação de orientações de hidratação e atenção a idosos e crianças.',
        createdAt: at,
      );
    }

    if (i.id == 'rain') {
      final total = i.forecast.reduce((a, b) => a + b);
      if (total < t.rainMm) return null;
      final severity = total >= 2 * t.rainMm
          ? Severity.high
          : total >= 1.5 * t.rainMm
              ? Severity.medium
              : Severity.low;
      return TerritoryAlert(
        id: 'rain_heavy',
        indicatorId: i.id,
        title: 'Chuva acumulada elevada prevista',
        severity: severity,
        justification:
            'A previsão soma ${_f(total)} mm em ${i.forecast.length} dias, acima do limiar de '
            '${_f(t.rainMm, 0)} mm. Chuva média diária recente: ${_f(mean(i.history))} mm.',
        confidence: (0.55 - synthPenalty).clamp(0.2, 0.95).toDouble(),
        limitations:
            'Chuva é a variável mais difícil de prever em escala local; o volume e o '
            'horário podem variar bastante. Não modela drenagem nem relevo. $limitSource',
        suggestion:
            'Considerar inspeção preventiva de bueiros e áreas de alagamento recorrente.',
        createdAt: at,
      );
    }
    return null;
  }
}

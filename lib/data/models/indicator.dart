import 'dart:math' as math;

enum IndicatorCategory { resources, climate, services }

enum ChartStyle { line, bar }

class Indicator {
  const Indicator({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.history,
    required this.startDate,
    required this.source,
    this.forecast = const [],
    this.chartStyle = ChartStyle.line,
  });

  final String id;
  final String name;
  final String unit;
  final IndicatorCategory category;
  final List<double> history;
  final List<double> forecast;
  final DateTime startDate;
  final String source;
  final ChartStyle chartStyle;

  bool get isSynthetic => source.startsWith('Sintético');
  bool get hasEnoughData => history.length >= 7;

  double get latest => history.last;
  double get mean => history.reduce((a, b) => a + b) / history.length;
  double get maxValue => history.reduce(math.max);
  double get minValue => history.reduce(math.min);

  DateTime dateAt(int index) =>
      DateTime(startDate.year, startDate.month, startDate.day + index);

  /// Variação % da média dos 3 últimos dias contra os 3 anteriores.
  double get trendPct {
    final n = history.length;
    if (n < 6) return 0;
    final recent = history.sublist(n - 3).reduce((a, b) => a + b) / 3;
    final prev = history.sublist(n - 6, n - 3).reduce((a, b) => a + b) / 3;
    if (prev == 0) return 0;
    return (recent - prev) / prev * 100;
  }
}

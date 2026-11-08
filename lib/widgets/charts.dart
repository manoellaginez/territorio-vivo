import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';

FlTitlesData _titles(BuildContext context) {
  final style = Theme.of(context).textTheme.bodySmall;
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        getTitlesWidget: (value, meta) => Text(fmt(value, decimals: 0), style: style),
      ),
    ),
  );
}

(double, double) _range(List<double> all) {
  final lo = all.reduce(math.min);
  final hi = all.reduce(math.max);
  final pad = (hi - lo) == 0 ? 1.0 : (hi - lo) * 0.15;
  return (math.max(0, lo - pad), hi + pad);
}

class _Legend extends StatelessWidget {
  const _Legend({required this.hasForecast});

  final bool hasForecast;

  @override
  Widget build(BuildContext context) {
    if (!hasForecast) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    Widget item(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 12, height: 12, color: c),
          const SizedBox(width: 4),
          Text(t, style: Theme.of(context).textTheme.bodySmall),
        ]);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.md,
        children: [item(scheme.primary, 'Observado'), item(scheme.tertiary, 'Previsão')],
      ),
    );
  }
}

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.values,
    required this.semanticsLabel,
    this.forecast = const [],
    this.height = 180,
  });

  final List<double> values;
  final List<double> forecast;
  final String semanticsLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];
    final fSpots = forecast.isEmpty
        ? <FlSpot>[]
        : [
            spots.last,
            for (var i = 0; i < forecast.length; i++)
              FlSpot((values.length + i).toDouble(), forecast[i]),
          ];
    final (minY, maxY) = _range([...values, ...forecast]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: semanticsLabel,
          image: true,
          excludeSemantics: true,
          child: SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: _titles(context),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: scheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData:
                        BarAreaData(show: true, color: scheme.primary.withAlpha(30)),
                  ),
                  if (fSpots.isNotEmpty)
                    LineChartBarData(
                      spots: fSpots,
                      color: scheme.tertiary,
                      barWidth: 3,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: true),
                    ),
                ],
              ),
            ),
          ),
        ),
        _Legend(hasForecast: forecast.isNotEmpty),
      ],
    );
  }
}

class DailyBarChart extends StatelessWidget {
  const DailyBarChart({
    super.key,
    required this.values,
    required this.semanticsLabel,
    this.forecast = const [],
    this.height = 180,
  });

  final List<double> values;
  final List<double> forecast;
  final String semanticsLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final all = [...values, ...forecast];
    final maxY = all.reduce(math.max) * 1.15 + 0.1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: semanticsLabel,
          image: true,
          excludeSemantics: true,
          child: SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: _titles(context),
                barGroups: [
                  for (var i = 0; i < all.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: all[i],
                        width: 6,
                        color: i >= values.length ? scheme.tertiary : scheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ),
        _Legend(hasForecast: forecast.isNotEmpty),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/indicator.dart';
import 'app_card.dart';
import 'charts.dart';

IconData iconForIndicator(String id) => switch (id) {
      'water' => Icons.water_drop_outlined,
      'energy' => Icons.bolt,
      'temp' => Icons.thermostat,
      'rain' => Icons.umbrella_outlined,
      'waste' => Icons.delete_outline,
      'demand' => Icons.support_agent,
      _ => Icons.show_chart,
    };

String valueText(Indicator i) => fmt(i.latest, decimals: i.latest >= 100 ? 0 : 1);

String trendText(Indicator i) {
  final t = i.trendPct;
  return '${t >= 0 ? '+' : ''}${fmt(t)}% vs. 3 dias anteriores';
}

String chartSemantics(Indicator i) =>
    'Gráfico de ${i.name}. Último valor ${valueText(i)} ${i.unit}. ${trendText(i)}.'
    '${i.forecast.isEmpty ? '' : ' Inclui previsão dos próximos ${i.forecast.length} dias.'}';

void openIndicator(BuildContext context, Indicator i) =>
    context.pushNamed('indicator', pathParameters: {'id': i.id});

/// Gráfico do indicador no estilo definido pelo próprio indicador (linha ou barras).
class IndicatorChart extends StatelessWidget {
  const IndicatorChart(this.indicator, {super.key, this.height = 180});

  final Indicator indicator;
  final double height;

  @override
  Widget build(BuildContext context) {
    return indicator.chartStyle == ChartStyle.bar
        ? DailyBarChart(
            values: indicator.history,
            forecast: indicator.forecast,
            semanticsLabel: chartSemantics(indicator),
            height: height,
          )
        : TrendLineChart(
            values: indicator.history,
            forecast: indicator.forecast,
            semanticsLabel: chartSemantics(indicator),
            height: height,
          );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.indicator});

  final Indicator indicator;

  @override
  Widget build(BuildContext context) {
    final i = indicator;
    final t = i.trendPct;
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${i.name}: ${valueText(i)} ${i.unit}. ${trendText(i)}. Toque para ver detalhes.',
      excludeSemantics: true,
      child: AppCard(
        onTap: () => openIndicator(context, i),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(iconForIndicator(i.id), color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(i.name, style: theme.textTheme.titleSmall)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Text('${valueText(i)} ${i.unit}', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              Icon(
                t > 1 ? Icons.arrow_upward : (t < -1 ? Icons.arrow_downward : Icons.trending_flat),
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(trendText(i), style: theme.textTheme.bodySmall)),
            ]),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class IndicatorStats extends StatelessWidget {
  const IndicatorStats(this.indicator, {super.key});

  final Indicator indicator;

  @override
  Widget build(BuildContext context) {
    final i = indicator;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        StatTile('Média', '${fmt(i.mean)} ${i.unit}'),
        StatTile('Máximo', '${fmt(i.maxValue)} ${i.unit}'),
        StatTile('Mínimo', '${fmt(i.minValue)} ${i.unit}'),
      ],
    );
  }
}

/// Cartão de painel: título, gráfico com histórico/tendência e estatísticas.
class IndicatorChartCard extends StatelessWidget {
  const IndicatorChartCard({super.key, required this.indicator});

  final Indicator indicator;

  @override
  Widget build(BuildContext context) {
    final i = indicator;
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => openIndicator(context, i),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(iconForIndicator(i.id), color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(i.name, style: theme.textTheme.titleMedium)),
            Text('${valueText(i)} ${i.unit}', style: theme.textTheme.titleMedium),
          ]),
          Text(trendText(i), style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          IndicatorChart(i),
          const SizedBox(height: AppSpacing.md),
          IndicatorStats(i),
          const SizedBox(height: AppSpacing.sm),
          Text('Fonte: ${i.source}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

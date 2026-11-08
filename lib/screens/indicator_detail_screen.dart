import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/app_card.dart';
import '../widgets/indicator_widgets.dart';
import '../widgets/state_views.dart';

class IndicatorDetailScreen extends StatelessWidget {
  const IndicatorDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return TerritoryGate(builder: (context, t) {
      final i = t.indicatorById(id);
      if (i == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Indicador')),
          body: const EmptyView(
            icon: Icons.search_off,
            title: 'Indicador não encontrado',
          ),
        );
      }
      final theme = Theme.of(context);
      final related = t.alertsFor(i.id);
      final n = i.history.length;
      final lastDays = [for (var k = n - 1; k >= n - 7 && k >= 0; k--) k];
      return Scaffold(
        appBar: AppBar(title: Text(i.name)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${valueText(i)} ${i.unit}', style: theme.textTheme.headlineMedium),
                  Text(trendText(i)),
                  const SizedBox(height: AppSpacing.md),
                  IndicatorChart(i, height: 220),
                  const SizedBox(height: AppSpacing.md),
                  IndicatorStats(i),
                ],
              ),
            ),
            const SectionTitle('Últimos 7 dias'),
            AppCard(
              child: Column(
                children: [
                  for (final k in lastDays)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmtDate(i.dateAt(k))),
                          Text('${fmt(i.history[k])} ${i.unit}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SectionTitle('Alertas relacionados'),
            if (related.isEmpty)
              const AppCard(
                child: EmptyView(
                  icon: Icons.check_circle_outline,
                  title: 'Sem alertas para este indicador',
                ),
              )
            else
              for (final a in related)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AlertTile(
                    alert: a,
                    decision: t.decisionFor(a.id),
                    onTap: () => context.pushNamed('alert', pathParameters: {'id': a.id}),
                  ),
                ),
            const SectionTitle('Fonte dos dados'),
            Text(i.isSynthetic
                ? 'Série sintética gerada para demonstração, sem relação com medições reais.'
                : 'Dados públicos obtidos de ${i.source}.'),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/repositories/territory_repository.dart';
import '../state/occurrences_provider.dart';
import '../state/territory_provider.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/app_card.dart';
import '../widgets/indicator_widgets.dart';
import '../widgets/state_views.dart';
import 'package:provider/provider.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.onSeeAlerts});

  final VoidCallback onSeeAlerts;

  String _sourceText(DataSourceStatus s) => switch (s) {
        DataSourceStatus.live => 'Clima: dados reais (Open-Meteo)',
        DataSourceStatus.cache => 'Sem conexão: clima do último cache salvo',
        DataSourceStatus.synthetic => 'Sem conexão e sem cache: clima sintético',
      };

  @override
  Widget build(BuildContext context) {
    return TerritoryGate(builder: (context, t) {
      final theme = Theme.of(context);
      final occurrences = context.watch<OccurrencesProvider>().items.length;
      final top = t.alerts.take(3).toList();
      return RefreshIndicator(
        onRefresh: () => t.load(silent: true),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bela Vista · São Paulo (SP)', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_sourceText(t.climateSource)),
                  if (t.lastSync != null)
                    Text('Atualizado em ${fmtDateTime(t.lastSync!)}',
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const HumanDecisionBanner(),
            SectionTitle(
              'Alertas em destaque',
              trailing: TextButton(onPressed: onSeeAlerts, child: const Text('Ver todos')),
            ),
            if (top.isEmpty)
              const AppCard(
                child: EmptyView(
                  icon: Icons.check_circle_outline,
                  title: 'Nenhum alerta ativo',
                  message: 'Todos os indicadores estão dentro dos limiares configurados.',
                ),
              )
            else
              for (final a in top)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AlertTile(
                    alert: a,
                    decision: t.decisionFor(a.id),
                    onTap: () => context.pushNamed('alert', pathParameters: {'id': a.id}),
                  ),
                ),
            const SectionTitle('Indicadores do território'),
            ResponsiveWrap(children: [for (final i in t.indicators) KpiCard(indicator: i)]),
            const SectionTitle('Benefício social'),
            ResponsiveWrap(children: [
              _SocialCard(
                icon: Icons.water_drop_outlined,
                label: 'Água potencialmente poupável',
                value: '${fmt(t.potentialWaterSavingM3PerDay, decimals: 0)} m³/dia',
                note: 'Estimativa se o consumo voltasse à média (população sintética de $kPopulationEstimate hab.).',
              ),
              _SocialCard(
                icon: Icons.fact_check_outlined,
                label: 'Alertas com ação humana',
                value: '${t.actedCount}',
                note: 'Alertas em que o gestor registrou uma ação.',
              ),
              _SocialCard(
                icon: Icons.groups_outlined,
                label: 'Ocorrências cidadãs',
                value: '$occurrences',
                note: 'Registros anônimos feitos por moradores.',
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    });
  }
}

class _SocialCard extends StatelessWidget {
  const _SocialCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value. $note',
      excludeSemantics: true,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: theme.colorScheme.secondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(note, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}


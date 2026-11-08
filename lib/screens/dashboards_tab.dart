import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/indicator.dart';
import '../state/territory_provider.dart';
import '../widgets/indicator_widgets.dart';
import '../widgets/state_views.dart';

/// Três painéis distintos: Recursos, Clima e Serviços.
class DashboardsTab extends StatelessWidget {
  const DashboardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [
            Tab(icon: Icon(Icons.water_drop_outlined), text: 'Recursos'),
            Tab(icon: Icon(Icons.cloud_outlined), text: 'Clima'),
            Tab(icon: Icon(Icons.support_agent), text: 'Serviços'),
          ]),
          Expanded(
            child: TerritoryGate(
              builder: (context, t) => TabBarView(children: [
                _DashboardPage(
                  t: t,
                  category: IndicatorCategory.resources,
                  description: 'Consumo de água e energia do território, com histórico de 30 dias.',
                ),
                _DashboardPage(
                  t: t,
                  category: IndicatorCategory.climate,
                  description:
                      'Clima local: 15 dias observados e 3 dias de previsão (tracejado/roxo).',
                ),
                _DashboardPage(
                  t: t,
                  category: IndicatorCategory.services,
                  description: 'Coleta de resíduos e demanda por serviços públicos.',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({required this.t, required this.category, required this.description});

  final TerritoryProvider t;
  final IndicatorCategory category;
  final String description;

  @override
  Widget build(BuildContext context) {
    final items = t.indicators.where((i) => i.category == category).toList();
    if (items.isEmpty) {
      return const EmptyView(
        icon: Icons.insights_outlined,
        title: 'Sem indicadores neste painel',
        message: 'Puxe para atualizar ou tente novamente mais tarde.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(description),
        const SizedBox(height: AppSpacing.md),
        for (final i in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: IndicatorChartCard(indicator: i),
          ),
      ],
    );
  }
}

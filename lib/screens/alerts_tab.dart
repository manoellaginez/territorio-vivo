import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/state_views.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TerritoryGate(builder: (context, t) {
      if (t.alerts.isEmpty) {
        return const EmptyView(
          icon: Icons.check_circle_outline,
          title: 'Nenhum alerta ativo',
          message: 'Altere os limiares em Configurações para ver como os alertas reagem.',
        );
      }
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HumanDecisionBanner(),
          const SizedBox(height: AppSpacing.md),
          for (final a in t.alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AlertTile(
                alert: a,
                decision: t.decisionFor(a.id),
                onTap: () => context.pushNamed('alert', pathParameters: {'id': a.id}),
              ),
            ),
        ],
      );
    });
  }
}

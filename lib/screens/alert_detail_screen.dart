import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/alert.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/app_card.dart';
import '../widgets/state_views.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return TerritoryGate(builder: (context, t) {
      final a = t.alertById(id);
      if (a == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Alerta')),
          body: const EmptyView(
            icon: Icons.search_off,
            title: 'Alerta não encontrado',
            message: 'Os limiares ou os dados mudaram e este alerta deixou de existir.',
          ),
        );
      }
      final theme = Theme.of(context);
      final decision = t.decisionFor(a.id);
      void decide(Decision d, String message) {
        t.decide(a.id, d);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Detalhe do alerta')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Align(alignment: Alignment.centerLeft, child: SeverityChip(a.severity)),
            const SizedBox(height: AppSpacing.sm),
            Semantics(header: true, child: Text(a.title, style: theme.textTheme.headlineSmall)),
            Text('Gerado em ${fmtDateTime(a.createdAt)}', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Por que este alerta? (evidência)', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(a.justification),
                  const SizedBox(height: AppSpacing.md),
                  ConfidenceBar(a.confidence),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Limitações', style: theme.textTheme.titleMedium),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Text(a.limitations),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sugestão de verificação', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(a.suggestion),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const HumanDecisionBanner(),
            const SizedBox(height: AppSpacing.md),
            Text('Decisão do gestor', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (decision == Decision.pending) ...[
              FilledButton.icon(
                onPressed: () => decide(Decision.acted, 'Ação registrada.'),
                icon: const Icon(Icons.task_alt),
                label: const Text('Registrar ação tomada'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => decide(Decision.dismissed, 'Alerta descartado.'),
                icon: const Icon(Icons.block),
                label: const Text('Descartar (sem ação necessária)'),
              ),
            ] else ...[
              AppCard(
                child: Row(children: [
                  const Icon(Icons.how_to_reg),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(decisionLabel(decision))),
                  TextButton(
                    onPressed: () => decide(Decision.pending, 'Decisão desfeita.'),
                    child: const Text('Desfazer'),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: () => context.pushNamed('indicator', pathParameters: {'id': a.indicatorId}),
              icon: const Icon(Icons.show_chart),
              label: const Text('Ver indicador relacionado'),
            ),
          ],
        ),
      );
    });
  }
}

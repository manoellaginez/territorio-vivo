import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/occurrences_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/state_views.dart';

class CitizenTab extends StatelessWidget {
  const CitizenTab({super.key});

  static const _severity = {1: 'Baixa', 2: 'Média', 3: 'Alta'};

  @override
  Widget build(BuildContext context) {
    final items = context.watch<OccurrencesProvider>().items;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        FilledButton.icon(
          onPressed: () => context.pushNamed('occurrence-new'),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Registrar ocorrência'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Registros anônimos, salvos só neste aparelho. Não inclua dados pessoais.',
          style: theme.textTheme.bodySmall,
        ),
        const SectionTitle('Minhas ocorrências'),
        if (items.isEmpty)
          const AppCard(
            child: EmptyView(
              icon: Icons.inbox_outlined,
              title: 'Nenhuma ocorrência registrada',
              message: 'Relate vazamentos, alagamentos, lixo acumulado e outros problemas do bairro.',
            ),
          )
        else
          for (final o in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.category, style: theme.textTheme.titleMedium),
                          Text(o.description),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${o.location} · gravidade ${_severity[o.severity]} · ${fmtDateTime(o.createdAt)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remover ocorrência de ${o.category}',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<OccurrencesProvider>().remove(o.id),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

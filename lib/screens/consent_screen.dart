import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/settings_provider.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget item(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(text)),
            ],
          ),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Icon(Icons.shield_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text('Território Vivo', style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Antes de começar, saiba como tratamos os dados:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            item(Icons.person_off_outlined,
                'Não pedimos nome, e-mail, telefone ou CPF. Ocorrências são anônimas.'),
            item(Icons.phone_android,
                'Suas ocorrências, preferências e decisões ficam salvas apenas neste dispositivo.'),
            item(Icons.analytics_outlined,
                'Os indicadores são sintéticos ou públicos (Open-Meteo) e servem para apoiar decisões.'),
            item(Icons.how_to_reg,
                'Os alertas não são decisões automáticas: a decisão final é sempre humana.'),
            item(Icons.undo,
                'Você pode revogar o consentimento e apagar os dados locais nas configurações.'),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v ?? false),
              title: const Text('Li e concordo com o tratamento descrito acima.'),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _accepted ? () => context.read<SettingsProvider>().setConsent(true) : null,
              child: const Text('Aceitar e continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

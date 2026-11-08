import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/validators.dart';
import '../data/models/thresholds.dart';
import '../state/occurrences_provider.dart';
import '../state/settings_provider.dart';
import '../state/territory_provider.dart';
import '../widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dev;
  late final TextEditingController _heat;
  late final TextEditingController _rain;

  String _n(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);

  @override
  void initState() {
    super.initState();
    final t = context.read<SettingsProvider>().thresholds;
    _dev = TextEditingController(text: _n(t.deviationPct));
    _heat = TextEditingController(text: _n(t.heatC));
    _rain = TextEditingController(text: _n(t.rainMm));
  }

  @override
  void dispose() {
    _dev.dispose();
    _heat.dispose();
    _rain.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = Thresholds(
      deviationPct: Validators.parseNumber(_dev.text)!,
      heatC: Validators.parseNumber(_heat.text)!,
      rainMm: Validators.parseNumber(_rain.text)!,
    );
    final territory = context.read<TerritoryProvider>();
    await context.read<SettingsProvider>().saveThresholds(t);
    territory.setThresholds(t);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Limiares salvos. Alertas recalculados.')));
  }

  Future<void> _revoke() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar consentimento?'),
        content: const Text(
            'Suas ocorrências e decisões salvas neste aparelho serão apagadas e o app voltará à tela de consentimento.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Revogar e apagar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final occurrences = context.read<OccurrencesProvider>();
    final territory = context.read<TerritoryProvider>();
    final settings = context.read<SettingsProvider>();
    await occurrences.clear();
    await territory.clearDecisions();
    await settings.setConsent(false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Limiares de alerta', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _dev,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: fieldDecoration('Desvio sobre a média (%)',
                      helper: 'Entre 5 e 100. Recursos e serviços.'),
                  validator: (v) =>
                      Validators.numberInRange(v, min: 5, max: 100, label: 'O desvio'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _heat,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: fieldDecoration('Calor: temperatura máxima (°C)',
                      helper: 'Entre 25 e 45.'),
                  validator: (v) =>
                      Validators.numberInRange(v, min: 25, max: 45, label: 'A temperatura'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _rain,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: fieldDecoration('Chuva acumulada em 3 dias (mm)',
                      helper: 'Entre 10 e 200.'),
                  validator: (v) =>
                      Validators.numberInRange(v, min: 10, max: 200, label: 'A chuva'),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar limiares'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Aparência e acessibilidade', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
              ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Escuro')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Alto contraste'),
            subtitle: const Text('Reforça o contraste de cores em todo o app.'),
            value: settings.highContrast,
            onChanged: settings.setHighContrast,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Privacidade', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Os dados ficam apenas neste aparelho. Você pode revogar o consentimento e apagá-los.'),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _revoke,
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Revogar consentimento e apagar dados'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

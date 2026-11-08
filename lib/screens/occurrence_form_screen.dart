import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/validators.dart';
import '../state/occurrences_provider.dart';
import '../widgets/app_card.dart';

class OccurrenceFormScreen extends StatefulWidget {
  const OccurrenceFormScreen({super.key});

  @override
  State<OccurrenceFormScreen> createState() => _OccurrenceFormScreenState();
}

class _OccurrenceFormScreenState extends State<OccurrenceFormScreen> {
  static const _categories = [
    'Vazamento de água',
    'Falta de energia',
    'Alagamento',
    'Lixo acumulado',
    'Calor extremo',
    'Outro',
  ];

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String? _category;
  int _severity = 2;

  @override
  void dispose() {
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<OccurrencesProvider>().add(
          category: _category!,
          description: _description.text,
          location: _location.text,
          severity: _severity,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Ocorrência registrada de forma anônima.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ocorrência')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const AppCard(
              child: Row(children: [
                Icon(Icons.privacy_tip_outlined),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('O registro é anônimo. Não informe nome, telefone, e-mail, CPF ou número da sua casa.'),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: fieldDecoration('Categoria'),
              items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Selecione uma categoria.' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _description,
              maxLines: 4,
              maxLength: 280,
              decoration: fieldDecoration('Descrição', hint: 'O que está acontecendo?'),
              validator: Validators.description,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _location,
              decoration: fieldDecoration('Local', hint: 'Ex.: Praça da Sé, próximo ao metrô'),
              validator: Validators.location,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Gravidade', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Baixa')),
                ButtonSegment(value: 2, label: Text('Média')),
                ButtonSegment(value: 3, label: Text('Alta')),
              ],
              selected: {_severity},
              onSelectionChanged: (s) => setState(() => _severity = s.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Enviar ocorrência'),
            ),
          ],
        ),
      ),
    );
  }
}

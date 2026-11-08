import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/alert.dart';
import 'app_card.dart';

class SeverityStyle {
  const SeverityStyle(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;
}

/// Cor + ícone + texto: a severidade nunca depende só da cor.
SeverityStyle severityStyle(Severity s) => switch (s) {
      Severity.low => const SeverityStyle(Color(0xFF0B5FA5), Icons.info_outline, 'Atenção baixa'),
      Severity.medium =>
        const SeverityStyle(Color(0xFF8A5A00), Icons.warning_amber_rounded, 'Atenção média'),
      Severity.high => const SeverityStyle(Color(0xFFB3261E), Icons.error_outline, 'Atenção alta'),
    };

String decisionLabel(Decision d) => switch (d) {
      Decision.pending => 'Aguardando decisão humana',
      Decision.acted => 'Ação registrada',
      Decision.dismissed => 'Descartado pelo gestor',
    };

String confidenceLabel(double c) => c >= 0.75 ? 'alta' : (c >= 0.5 ? 'média' : 'baixa');

class SeverityChip extends StatelessWidget {
  const SeverityChip(this.severity, {super.key});

  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final s = severityStyle(severity);
    return Semantics(
      label: s.label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(s.icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(s.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar(this.confidence, {super.key});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    final label = confidenceLabel(confidence);
    return Semantics(
      label: 'Nível de confiança: $pct por cento, $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nível de confiança: $pct% ($label)',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          // Animação com propósito: mostra o preenchimento da confiança.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: confidence),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: v, minHeight: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso fixo exigido pelo desafio: alertas apoiam, não substituem, a decisão humana.
class HumanDecisionBanner extends StatelessWidget {
  const HumanDecisionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      color: scheme.tertiaryContainer,
      child: Row(
        children: [
          Icon(Icons.how_to_reg, color: scheme.onTertiaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Os alertas apoiam, mas não substituem, a decisão humana. '
              'A decisão final é sempre do gestor público.',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, required this.decision, required this.onTap});

  final TerritoryAlert alert;
  final Decision decision;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = severityStyle(alert.severity);
    final pct = (alert.confidence * 100).round();
    return Semantics(
      button: true,
      label: '${alert.title}. ${s.label}. Confiança $pct por cento. ${decisionLabel(decision)}.',
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(s.icon, color: s.color, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${s.label} · confiança $pct%'),
                  Text('${decisionLabel(decision)} · ${fmtDateTime(alert.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

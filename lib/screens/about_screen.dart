import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/app_card.dart';

/// Transparência: fontes, método, métricas, vieses e quando não confiar nas previsões.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'Fontes dos dados',
      'Água, energia, resíduos e demanda por serviços são séries sintéticas geradas para demonstração. '
          'Temperatura e chuva vêm da API pública Open-Meteo (dados reais). Sem internet, o app usa o último cache salvo; '
          'sem cache, usa clima sintético e avisa isso na tela inicial.'
    ),
    (
      'Como os alertas são gerados',
      'Recursos e serviços: compara a média dos últimos 3 dias com a média dos dias anteriores. '
          'Se o desvio passar do limiar configurado, gera alerta (baixo, médio ou alto conforme a distância ao limiar). '
          'Clima: dispara se a previsão passar do limiar de calor (°C) ou de chuva acumulada (mm).'
    ),
    (
      'Métricas e confiança',
      'Cada alerta mostra desvio percentual e z-score. A confiança combina o tamanho da amostra e a variabilidade dos dados '
          '(séries instáveis têm confiança menor). Alertas baseados em previsão têm confiança fixa mais baixa, '
          'e ainda menor com dados sintéticos.'
    ),
    (
      'Limitações e vieses',
      'Regras simples não capturam sazonalidade, feriados, obras ou falhas de medição. '
          'Os dados sintéticos não representam nenhum bairro real. A previsão de chuva em escala local é incerta. '
          'Grupos com menos acesso a celular ou internet podem registrar menos ocorrências, o que enviesa a demanda percebida.'
    ),
    (
      'Quando não confiar',
      'Com menos de 7 dias de dados, o alerta não é gerado. Desconfie quando a confiança estiver baixa, '
          'quando a fonte for sintética, quando o clima vier do cache antigo ou após eventos atípicos (feriados, greves, enchentes).'
    ),
    (
      'Decisão humana e privacidade',
      'Nenhuma ação é automática: o gestor registra a decisão. Ocorrências são anônimas, o app bloqueia e-mail, telefone '
          'e CPF em texto livre e todos os dados ficam apenas no aparelho.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dados, método e limitações')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final s in _sections)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(s.$1, style: theme.textTheme.titleMedium)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(s.$2),
                  ],
                ),
              ),
            ),
          Text('Projeto acadêmico · FIAP · Global Solution 2026.2', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

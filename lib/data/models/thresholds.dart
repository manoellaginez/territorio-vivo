class Thresholds {
  const Thresholds({this.deviationPct = 20, this.heatC = 32, this.rainMm = 30});

  /// Desvio mínimo (%) da média recente sobre a média histórica.
  final double deviationPct;

  /// Temperatura máxima prevista (°C) que dispara alerta de calor.
  final double heatC;

  /// Chuva acumulada prevista em 3 dias (mm) que dispara alerta.
  final double rainMm;

  Map<String, dynamic> toJson() =>
      {'deviationPct': deviationPct, 'heatC': heatC, 'rainMm': rainMm};

  factory Thresholds.fromJson(Map<String, dynamic> j) => Thresholds(
        deviationPct: (j['deviationPct'] as num).toDouble(),
        heatC: (j['heatC'] as num).toDouble(),
        rainMm: (j['rainMm'] as num).toDouble(),
      );
}

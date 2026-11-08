enum Severity { low, medium, high }

enum Decision { pending, acted, dismissed }

class TerritoryAlert {
  const TerritoryAlert({
    required this.id,
    required this.indicatorId,
    required this.title,
    required this.severity,
    required this.justification,
    required this.confidence,
    required this.limitations,
    required this.suggestion,
    required this.createdAt,
  });

  final String id;
  final String indicatorId;
  final String title;
  final Severity severity;
  final String justification;
  final double confidence; // 0..1
  final String limitations;
  final String suggestion;
  final DateTime createdAt;
}

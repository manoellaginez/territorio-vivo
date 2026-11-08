/// Ocorrência registrada pelo cidadão. Anônima: não guarda nome nem contato.
class Occurrence {
  const Occurrence({
    required this.id,
    required this.category,
    required this.description,
    required this.location,
    required this.severity,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String description;
  final String location;
  final int severity; // 1 = baixa, 2 = média, 3 = alta
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'location': location,
        'severity': severity,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Occurrence.fromJson(Map<String, dynamic> j) => Occurrence(
        id: j['id'] as String,
        category: j['category'] as String,
        description: j['description'] as String,
        location: j['location'] as String,
        severity: j['severity'] as int,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

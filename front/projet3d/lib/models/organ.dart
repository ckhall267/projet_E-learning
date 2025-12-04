class Organ {
  final String id;
  final String name;
  final String description;
  final List<String> relatedSymptoms;
  final bool isHighlighted;
  final String? color;

  Organ({
    required this.id,
    required this.name,
    required this.description,
    this.relatedSymptoms = const [],
    this.isHighlighted = false,
    this.color,
  });

  Organ copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? relatedSymptoms,
    bool? isHighlighted,
    String? color,
  }) {
    return Organ(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      relatedSymptoms: relatedSymptoms ?? this.relatedSymptoms,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      color: color ?? this.color,
    );
  }
}


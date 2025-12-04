class Symptom {
  final int id;
  final String name;
  final String description;
  final String? organ;
  final bool isSelected;

  Symptom({
    required this.id,
    required this.name,
    required this.description,
    this.organ,
    this.isSelected = false,
  });

  Symptom copyWith({
    int? id,
    String? name,
    String? description,
    String? organ,
    bool? isSelected,
  }) {
    return Symptom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      organ: organ ?? this.organ,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}


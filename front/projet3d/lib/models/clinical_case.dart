class ClinicalCase {
  final String id;
  final String title;
  final String description;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<int> symptoms;
  final String? expectedDiagnosis;
  final bool isCompleted;

  ClinicalCase({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.symptoms,
    this.expectedDiagnosis,
    this.isCompleted = false,
  });

  ClinicalCase copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    List<int>? symptoms,
    String? expectedDiagnosis,
    bool? isCompleted,
  }) {
    return ClinicalCase(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      symptoms: symptoms ?? this.symptoms,
      expectedDiagnosis: expectedDiagnosis ?? this.expectedDiagnosis,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  String get difficultyText {
    switch (difficulty) {
      case 'easy':
        return 'Facile';
      case 'medium':
        return 'Moyen';
      case 'hard':
        return 'Difficile';
      default:
        return 'Moyen';
    }
  }
}


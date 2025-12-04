enum TPStatus { published, draft }

enum TPCategory {
  cardiology,
  neurology,
  pulmonology,
  other,
}

class PracticalWork {
  final String id;
  final String title;
  final String description;
  final String duration;
  final int studentCount;
  final TPStatus status;
  final TPCategory category;

  PracticalWork({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.studentCount,
    required this.status,
    required this.category,
  });

  String get statusText {
    switch (status) {
      case TPStatus.published:
        return 'Publié';
      case TPStatus.draft:
        return 'Brouillon';
    }
  }

  String get categoryText {
    switch (category) {
      case TPCategory.cardiology:
        return 'Cardiologie';
      case TPCategory.neurology:
        return 'Neurologie';
      case TPCategory.pulmonology:
        return 'Pneumologie';
      case TPCategory.other:
        return 'Autre';
    }
  }
}


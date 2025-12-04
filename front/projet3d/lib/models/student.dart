enum StudentStatus { completed, inProgress, notStarted }

class Student {
  final String id;
  final String name;
  final String email;
  final String tpId;
  final String tpTitle;
  final double progress;
  final StudentStatus status;
  final double? grade;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.tpId,
    required this.tpTitle,
    required this.progress,
    required this.status,
    this.grade,
  });

  String get statusText {
    switch (status) {
      case StudentStatus.completed:
        return 'Terminé';
      case StudentStatus.inProgress:
        return 'En cours';
      case StudentStatus.notStarted:
        return 'Non commencé';
    }
  }
}


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

  factory Student.fromUserJson(Map<String, dynamic> json) {
    // Mapping from backend User entity to Student view model
    // Note: User entity usually doesn't have TP info directly unless it's a DTO.
    // Here we are parsing from 'etudiantsAssignes' inside a TP object, 
    // so we don't have TP info in the User object itself. 
    // We might need to fill tpId and tpTitle later or handle it differently.
    // For now, we put placeholders or empty.
    
    return Student(
      id: json['id']?.toString() ?? '',
      name: '${json['prenom']} ${json['nom']}',
      email: json['email'] ?? '',
      tpId: '', // Context dependent
      tpTitle: '', // Context dependent
      progress: 0.0, // TODO: Fetch real progress from TentativeSimulation
      status: StudentStatus.notStarted, // TODO: Compute from progress
      grade: null, // TODO: Fetch grade
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? tpId,
    String? tpTitle,
    double? progress,
    StudentStatus? status,
    double? grade,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      tpId: tpId ?? this.tpId,
      tpTitle: tpTitle ?? this.tpTitle,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      grade: grade ?? this.grade,
    );
  }

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

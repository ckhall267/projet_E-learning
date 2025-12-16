import 'student.dart';

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
  final List<Student> assignedStudents;
  final String professorName;
  final String professorEmail;

  PracticalWork({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.studentCount,
    required this.status,
    required this.category,
    this.assignedStudents = const [],
    this.professorName = '',
    this.professorEmail = '',
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
  
  // Factory method to create a PracticalWork from JSON
  factory PracticalWork.fromJson(Map<String, dynamic> json) {
    // 1. Parse notes into a Map<studentId, grade>
    final Map<String, double> gradesMap = {};
    if (json['notes'] != null) {
      for (var note in json['notes']) {
        if (note['etudiant'] != null && note['valeur'] != null) {
          final studentId = note['etudiant']['id'].toString();
          final grade = (note['valeur'] as num).toDouble();
          gradesMap[studentId] = grade;
        }
      }
    }

    return PracticalWork(
      id: json['id']?.toString() ?? '',
      title: json['titre'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '2h',
      studentCount: (json['etudiantsAssignes'] as List?)?.length ?? 0,
      professorName: json['professeur'] != null ? '${json['professeur']['prenom']} ${json['professeur']['nom']}' : 'Professeur Inconnu',
      professorEmail: json['professeur'] != null ? json['professeur']['email'] : '',
      status: _parseStatus(json['status']),
      category: _parseCategory(json['category']),
      assignedStudents: (json['etudiantsAssignes'] as List<dynamic>?)
              ?.map((e) {
                final student = Student.fromUserJson(e);
                // 2. Inject grade if available
                if (gradesMap.containsKey(student.id)) {
                  return student.copyWith(grade: gradesMap[student.id]);
                }
                return student;
              })
              .toList() ??
          [],
    );
  }

  // Method to convert PracticalWork to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': title,
      'description': description,
      'duration': duration,
      'status': status == TPStatus.published ? 'published' : 'draft',
      'category': category.toString().split('.').last, // 'cardiology', etc.
    };
  }

  static TPStatus _parseStatus(String? status) {
    if (status == 'published') return TPStatus.published;
    return TPStatus.draft;
  }

  static TPCategory _parseCategory(String? category) {
    switch (category) {
      case 'cardiology':
        return TPCategory.cardiology;
      case 'neurology':
        return TPCategory.neurology;
      case 'pulmonology':
        return TPCategory.pulmonology;
      default:
        return TPCategory.other;
    }
  }
}


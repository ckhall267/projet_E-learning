import 'package:flutter/material.dart';

class GradeStudentDialog extends StatefulWidget {
  final String studentName;
  final Function(double) onGrade;

  const GradeStudentDialog({
    super.key,
    required this.studentName,
    required this.onGrade,
  });

  @override
  State<GradeStudentDialog> createState() => _GradeStudentDialogState();
}

class _GradeStudentDialogState extends State<GradeStudentDialog> {
  final _gradeController = TextEditingController();

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final grade = double.tryParse(_gradeController.text);
    if (grade != null && grade >= 0 && grade <= 20) {
      widget.onGrade(grade);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une note valide entre 0 et 20')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: Text('Attribuer une note à ${widget.studentName}', style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: _gradeController,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Note /20',
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF23B8C0)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF23B8C0)),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

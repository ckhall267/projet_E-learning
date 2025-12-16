import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AddStudentDialog extends StatefulWidget {
  final int tpId;
  final String token;
  final Function() onAssign;

  const AddStudentDialog({
    super.key,
    required this.tpId,
    required this.token,
    required this.onAssign,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {

    final url = Uri.parse('http://localhost:8080/api/users/role/Etudiant');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _students = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // Fallback for demo if endpoint not ready
        setState(() {
          _isLoading = false;
        });
        print("Error fetching students: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching students: $e");
    }
  }

  Future<void> _assignStudent(int studentId) async {
    final url = Uri.parse('http://localhost:8080/api/tps/${widget.tpId}/students/$studentId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Étudiant assigné avec succès')),
          );
          widget.onAssign();
          Navigator.of(context).pop();
        }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'assignation: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur réseau: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assigner un étudiant'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _students.isEmpty
                ? const Text('Aucun étudiant disponible.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text('${student['prenom']} ${student['nom']}'),
                        subtitle: Text(student['email']),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.teal),
                          onPressed: () => _assignStudent(student['id']),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

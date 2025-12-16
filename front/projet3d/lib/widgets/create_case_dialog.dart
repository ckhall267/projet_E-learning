import 'package:flutter/material.dart';
import '../../models/clinical_case.dart';
import '../../models/practical_work.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateCaseDialog extends StatefulWidget {
  final Function(ClinicalCase) onCreate;
  final List<PracticalWork> availableTPs;

  const CreateCaseDialog({
    super.key,
    required this.onCreate,
    required this.availableTPs,
  });

  @override
  State<CreateCaseDialog> createState() => _CreateCaseDialogState();
}

class _CreateCaseDialogState extends State<CreateCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _difficultyController = TextEditingController();
  String _selectedDifficulty = 'easy';
  String? _selectedTPId;
  
  // Symptoms management
  List<Map<String, dynamic>> _availableSymptoms = [];
  final List<int> _selectedSymptomsIds = [];
  bool _loadingSymptoms = true;

  @override
  void initState() {
    super.initState();
    _fetchSymptoms();
  }

  Future<void> _fetchSymptoms() async {
    // URL to AI Service
    // Note: If running on Android Emulator, use 10.0.2.2 instead of localhost
    // But user is likely on Web/Desktop primarily for Prof Dashboard.
    final url = Uri.parse('http://localhost:8000/symptoms');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _availableSymptoms = List<Map<String, dynamic>>.from(data['symptoms']);
          _loadingSymptoms = false;
        });
      } else {
        print('Erreur chargement symptômes: ${response.statusCode}');
        setState(() => _loadingSymptoms = false);
      }
    } catch (e) {
      print('Erreur connexion AI Service: $e');
      setState(() => _loadingSymptoms = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSymptomsIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner au moins un symptôme')),
        );
        return;
      }

      // On ne demande PLUS le diagnostic attendu, l'IA s'en charge.
      // Cependant, le modèle ClinicalCase a un champ expectedDiagnosis qui peut être null.
      
      final newCase = ClinicalCase(
        id: '', 
        title: _titleController.text,
        description: _descriptionController.text,
        difficulty: _selectedDifficulty,
        symptoms: _selectedSymptomsIds,
        travailPratiqueId: _selectedTPId,
        expectedDiagnosis: null, // L'IA déterminera cela
      );
      
      widget.onCreate(newCase);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Text('Créer un Cas Clinique (IA)', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 600,
        height: 600, // Fixed height to allow scrolling
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Titre du cas',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (Contexte patient)',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDifficulty,
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Difficulté',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'easy', child: Text('Facile')),
                          DropdownMenuItem(value: 'medium', child: Text('Moyen')),
                          DropdownMenuItem(value: 'hard', child: Text('Difficile')),
                        ],
                        onChanged: (value) => setState(() => _selectedDifficulty = value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTPId,
                         dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Lier au TP',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        items: widget.availableTPs.map((tp) {
                          return DropdownMenuItem(value: tp.id, child: Text(tp.title));
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedTPId = value),
                        // validator: (value) => value == null ? 'Requis' : null, // Optionnel ?
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Symptômes (L\'IA utilisera ces données)',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // List of Symptoms
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _loadingSymptoms
                            ? const Center(child: CircularProgressIndicator())
                            : _availableSymptoms.isEmpty
                                ? const Center(child: Text('Aucun symptôme chargé (Vérifiez le service IA)', style: TextStyle(color: Colors.white70)))
                                : ListView.builder(
                                    itemCount: _availableSymptoms.length,
                                    itemBuilder: (context, index) {
                                      final symptom = _availableSymptoms[index];
                                      final id = symptom['id'] as int;
                                      final name = symptom['name'] as String;
                                      final isSelected = _selectedSymptomsIds.contains(id);
                
                                      return CheckboxListTile(
                                        title: Text(name, style: const TextStyle(color: Colors.white70)),
                                        value: isSelected,
                                        activeColor: const Color(0xFF23B8C0),
                                        checkColor: Colors.white,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedSymptomsIds.add(id);
                                            } else {
                                              _selectedSymptomsIds.remove(id);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          child: const Text('Créer'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/practical_work.dart';
import '../../models/student.dart';
import '../../models/clinical_case.dart';
import '../../widgets/tp_card.dart';
import '../../widgets/create_tp_dialog.dart';
import '../../widgets/create_case_dialog.dart';
import '../../widgets/add_student_dialog.dart';
import '../simulation_3d_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../widgets/grade_student_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../login_page.dart';

class ProfessorDashboard extends StatefulWidget {
  final String nom;
  final String prenom;
  final String token;

  const ProfessorDashboard({
    super.key, 
    required this.nom, 
    required this.prenom,
    required this.token,
  });

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  int _selectedTab = 0;
  bool _isLoading = false;
  List<PracticalWork> _practicalWorks = [];
  List<ClinicalCase> _clinicalCases = [];
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchTPs();
    _fetchCases();
  }

  Future<void> _fetchCases() async {
    // setState(() => _isLoading = true); // Avoid double loading state with TPs or handle separately
    try {
      final response = await http.get(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/cases")}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _clinicalCases = data.map((json) => ClinicalCase.fromJson(json)).toList();
        });
      } else {
        print('Erreur chargement Cas: ${response.body}');
      }
    } catch (e) {
      print('Erreur connexion Cas: $e');
    }
  }

  Future<void> _fetchTPs() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/tps")}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _practicalWorks = data.map((json) => PracticalWork.fromJson(json)).toList();
        });
      } else {
        _showError('Erreur chargement TPs: ${response.body}');
      }
    } catch (e) {
      _showError('Erreur connexion: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTP(PracticalWork tp) async {
    setState(() => _isLoading = true);
    try {
      final tpData = tp.toJson();
      tpData.remove('id'); // Let backend generate ID
      tpData.remove('studentCount'); // Not a field in backend entity

      final response = await http.post(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/tps")}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tpData),
      );

      if (response.statusCode == 200) {
        _fetchTPs(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TP créé avec succès'), backgroundColor: Colors.green),
        );
      } else {
        _showError('Erreur création TP: ${response.body}');
      }
    } catch (e) {
      _showError('Erreur connexion: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTP(String id) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/tps")}/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _practicalWorks.removeWhere((p) => p.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TP supprimé avec succès'), backgroundColor: Colors.green),
        );
      } else {
        _showError('Erreur suppression TP: ${response.body}');
      }
    } catch (e) {
      _showError('Erreur connexion: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTP(PracticalWork tp) async {
    setState(() => _isLoading = true);
    try {
      final tpData = tp.toJson();
      tpData.remove('studentCount'); // Not a field in backend entity

      final response = await http.put(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/tps")}/${tp.id}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tpData),
      );

      if (response.statusCode == 200) {
        _fetchTPs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TP modifié avec succès'), backgroundColor: Colors.green),
        );
      } else {
        _showError('Erreur modification TP: ${response.body}');
      }
    } catch (e) {
      _showError('Erreur connexion: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _handleViewTP(PracticalWork tp) {
    // TODO: Naviguer vers la page de visualisation du TP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualisation de: ${tp.title}'),
        backgroundColor: const Color(0xFF23B8C0),
      ),
    );
  }

  void _handleEditTP(PracticalWork tp) {
    showDialog(
      context: context,
      builder: (context) => CreateTPDialog(
        // TODO: Pass existing TP to dialog for editing (CreateTPDialog needs update to support edit)
        // For now, we simulate success
        onCreate: (updatedTP) {
             // We need to keep the ID of the TP being edited
             final tpToUpdate = PracticalWork(
               id: tp.id,
               title: updatedTP.title,
               description: updatedTP.description,
               duration: updatedTP.duration,
               studentCount: tp.studentCount,
               status: updatedTP.status,
               category: updatedTP.category,
             );
             _updateTP(tpToUpdate);
        },
      ),
    );
  }

  void _handleDeleteTP(PracticalWork tp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Supprimer le TP',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${tp.title}" ?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTP(tp.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _handleCreateTP() {
    showDialog(
      context: context,
      builder: (context) => CreateTPDialog(
        onCreate: (newTP) {
          _createTP(newTP);
        },
      ),
    );
  }

  void _handleCreateCase() {
    showDialog(
      context: context,
      builder: (context) => CreateCaseDialog(
        availableTPs: _practicalWorks,
        onCreate: (newCase) {
          _createCase(newCase);
        },
      ),
    );
  }

  Future<void> _createCase(ClinicalCase newCase) async {
    setState(() => _isLoading = true);
    try {
      final caseData = newCase.toJson();
      caseData.remove('id'); 
     
      final response = await http.post(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/cases")}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(caseData),
      );

      if (response.statusCode == 200) {
        _fetchCases();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cas clinique créé avec succès'), backgroundColor: Colors.green),
        );
      } else {
        _showError('Erreur création Cas: ${response.body}');
      }
    } catch (e) {
      _showError('Erreur connexion: $e');
    } finally {
      setState(() => _isLoading = false);
    }

  }

  Future<void> _showMyQrCode() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final profile = await _authService.getUserProfile(widget.token);
      final qrToken = profile['qrToken'];

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Mon QR Code', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: QrImageView(
                      data: qrToken ?? 'Erreur: Pas de token',
                      version: QrVersions.auto,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Scannez ce code pour vous connecter',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer', style: TextStyle(color: Color(0xFF23B8C0))),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      _showError('Erreur lors de la récupération du QR Code: $e');
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo et titre
          Row(
            children: [
              const Icon(
                Icons.school,
                color: Color(0xFF23B8C0),
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'E-learning Médical Augmenté',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cas cliniques simulés en 3D - Espace Professeur',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Profil professeur
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dr. ${widget.prenom} ${widget.nom}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Professeur',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF23B8C0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.prenom[0]}${widget.nom[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.qr_code, color: Colors.white),
                tooltip: 'Mon QR Code',
                onPressed: () => _showMyQrCode(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () {
                   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Travaux Pratiques', Icons.description),
          _buildTab(1, 'Simulation 3D', Icons.cable),
          _buildTab(2, 'Étudiants & Notes', Icons.people),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF23B8C0) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF23B8C0)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticalWorksContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F1E),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et bouton Créer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mes Travaux Pratiques',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créez et gérez vos TPs avec simulations 3D',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _handleCreateTP,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Créer un TP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23B8C0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Liste des TPs
            if (_isLoading)
               const Center(child: CircularProgressIndicator())
            else if (_practicalWorks.isEmpty)
               const Center(child: Text("Aucun TP trouvé", style: TextStyle(color: Colors.white)))
            else
               ..._practicalWorks.map((tp) => TPCard(
                  tp: tp,
                  onView: () => _handleViewTP(tp),
                  onEdit: () => _handleEditTP(tp),
                  onDelete: () => _handleDeleteTP(tp),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulation3DContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F1E),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulation 3D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lancez une simulation 3D interactive avec diagnostic IA',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes Cas Cliniques',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _handleCreateCase,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Nouveau Cas',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23B8C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Cas cliniques disponibles
            _buildAvailableCases(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cas cliniques disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_clinicalCases.isEmpty)
           const Text("Aucun cas clinique disponible", style: TextStyle(color: Colors.white70))
        else
           ..._clinicalCases.map((caseItem) => _buildCaseCard(caseItem)),
      ],
    );
  }

  Widget _buildCaseCard(ClinicalCase caseItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseItem.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caseItem.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(caseItem.difficulty).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getDifficultyColor(caseItem.difficulty),
                    width: 1,
                  ),
                ),
                child: Text(
                  caseItem.difficultyText,
                  style: TextStyle(
                    color: _getDifficultyColor(caseItem.difficulty),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Simulation3DPage(initialCase: caseItem),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23B8C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Lancer la simulation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Widget _buildStudentsGradesContent() {
    // Aggregate students from all TPs
    final List<Student> students = [];
    for (var tp in _practicalWorks) {
      for (var student in tp.assignedStudents) {
        // Enforce TP context into student object for display
        students.add(student.copyWith(
          tpId: tp.id,
          tpTitle: tp.title,
        ));
      }
    }

    final int totalStudents = students.length;
    final int completed = students.where((s) => s.status == StudentStatus.completed).length;
    final int inProgress = students.where((s) => s.status == StudentStatus.inProgress).length;
    final double average = students
            .where((s) => s.grade != null)
            .map((s) => s.grade!)
            .fold(0.0, (a, b) => a + b) /
        students.where((s) => s.grade != null).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F1E),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques
            Row(
              children: [
                _buildStatCard('Total Étudiants', totalStudents.toString(), Colors.white),
                const SizedBox(width: 16),
                _buildStatCard('Terminés', completed.toString(), Colors.green),
                const SizedBox(width: 16),
                _buildStatCard('En cours', inProgress.toString(), const Color(0xFF23B8C0)),
                const SizedBox(width: 16),
                _buildStatCard(
                    'Moyenne', average.toStringAsFixed(1) + '/20', const Color(0xFF23B8C0)),
              ],
            ),
            const SizedBox(height: 32),

            // Titre et boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Liste des Étudiants',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Suivez la progression et attribuez les notes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _handleExport,
                      icon: const Icon(Icons.download, color: Color(0xFF23B8C0)),
                      label: const Text(
                        'Exporter',
                        style: TextStyle(color: Color(0xFF23B8C0)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddStudentDialog(
                            // Utilise le premier TP s'il existe, sinon l'utilisateur devra créer un TP d'abord
                             tpId: _practicalWorks.isNotEmpty ? int.parse(_practicalWorks.first.id) : 0,
                            token: widget.token,
                            onAssign: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Étudiant ajouté avec succès')),
                              );
                              // TODO: Rafraîchir la liste des étudiants si elle était dynamique
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        'Ajouter',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23B8C0),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Barre de recherche et filtre
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un étudiant...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF23B8C0), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: 'Tous les TPs',
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    items: ['Tous les TPs', 'Anatomie du Cœur', 'Système Nerveux']
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tableau des étudiants
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // En-tête du tableau
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _buildTableHeader('Étudiant')),
                        Expanded(flex: 2, child: _buildTableHeader('TP')),
                        Expanded(flex: 2, child: _buildTableHeader('Progression')),
                        Expanded(flex: 1, child: _buildTableHeader('Statut')),
                        Expanded(flex: 1, child: _buildTableHeader('Note')),
                        Expanded(flex: 1, child: _buildTableHeader('Actions')),
                      ],
                    ),
                  ),
                  // Lignes du tableau
                  ...students.map((student) => _buildStudentRow(student)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStudentRow(Student student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              student.tpTitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: student.progress / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF23B8C0)),
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.progress.toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: student.status == StudentStatus.completed
                    ? Colors.green.withOpacity(0.2)
                    : const Color(0xFF23B8C0).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: student.status == StudentStatus.completed
                      ? Colors.green
                      : const Color(0xFF23B8C0),
                  width: 1,
                ),
              ),
              child: Text(
                student.statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: student.status == StudentStatus.completed
                      ? Colors.green
                      : const Color(0xFF23B8C0),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              student.grade != null ? '${student.grade}/20' : '-',
              style: TextStyle(
                color: student.grade != null ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Attribuer une note
                    _handleGrade(student.id, student.tpId, student.name);
                  },
                  icon: const Icon(Icons.emoji_events, color: Color(0xFF23B8C0), size: 20),
                  tooltip: 'Attribuer une note',
                ),
                IconButton(
                  onPressed: () {
                     _handleEmail(student.email);
                  },
                  icon: const Icon(Icons.email, color: Color(0xFF23B8C0), size: 20),
                  tooltip: 'Envoyer un message',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  void _handleGrade(String studentId, String tpId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => GradeStudentDialog(
        studentName: studentName,
        onGrade: (grade) => _submitGrade(studentId, tpId, grade),
      ),
    );
  }

  Future<void> _submitGrade(String studentId, String tpId, double grade) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/tps")}/$tpId/students/$studentId/grade'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(grade),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note attribuée avec succès'), backgroundColor: Colors.green),
        );
        _fetchTPs(); // Refresh List
      } else {
        _showError('Erreur attribution note: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Erreur connexion: $e');
    }
  }


  Future<void> _handleEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Med3D - Suivi E-Learning',
        'body': 'Bonjour,\n\nConcernant votre progression...',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      _showError('Impossible d\'ouvrir le client mail');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _handleExport() async {
    final pdf = pw.Document();
    
    // Aggregation des données pour le PDF
    final List<Student> students = [];
    for (var tp in _practicalWorks) {
      for (var student in tp.assignedStudents) {
         students.add(student.copyWith(
          tpId: tp.id,
          tpTitle: tp.title,
        ));
      }
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(level: 0, child: pw.Text('Rapport de Suivi des Etudiants - Med3D', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24))),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Nom', 'Email', 'TP', 'Note'],
                  ...students.map(
                    (student) => [student.name, student.email, student.tpTitle, student.grade != null ? '${student.grade}/20' : 'N/A']
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Column(
        children: [
          _buildHeader(),
          _buildNavigationTabs(),
          Expanded(
            child: _selectedTab == 0
                ? _buildPracticalWorksContent()
                : _selectedTab == 1
                    ? _buildSimulation3DContent()
                    : _buildStudentsGradesContent(),
          ),
        ],
      ),
    );
  }
}


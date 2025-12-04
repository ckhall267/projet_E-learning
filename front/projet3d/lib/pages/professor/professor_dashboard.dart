import 'package:flutter/material.dart';
import '../../models/practical_work.dart';
import '../../models/student.dart';
import '../../models/clinical_case.dart';
import '../../widgets/tp_card.dart';
import '../../widgets/create_tp_dialog.dart';
import '../simulation_3d_page.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  int _selectedTab = 0;

  // Données de démonstration
  final List<PracticalWork> _practicalWorks = [
    PracticalWork(
      id: '1',
      title: 'Anatomie du Cœur Humain',
      description:
          'Exploration 3D des structures cardiaques et identification des pathologies courantes',
      duration: '2h',
      studentCount: 24,
      status: TPStatus.published,
      category: TPCategory.cardiology,
    ),
    PracticalWork(
      id: '2',
      title: 'Système Nerveux Central',
      description:
          'Étude interactive du cerveau et de la moelle épinière avec cas cliniques',
      duration: '3h',
      studentCount: 18,
      status: TPStatus.published,
      category: TPCategory.neurology,
    ),
    PracticalWork(
      id: '3',
      title: 'Pathologies Respiratoires',
      description:
          'Simulation de diagnostics et traitements des maladies pulmonaires',
      duration: '2h30',
      studentCount: 0,
      status: TPStatus.draft,
      category: TPCategory.pulmonology,
    ),
  ];

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
    // TODO: Naviguer vers la page d'édition du TP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Édition de: ${tp.title}'),
        backgroundColor: const Color(0xFF23B8C0),
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
              setState(() {
                _practicalWorks.removeWhere((p) => p.id == tp.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TP supprimé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
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
          setState(() {
            _practicalWorks.add(newTP);
          });
        },
      ),
    );
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
                  const Text(
                    'Dr. Marie Dubois',
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    'MD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
            // Cas cliniques disponibles
            _buildAvailableCases(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCases() {
    final availableCases = [
      ClinicalCase(
        id: '1',
        title: 'Infarctus du myocarde',
        description: 'Cas d\'urgence cardiaque avec douleur thoracique',
        difficulty: 'hard',
        symptoms: [0, 1, 3, 4, 6], // Douleur thoracique, Essoufflement, Transpiration, Fatigue, Palpitations
        expectedDiagnosis: 'Infarctus du myocarde',
      ),
      ClinicalCase(
        id: '2',
        title: 'Pneumonie',
        description: 'Infection pulmonaire avec symptômes respiratoires',
        difficulty: 'medium',
        symptoms: [1, 7, 4], // Essoufflement, Toux, Fatigue
        expectedDiagnosis: 'Pneumonie',
      ),
      ClinicalCase(
        id: '3',
        title: 'Grippe',
        description: 'Infection virale courante',
        difficulty: 'easy',
        symptoms: [4, 5, 2], // Fatigue, Vertiges, Nausées
        expectedDiagnosis: 'Grippe',
      ),
    ];

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
        ...availableCases.map((caseItem) => _buildCaseCard(caseItem)),
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
    // Données de démonstration pour les étudiants
    final List<Student> students = [
      Student(
        id: '1',
        name: 'Sophie Martin',
        email: 'sophie.martin@email.com',
        tpId: '1',
        tpTitle: 'Anatomie du Cœur Humain',
        progress: 100,
        status: StudentStatus.completed,
        grade: 16.5,
      ),
      Student(
        id: '2',
        name: 'Lucas Dubois',
        email: 'lucas.dubois@email.com',
        tpId: '1',
        tpTitle: 'Anatomie du Cœur Humain',
        progress: 75,
        status: StudentStatus.inProgress,
      ),
    ];

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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export en cours...'),
                            backgroundColor: Color(0xFF23B8C0),
                          ),
                        );
                      },
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ajouter un étudiant'),
                            backgroundColor: Color(0xFF23B8C0),
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
                    _showGradeDialog(student);
                  },
                  icon: const Icon(Icons.emoji_events, color: Color(0xFF23B8C0), size: 20),
                  tooltip: 'Attribuer une note',
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Envoi d\'un message à ${student.name}'),
                        backgroundColor: const Color(0xFF23B8C0),
                      ),
                    );
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

  void _showGradeDialog(Student student) {
    final gradeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Attribuer une note à ${student.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: gradeController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Note /20',
            labelStyle: const TextStyle(color: Colors.white70),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Sauvegarder la note
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note attribuée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23B8C0),
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
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


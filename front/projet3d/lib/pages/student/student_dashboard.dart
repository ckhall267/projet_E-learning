import 'package:flutter/material.dart';
import '../../pages/login_page.dart';
import '../simulation_3d_page.dart';
import '../../models/clinical_case.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart'; // For contact professor
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/practical_work.dart';
import '../../models/student.dart';
import '../../widgets/tp_card.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentDashboard extends StatefulWidget {
  final String nom;
  final String prenom;
  final String token;

  const StudentDashboard({
    super.key, 
    required this.nom, 
    required this.prenom,
    required this.token,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedTab = 0;
  bool _isLoading = false;
  List<ClinicalCase> _clinicalCases = [];
  List<PracticalWork> _practicalWorks = [];
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchTPs();
    _fetchCases();
  }

  Future<void> _fetchTPs() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${_authService.baseUrl.replaceAll("/auth", "/tps")}/my'),
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
      _showError('Erreur connexion TPs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCases() async {
    setState(() => _isLoading = true);
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
        _showError('Erreur chargement Cas: ${response.body}');
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
                    'Espace Étudiant',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                    '${widget.prenom} ${widget.nom}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '2ème Année Médecine',
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
                decoration: const BoxDecoration(
                  color: Color(0xFF23B8C0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.prenom.isNotEmpty ? widget.prenom[0] : "E"}${widget.nom.isNotEmpty ? widget.nom[0] : "E"}',
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
          _buildTab(0, 'Mes TPs', Icons.science),
          _buildTab(1, 'Simulations', Icons.vrpano),
          _buildTab(2, 'Progression', Icons.bar_chart),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildNavigationTabs(),
          Expanded(
            child: Container(
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
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildTPContent();
      case 1:
        return _buildSimulationContent();
      case 2:
         return _buildProgressionContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTPContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
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
            'Accédez à vos TPs et réalisez les simulations',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_practicalWorks.isEmpty)
            const Center(child: Text("Aucun TP assigné", style: TextStyle(color: Colors.white70)))
          else
            ..._practicalWorks.map((tp) => TPCard(
                  tp: tp,
                  onView: () => _showTPCases(tp),
                )),
        ],
      ),
    );
  }

  void _showTPCases(PracticalWork tp) {
    // Filter cases related to this TP
    // Note: Backend JSON for TP includes 'casCliniques'? 
    // Let's check TravailPratique model. Yes, @OneToMany private List<CasClinique> casCliniques;
    // BUT PracticalWork.dart front model might not include it inside yet?
    // Let's check PracticalWork.dart. It DOES NOT include List<ClinicalCase>.
    // So we fetch cases separately or rely on _clinicalCases being loaded.
    // _clinicalCases contains ALL cases. We should filter them.
    // We need to check if ClinicalCase has tpId. Yes it does.
    
    final tpCases = _clinicalCases.where((c) => c.travailPratiqueId.toString() == tp.id).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cas - ${tp.title}',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
             if (tpCases.isEmpty)
               const Text("Aucun cas clinique pour ce TP", style: TextStyle(color: Colors.white70))
             else
               Expanded(
                 child: ListView(
                   children: tpCases.map((c) => _buildCaseCard(c)).toList(),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ma Progression',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suivez vos résultats et contactez vos professeurs',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_practicalWorks.isEmpty)
             const Center(child: Text("Aucune progression à afficher", style: TextStyle(color: Colors.white70)))
          else
            ..._practicalWorks.map((tp) {
              // Find the student in the list that matches the current user
              Student? currentUserStudent;
              try {
                // Name format in Student.dart is '${prenom} ${nom}'
                final currentName = '${widget.prenom} ${widget.nom}';
                currentUserStudent = tp.assignedStudents.firstWhere(
                  (s) => s.name.toLowerCase() == currentName.toLowerCase(), 
                  orElse: () => Student(id: '', name: '', email: '', tpId: '', tpTitle: '', progress: 0, status: StudentStatus.notStarted)
                );
              } catch (e) {
                // Ignore matching error
              }

              // Only display if student is found (should be always true if TPs are filtered by backend)
              return _buildProgressionCard(tp, currentUserStudent?.grade, currentUserStudent?.statusText ?? 'Non commencé');
            }),
        ],
      ),
    );
  }

  Widget _buildProgressionCard(PracticalWork tp, double? grade, String statusText) {
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
              Text(
                tp.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                 decoration: BoxDecoration(
                   color: statusText == 'Terminé' ? Colors.green.withOpacity(0.2) : const Color(0xFF23B8C0).withOpacity(0.2),
                   borderRadius: BorderRadius.circular(10),
                   border: Border.all(color: statusText == 'Terminé' ? Colors.green : const Color(0xFF23B8C0)),
                 ),
                 child: Text(
                   statusText,
                   style: TextStyle(color: statusText == 'Terminé' ? Colors.green : const Color(0xFF23B8C0), fontSize: 12, fontWeight: FontWeight.bold),
                 ),
              ),
            ],
           ),
           const SizedBox(height: 16),
           Row(
             children: [
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text("Note Obtenue", style: TextStyle(color: Colors.white70, fontSize: 12)),
                     const SizedBox(height: 4),
                     Text(
                       grade != null ? '$grade/20' : 'Non noté',
                       style: TextStyle(
                         color: grade != null ? Colors.white : Colors.white54,
                         fontSize: 20, 
                         fontWeight: FontWeight.bold
                       ),
                     ),
                   ],
                 ),
               ),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                      Text("Prof. ${tp.professorName}", style: const TextStyle(color: Colors.white, fontSize: 14)),
                      if (tp.professorEmail.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: tp.professorEmail,
                                queryParameters: {
                                  'subject': 'Question sur le TP ${tp.title}',
                                }
                              );
                              if (await canLaunchUrl(emailLaunchUri)) {
                                await launchUrl(emailLaunchUri);
                              }
                          },
                          icon: const Icon(Icons.mail, size: 16, color: Color(0xFF23B8C0)),
                          label: const Text("Contacter", style: TextStyle(color: Color(0xFF23B8C0))),
                        ),
                   ],
                 ),
               ),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildSimulationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulations Disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
             const Center(child: CircularProgressIndicator())
          else if (_clinicalCases.isEmpty)
             const Center(child: Text("Aucun cas clinique disponible", style: TextStyle(color: Colors.white70)))
          else
             ..._clinicalCases.map((caseItem) => _buildCaseCard(caseItem)),
        ],
      ),
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
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF23B8C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_services, color: Color(0xFF23B8C0)),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
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
              child: const Text(
                'Commencer la simulation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

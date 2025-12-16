import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/symptom.dart';
import '../models/organ.dart';
import '../models/clinical_case.dart';
import '../services/ai_service.dart';
import 'simulation_3d_js_helper_stub.dart'
    if (dart.library.html) 'simulation_3d_js_helper.dart' as js_helper;

// Import conditionnel pour web
import 'simulation_3d_web_stub.dart'
    if (dart.library.html) 'simulation_3d_web_impl.dart' as web_helper;

class Simulation3DPage extends StatefulWidget {
  final ClinicalCase? initialCase;

  const Simulation3DPage({super.key, this.initialCase});

  @override
  State<Simulation3DPage> createState() => _Simulation3DPageState();
}

class _Simulation3DPageState extends State<Simulation3DPage> {
  final AIService _aiService = AIService();
  final TextEditingController _diagnosisController = TextEditingController();
  
  List<Symptom> _symptoms = [];
  List<Organ> _organs = [];
  List<int> _selectedSymptomIds = [];
  Organ? _selectedOrgan;
  bool _isLoading = false;
  bool _show3DView = false;
  CheckAnswerResponse? _aiResponse;
  RecommendationResponse? _recommendations;
  ClinicalCase? _currentCase;

  @override
  void initState() {
    super.initState();
    _currentCase = widget.initialCase;
    _initializeData();
    _loadRecommendations();
    _register3DView();
  }

  void _register3DView() {
    if (kIsWeb) {
      _registerThreeJSViewer();
    }
  }

  void _registerThreeJSViewer() {
    // L'enregistrement sera fait via le helper web
    // Pour éviter les erreurs de compilation, on utilise une approche conditionnelle
  }

  void _initializeData() {
    // Données de démonstration - À remplacer par des données réelles
    _symptoms = [
      Symptom(id: 0, name: 'Douleur thoracique', description: 'Douleur dans la poitrine', organ: 'Cœur'),
      Symptom(id: 1, name: 'Essoufflement', description: 'Difficulté à respirer', organ: 'Poumons'),
      Symptom(id: 2, name: 'Nausées', description: 'Sensation de nausée', organ: 'Estomac'),
      Symptom(id: 3, name: 'Transpiration', description: 'Transpiration excessive', organ: 'Peau'),
      Symptom(id: 4, name: 'Fatigue', description: 'Fatigue intense', organ: 'Général'),
      Symptom(id: 5, name: 'Vertiges', description: 'Sensation de vertige', organ: 'Cerveau'),
      Symptom(id: 6, name: 'Palpitations', description: 'Battements cardiaques irréguliers', organ: 'Cœur'),
      Symptom(id: 7, name: 'Toux', description: 'Toux persistante', organ: 'Poumons'),
    ];

    _organs = [
      Organ(
        id: 'heart',
        name: 'Cœur',
        description: 'Organe cardiaque',
        relatedSymptoms: ['Douleur thoracique', 'Palpitations'],
        color: '#FF6B6B',
      ),
      Organ(
        id: 'lungs',
        name: 'Poumons',
        description: 'Organes respiratoires',
        relatedSymptoms: ['Essoufflement', 'Toux'],
        color: '#4ECDC4',
      ),
      Organ(
        id: 'brain',
        name: 'Cerveau',
        description: 'Système nerveux central',
        relatedSymptoms: ['Vertiges'],
        color: '#95E1D3',
      ),
      Organ(
        id: 'stomach',
        name: 'Estomac',
        description: 'Organe digestif',
        relatedSymptoms: ['Nausées'],
        color: '#F38181',
      ),
    ];

    if (_currentCase != null) {
      _selectedSymptomIds = List.from(_currentCase!.symptoms);
    }
  }

  Future<void> _loadRecommendations() async {
    if (_currentCase == null) return;
    
    try {
      final response = await _aiService.recommendCases(
        currentCase: _currentCase!.title,
        completedCases: [],
        nRecommendations: 3,
      );
      setState(() {
        _recommendations = response;
      });
    } catch (e) {
      // Ignorer les erreurs pour l'instant
      print('Erreur lors du chargement des recommandations: $e');
    }
  }

  Future<void> _checkDiagnosis() async {
    if (_selectedSymptomIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un symptôme'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un diagnostic'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    try {
      final response = await _aiService.checkAnswer(
        symptoms: _selectedSymptomIds,
        studentAnswer: _diagnosisController.text.trim(),
        expectedDisease: _currentCase?.expectedDiagnosis,
      );

      setState(() {
        _aiResponse = response;
        _isLoading = false;
      });

      // Afficher un message de feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.feedback),
          backgroundColor: response.isCorrect ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleSymptom(Symptom symptom) {
    setState(() {
      if (_selectedSymptomIds.contains(symptom.id)) {
        _selectedSymptomIds.remove(symptom.id);
      } else {
        _selectedSymptomIds.add(symptom.id);
      }
    });
  }

  void _selectOrgan(Organ organ) {
    setState(() {
      final wasSelected = _selectedOrgan?.id == organ.id;
      _selectedOrgan = wasSelected ? null : organ;
      
      // Mettre à jour les organes highlightés
      _organs = _organs.map((o) {
        return o.copyWith(isHighlighted: o.id == organ.id && !wasSelected);
      }).toList();
    });

    // Envoyer un message à Three.js pour afficher/masquer l'organe
    if (kIsWeb) {
      _sendMessageTo3D(_selectedOrgan != null && _selectedOrgan!.id == organ.id 
          ? {'type': 'showOrgan', 'organId': organ.id}
          : {'type': 'hideAllOrgans'});
    }
  }

  void _sendMessageTo3D(Map<String, dynamic> message) {
    if (kIsWeb) {
      try {
        // Utiliser le helper pour envoyer le message
        js_helper.sendMessageTo3D(message);
      } catch (e) {
        print('Erreur lors de l\'envoi du message à Three.js: $e');
      }
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Row(
        children: [
          // Panneau gauche - Vue 3D et organes
          Expanded(
            flex: 2,
            child: _build3DView(),
          ),
          // Panneau droit - Symptômes, diagnostic, résultats
          Expanded(
            flex: 1,
            child: _buildControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _build3DView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)],
        ),
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simulation 3D - Patient',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentCase != null)
                        Text(
                          _currentCase!.title,
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
          ),
          // Zone 3D (placeholder pour Three.js)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: _show3DView && kIsWeb
                  ? _buildThreeJSView()
                  : _build3DPlaceholder(),
            ),
          ),
          // Liste des organes interactifs
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _organs.length,
              itemBuilder: (context, index) {
                final organ = _organs[index];
                return _buildOrganCard(organ);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPlaceholder() {
    return Stack(
      children: [
        // Placeholder pour Three.js
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Vue 3D du Patient',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? 'Cliquez sur le bouton pour charger la vue 3D'
                    : 'Vue 3D disponible sur la version web',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _show3DView = true;
                    });
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Charger la vue 3D'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23B8C0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThreeJSView() {
    if (!kIsWeb) {
      return _build3DPlaceholder();
    }

    // Pour Flutter Web, utiliser directement un iframe via un widget personnalisé
    return _buildIframeView();
  }

  Widget _buildIframeView() {
    // Créer un widget qui charge directement l'iframe
    return Builder(
      builder: (context) {
        // Enregistrer la vue une seule fois
        if (!_isRegistered) {
          _registerIframeView();
          _isRegistered = true;
        }
        
        return HtmlElementView(
          viewType: 'threejs-viewer-iframe',
          onPlatformViewCreated: (int viewId) {
            // Vue créée avec succès
          },
        );
      },
    );
  }

  static bool _isRegistered = false;

  void _registerIframeView() {
    if (kIsWeb) {
      // Utiliser l'import conditionnel pour enregistrer la vue
      _registerWebViewFactory();
    }
  }

  void _registerWebViewFactory() {
    // Utiliser l'import conditionnel
    web_helper.registerThreeJSViewerWeb();
  }

  Widget _buildOrganCard(Organ organ) {
    final isSelected = _selectedOrgan?.id == organ.id;
    return GestureDetector(
      onTap: () => _selectOrgan(organ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF23B8C0).withOpacity(0.3)
              : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF23B8C0)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getOrganIcon(organ.id),
              color: isSelected ? const Color(0xFF23B8C0) : Colors.white70,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              organ.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOrganIcon(String organId) {
    switch (organId) {
      case 'heart':
        return Icons.favorite;
      case 'lungs':
        return Icons.air;
      case 'brain':
        return Icons.psychology;
      case 'stomach':
        return Icons.restaurant;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildControlPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(
          left: BorderSide(color: Color(0xFF0F0F1E), width: 2),
        ),
      ),
      child: Column(
        children: [
          // En-tête du panneau
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1E),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.medical_information, color: Color(0xFF23B8C0)),
                SizedBox(width: 12),
                Text(
                  'Diagnostic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symptômes sélectionnés
                  _buildSymptomsSection(),
                  const SizedBox(height: 24),
                  // Zone de diagnostic
                  _buildDiagnosisSection(),
                  const SizedBox(height: 24),
                  // Résultats IA
                  if (_aiResponse != null) _buildAIResultsSection(),
                  const SizedBox(height: 24),
                  // Recommandations
                  if (_recommendations != null) _buildRecommendationsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptômes sélectionnés',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _symptoms.map((symptom) {
            final isSelected = _selectedSymptomIds.contains(symptom.id);
            return FilterChip(
              label: Text(symptom.name),
              selected: isSelected,
              onSelected: (_) => _toggleSymptom(symptom),
              selectedColor: const Color(0xFF23B8C0).withOpacity(0.3),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF23B8C0)
                    : Colors.white.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
        if (_selectedSymptomIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF23B8C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF23B8C0).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF23B8C0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedSymptomIds.length} symptôme(s) sélectionné(s)',
                    style: const TextStyle(
                      color: Color(0xFF23B8C0),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre diagnostic',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _diagnosisController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ex: Infarctus, Pneumonie...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _checkDiagnosis,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23B8C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Vérifier le diagnostic',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIResultsSection() {
    if (_aiResponse == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _aiResponse!.isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _aiResponse!.isCorrect
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _aiResponse!.isCorrect ? Icons.check_circle : Icons.cancel,
                color: _aiResponse!.isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _aiResponse!.isCorrect ? 'Diagnostic correct !' : 'Diagnostic incorrect',
                style: TextStyle(
                  color: _aiResponse!.isCorrect ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiResponse!.feedback,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Confiance de l\'IA : ',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${(_aiResponse!.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF23B8C0),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Diagnostic prédit: ${_aiResponse!.predictedDisease}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_recommendations == null || _recommendations!.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.recommend, color: Color(0xFF23B8C0)),
            SizedBox(width: 8),
            Text(
              'Cas recommandés',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recommendations!.recommendations.map((recommendation) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF23B8C0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}


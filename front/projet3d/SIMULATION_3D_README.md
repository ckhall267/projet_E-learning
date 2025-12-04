# Simulation 3D avec Intégration IA

Ce document explique comment utiliser la fonctionnalité de simulation 3D avec l'intégration de l'IA pour le diagnostic médical.

## Architecture

### Composants principaux

1. **Service IA** (`lib/services/ai_service.dart`)
   - Communication avec l'API FastAPI backend
   - Méthodes : `checkAnswer()`, `predictDisease()`, `recommendCases()`

2. **Page Simulation 3D** (`lib/pages/simulation_3d_page.dart`)
   - Interface utilisateur pour la simulation
   - Sélection de symptômes
   - Saisie de diagnostic
   - Affichage des résultats IA

3. **Modèles de données**
   - `Symptom` : Représente un symptôme médical
   - `Organ` : Représente un organe du corps
   - `ClinicalCase` : Représente un cas clinique

4. **Vue 3D** (`web/threejs_viewer.html`)
   - Modèle 3D du patient utilisant Three.js
   - Interaction avec les organes
   - Rotation et zoom

## Fonctionnalités

### 1. Vérification de diagnostic

L'étudiant peut :
- Sélectionner des symptômes
- Proposer un diagnostic
- Obtenir une réponse de l'IA avec :
  - Correct/Faux
  - Pourcentage de confiance
  - Feedback détaillé

### 2. Recommandation de cas

Le système IA recommande automatiquement :
- Les prochains cas adaptés au niveau de l'étudiant
- Basé sur l'historique et la difficulté

## Configuration

### 1. Backend IA

Assurez-vous que le serveur FastAPI est démarré :

```bash
cd IA/ai_python
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000
```

### 2. Configuration de l'URL de l'API

Dans `lib/services/ai_service.dart`, modifiez l'URL si nécessaire :

```dart
final AIService _aiService = AIService(
  baseUrl: 'http://localhost:8000' // ou votre URL
);
```

### 3. Vue 3D (Web uniquement)

Pour la version web, le fichier `web/threejs_viewer.html` est automatiquement chargé.

Pour une intégration complète dans Flutter Web, vous pouvez utiliser :

```dart
import 'dart:html' as html;
import 'dart:ui' as ui;

// Enregistrer la vue
html.platformViewRegistry.registerViewFactory(
  'threejs-viewer',
  (int viewId) {
    final html.IFrameElement iframe = html.IFrameElement()
      ..src = 'threejs_viewer.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return iframe;
  },
);

// Utiliser dans le widget
HtmlElementView(viewType: 'threejs-viewer')
```

## Utilisation

### Pour les étudiants

1. Accéder à la page "Simulation 3D" depuis le dashboard
2. Sélectionner un cas clinique
3. Examiner le patient 3D
4. Cliquer sur les organes pour voir les symptômes associés
5. Sélectionner les symptômes observés
6. Proposer un diagnostic
7. Vérifier avec l'IA
8. Consulter les recommandations de cas suivants

### Pour les professeurs

1. Accéder au dashboard professeur
2. Onglet "Simulation 3D"
3. Voir les cas disponibles
4. Lancer une simulation pour démonstration

## API Endpoints utilisés

### POST /check_answer

Vérifie si le diagnostic de l'étudiant est correct.

**Request:**
```json
{
  "symptoms": [0, 1, 5, 12, 23],
  "student_answer": "Infarctus",
  "expected_disease": null
}
```

**Response:**
```json
{
  "is_correct": true,
  "predicted_disease": "Infarctus",
  "confidence": 0.95,
  "feedback": "Correct! The disease is Infarctus."
}
```

### POST /recommend

Recommandations de cas suivants.

**Request:**
```json
{
  "current_case": "Infarctus",
  "completed_cases": [],
  "n_recommendations": 3,
  "difficulty": null
}
```

**Response:**
```json
{
  "recommendations": ["Pneumonie", "Grippe", "Angine"],
  "current_cluster": 2
}
```

## Structure des données

### Symptômes

Les symptômes sont représentés par des indices (IDs) correspondant aux colonnes du modèle ML.

Exemple :
- 0 : Douleur thoracique
- 1 : Essoufflement
- 2 : Nausées
- etc.

### Organes

Les organes sont mappés aux symptômes :

- **Cœur** : Douleur thoracique, Palpitations
- **Poumons** : Essoufflement, Toux
- **Cerveau** : Vertiges
- **Estomac** : Nausées

## Améliorations futures

1. **Intégration Three.js complète**
   - Utiliser `flutter_web_plugins` pour une meilleure intégration
   - Support mobile avec Unity ou autre solution 3D

2. **Modèles 3D avancés**
   - Modèles anatomiques détaillés
   - Animations de pathologies
   - Visualisation des examens (IRM, scanner)

3. **Fonctionnalités supplémentaires**
   - Historique des diagnostics
   - Statistiques de performance
   - Comparaison avec d'autres étudiants
   - Mode examen chronométré

## Dépannage

### L'API ne répond pas

1. Vérifiez que le serveur FastAPI est démarré
2. Vérifiez l'URL dans `ai_service.dart`
3. Vérifiez les CORS dans `app.py` (devrait être `allow_origins=["*"]`)

### La vue 3D ne s'affiche pas

1. Vérifiez que vous êtes sur la version web (`flutter run -d chrome`)
2. Vérifiez que `threejs_viewer.html` est dans le dossier `web/`
3. Vérifiez la console du navigateur pour les erreurs JavaScript

### Les symptômes ne correspondent pas

1. Vérifiez que les IDs de symptômes correspondent aux colonnes du modèle ML
2. Vérifiez le fichier de données dans `IA/ai_python/data/raw/`

## Support

Pour toute question ou problème, consultez :
- La documentation de l'API IA : `IA/ai_python/README.md`
- La documentation Flutter : https://flutter.dev/docs


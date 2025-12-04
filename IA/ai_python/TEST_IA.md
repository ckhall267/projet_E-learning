# Guide de Test de la Partie IA

Ce guide explique comment tester l'intégration IA avec l'application Flutter.

## Prérequis

1. Python 3.8+ installé
2. Les dépendances Python installées
3. Les modèles ML entraînés (optionnel pour les tests de base)

## Étape 1 : Installation des dépendances

```bash
cd IA/ai_python
pip install -r requirements.txt
```

## Étape 2 : Vérifier que les modèles sont entraînés

Les modèles doivent être dans `experiments/best_models/` :

- `diagnostic_model.pkl` - Modèle de diagnostic
- `recommender_model.pkl` - Modèle de recommandation
- `label_encoder.pkl` - Encodeur des labels
- `scaler.pkl` - Scaler pour les features
- `feature_columns.pkl` - Colonnes de features

Si les modèles n'existent pas, entraînez-les :

```bash
# Entraîner le modèle de diagnostic
python -m src.train_diagnostic --data_path data/raw/Final_Augmented_dataset_Diseases_and_Symptoms.csv

# Entraîner le modèle de recommandation
python -m src.train_recommender --data_path data/raw/Final_Augmented_dataset_Diseases_and_Symptoms.csv
```

## Étape 3 : Démarrer le serveur FastAPI

```bash
cd IA/ai_python
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000
```

Le serveur devrait démarrer et afficher :
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

## Étape 4 : Tester l'API directement

### 4.1 Vérifier la santé de l'API

```bash
curl http://localhost:8000/health
```

Réponse attendue :
```json
{
  "status": "healthy",
  "models_loaded": {
    "diagnostic": true,
    "recommender": true,
    "preprocessors": true
  }
}
```

### 4.2 Tester la vérification de diagnostic

```bash
curl -X POST "http://localhost:8000/check_answer" \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": [0, 1, 3, 6],
    "student_answer": "Infarctus"
  }'
```

Réponse attendue :
```json
{
  "is_correct": true,
  "predicted_disease": "Infarctus",
  "confidence": 0.95,
  "feedback": "Correct! The disease is Infarctus."
}
```

### 4.3 Tester la prédiction de diagnostic

```bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": [0, 1, 3, 6]
  }'
```

### 4.4 Tester les recommandations

```bash
curl -X POST "http://localhost:8000/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "current_case": "Infarctus",
    "completed_cases": [],
    "n_recommendations": 3
  }'
```

## Étape 5 : Tester depuis l'application Flutter

### 5.1 Configurer l'URL de l'API

Dans `front/projet3d/lib/services/ai_service.dart`, vérifiez que l'URL est correcte :

```dart
final AIService _aiService = AIService(
  baseUrl: 'http://localhost:8000'  // ou votre IP si test sur mobile
);
```

**Important** : Si vous testez sur un appareil mobile ou un émulateur :
- Android Emulator : utilisez `http://10.0.2.2:8000`
- iOS Simulator : utilisez `http://localhost:8000`
- Appareil physique : utilisez l'IP de votre machine (ex: `http://192.168.1.100:8000`)

### 5.2 Lancer l'application Flutter

```bash
cd front/projet3d
flutter run
```

### 5.3 Tester dans l'application

1. **Se connecter** à l'application
2. **Aller dans "Simulation 3D"** depuis le dashboard
3. **Sélectionner un cas clinique** (ex: "Infarctus du myocarde")
4. **Sélectionner des symptômes** :
   - Douleur thoracique (id: 0)
   - Essoufflement (id: 1)
   - Transpiration (id: 3)
   - Palpitations (id: 6)
5. **Entrer un diagnostic** : "Infarctus"
6. **Cliquer sur "Vérifier le diagnostic"**
7. **Vérifier la réponse** :
   - ✅ Correct/Faux
   - Pourcentage de confiance
   - Feedback détaillé

## Étape 6 : Tests avec Python (optionnel)

Vous pouvez aussi tester directement avec Python :

```python
import requests

# Test de vérification
response = requests.post(
    "http://localhost:8000/check_answer",
    json={
        "symptoms": [0, 1, 3, 6],
        "student_answer": "Infarctus"
    }
)
print(response.json())

# Test de recommandation
response = requests.post(
    "http://localhost:8000/recommend",
    json={
        "current_case": "Infarctus",
        "completed_cases": [],
        "n_recommendations": 3
    }
)
print(response.json())
```

## Dépannage

### Erreur : "Connection refused"

- Vérifiez que le serveur FastAPI est bien démarré
- Vérifiez le port (8000 par défaut)
- Vérifiez les CORS dans `app.py` (devrait être `allow_origins=["*"]`)

### Erreur : "Diagnostic model not loaded"

- Vérifiez que les modèles sont dans `experiments/best_models/`
- Vérifiez les logs du serveur au démarrage
- Entraînez les modèles si nécessaire

### Erreur : "Preprocessors not loaded"

- Vérifiez que `label_encoder.pkl`, `scaler.pkl`, etc. existent
- Ré-entraînez les modèles pour régénérer les preprocessors

### Les symptômes ne correspondent pas

- Vérifiez que les IDs de symptômes correspondent aux colonnes du modèle
- Consultez `feature_columns.pkl` pour voir les colonnes disponibles

## Tests de performance

Pour tester les performances de l'API :

```bash
# Installer Apache Bench ou utiliser curl en boucle
for i in {1..10}; do
  curl -X POST "http://localhost:8000/check_answer" \
    -H "Content-Type: application/json" \
    -d '{"symptoms": [0, 1, 3, 6], "student_answer": "Infarctus"}' \
    -w "\nTime: %{time_total}s\n"
done
```

## Vérification des logs

Les logs du serveur FastAPI affichent :
- Les requêtes reçues
- Les erreurs éventuelles
- Les temps de réponse

Surveillez la console où le serveur est lancé pour voir les détails.



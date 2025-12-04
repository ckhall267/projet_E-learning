# Guide de Test - Intégration IA avec Flutter

Guide complet pour tester l'intégration de l'IA avec l'application Flutter.

## 📋 Table des matières

1. [Préparation](#préparation)
2. [Démarrer le serveur IA](#démarrer-le-serveur-ia)
3. [Tester l'API directement](#tester-lapi-directement)
4. [Tester depuis Flutter](#tester-depuis-flutter)
5. [Scénarios de test](#scénarios-de-test)
6. [Dépannage](#dépannage)

## 🚀 Préparation

### 1. Vérifier les dépendances Python

```bash
cd IA/ai_python
pip install -r requirements.txt
```

### 2. Vérifier que les modèles sont entraînés

Les fichiers suivants doivent exister dans `IA/ai_python/experiments/best_models/` :

- ✅ `diagnostic_model.pkl`
- ✅ `recommender_model.pkl`
- ✅ `label_encoder.pkl`
- ✅ `scaler.pkl`
- ✅ `feature_columns.pkl`

Si les modèles n'existent pas :

```bash
cd IA/ai_python

# Entraîner le modèle de diagnostic
python -m src.train_diagnostic --data_path data/raw/Final_Augmented_dataset_Diseases_and_Symptoms.csv

# Entraîner le modèle de recommandation
python -m src.train_recommender --data_path data/raw/Final_Augmented_dataset_Diseases_and_Symptoms.csv
```

## 🖥️ Démarrer le serveur IA

### Terminal 1 : Serveur FastAPI

```bash
cd IA/ai_python
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000
```

Vous devriez voir :
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

**Important** : Gardez ce terminal ouvert pendant les tests.

## 🧪 Tester l'API directement

### Option 1 : Script Python de test

```bash
cd IA/ai_python
python test_api_simple.py
```

Ce script teste automatiquement :
- ✅ Health check
- ✅ Prédiction de diagnostic
- ✅ Vérification de réponse (correct/incorrect)
- ✅ Recommandations

### Option 2 : Tests manuels avec curl

#### Test 1 : Health Check

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

#### Test 2 : Vérification de diagnostic

```bash
curl -X POST "http://localhost:8000/check_answer" \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": [0, 1, 3, 6],
    "student_answer": "Infarctus"
  }'
```

#### Test 3 : Recommandations

```bash
curl -X POST "http://localhost:8000/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "current_case": "Infarctus",
    "completed_cases": [],
    "n_recommendations": 3
  }'
```

## 📱 Tester depuis Flutter

### 1. Configurer l'URL de l'API

Ouvrez `front/projet3d/lib/services/ai_service.dart` et vérifiez l'URL :

```dart
class AIService {
  final String baseUrl;
  
  AIService({this.baseUrl = 'http://localhost:8000'});
  // ...
}
```

**Configuration selon la plateforme :**

- **Web (Chrome)** : `http://localhost:8000` ✅
- **Android Emulator** : `http://10.0.2.2:8000` ✅
- **iOS Simulator** : `http://localhost:8000` ✅
- **Appareil physique** : `http://VOTRE_IP:8000` (ex: `http://192.168.1.100:8000`)

Pour trouver votre IP :
- Windows : `ipconfig` → chercher "IPv4"
- Mac/Linux : `ifconfig` ou `ip addr`

### 2. Lancer l'application Flutter

```bash
cd front/projet3d
flutter run
```

### 3. Scénario de test complet

#### Étape 1 : Accéder à la simulation 3D

1. Se connecter à l'application
2. Aller dans le dashboard
3. Cliquer sur l'onglet **"Simulation 3D"**

#### Étape 2 : Sélectionner un cas clinique

1. Choisir un cas (ex: **"Infarctus du myocarde"**)
2. Cliquer sur **"Lancer la simulation"**

#### Étape 3 : Sélectionner les symptômes

Dans le panneau de droite, sélectionner les symptômes observés :

- ✅ **Douleur thoracique** (id: 0)
- ✅ **Essoufflement** (id: 1)
- ✅ **Transpiration** (id: 3)
- ✅ **Palpitations** (id: 6)

#### Étape 4 : Proposer un diagnostic

1. Dans le champ **"Votre diagnostic"**, entrer : `Infarctus`
2. Cliquer sur **"Vérifier le diagnostic"**

#### Étape 5 : Vérifier les résultats

Vous devriez voir :

- ✅ **Diagnostic correct !** (ou incorrect si vous avez mis autre chose)
- 📊 **Confiance** : 95% (exemple)
- 💬 **Feedback** : "Correct! The disease is Infarctus."
- 🎯 **Diagnostic prédit** : Infarctus

#### Étape 6 : Voir les recommandations

En bas du panneau, vous devriez voir :

- 📋 **Cas recommandés** :
  1. Pneumonie
  2. Grippe
  3. Angine

## 🎯 Scénarios de test

### Scénario 1 : Diagnostic correct

**Symptômes** : [0, 1, 3, 6] (Douleur thoracique, Essoufflement, Transpiration, Palpitations)  
**Diagnostic proposé** : "Infarctus"  
**Résultat attendu** : ✅ Correct avec confiance élevée

### Scénario 2 : Diagnostic incorrect

**Symptômes** : [0, 1, 3, 6]  
**Diagnostic proposé** : "Grippe"  
**Résultat attendu** : ❌ Incorrect, avec le bon diagnostic suggéré

### Scénario 3 : Symptômes différents

**Symptômes** : [1, 7, 4] (Essoufflement, Toux, Fatigue)  
**Diagnostic proposé** : "Pneumonie"  
**Résultat attendu** : ✅ Correct (selon le modèle)

### Scénario 4 : Aucun symptôme sélectionné

**Symptômes** : []  
**Résultat attendu** : ⚠️ Message d'erreur "Veuillez sélectionner au moins un symptôme"

### Scénario 5 : Diagnostic vide

**Symptômes** : [0, 1, 3, 6]  
**Diagnostic proposé** : ""  
**Résultat attendu** : ⚠️ Message d'erreur "Veuillez entrer un diagnostic"

## 🔧 Dépannage

### Problème : "Connection refused"

**Cause** : Le serveur FastAPI n'est pas démarré ou l'URL est incorrecte.

**Solution** :
1. Vérifier que le serveur est démarré : `curl http://localhost:8000/health`
2. Vérifier l'URL dans `ai_service.dart`
3. Pour mobile, utiliser l'IP de la machine au lieu de localhost

### Problème : "Diagnostic model not loaded"

**Cause** : Les modèles ne sont pas entraînés ou introuvables.

**Solution** :
```bash
cd IA/ai_python
python -m src.train_diagnostic --data_path data/raw/Final_Augmented_dataset_Diseases_and_Symptoms.csv
```

### Problème : CORS Error

**Cause** : Les CORS ne sont pas configurés correctement.

**Solution** : Vérifier dans `IA/ai_python/src/api/app.py` :
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Devrait être ["*"] pour le développement
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Problème : Les symptômes ne correspondent pas

**Cause** : Les IDs de symptômes ne correspondent pas aux colonnes du modèle.

**Solution** :
1. Vérifier les IDs dans `simulation_3d_page.dart`
2. Vérifier les colonnes dans `feature_columns.pkl`
3. Ajuster les IDs si nécessaire

### Problème : Pas de recommandations

**Cause** : Le modèle de recommandation n'est pas entraîné ou le cas n'existe pas.

**Solution** :
```bash
cd IA/ai_python
python -m src.train_recommender --data_path data/raw/Final_Augmented_dataset_Diseases_and_Symptoms.csv
```

## 📊 Vérification des logs

### Logs du serveur FastAPI

Surveillez le terminal où le serveur est lancé pour voir :
- Les requêtes reçues
- Les erreurs éventuelles
- Les temps de réponse

### Logs Flutter

Dans la console Flutter, vous verrez :
- Les erreurs de connexion
- Les réponses de l'API
- Les erreurs de parsing

## ✅ Checklist de test

- [ ] Serveur FastAPI démarré et accessible
- [ ] Health check retourne "healthy"
- [ ] Modèles chargés correctement
- [ ] Test API avec curl/script Python fonctionne
- [ ] Application Flutter se connecte à l'API
- [ ] Sélection de symptômes fonctionne
- [ ] Vérification de diagnostic fonctionne
- [ ] Affichage des résultats correct
- [ ] Recommandations s'affichent
- [ ] Gestion des erreurs (pas de symptômes, diagnostic vide)

## 🎉 Test réussi !

Si tous les tests passent, l'intégration IA est fonctionnelle ! 🚀



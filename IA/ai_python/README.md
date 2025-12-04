# Microservice IA pour E-learning

Microservice Python pour le diagnostic médical et la recommandation de cas dans une plateforme d'e-learning.

## Fonctionnalités

### ✔ Diagnostic IA
- Vérifie si l'étudiant a donné la bonne maladie basée sur les symptômes
- Prédit la maladie avec un score de confiance
- Fournit des probabilités pour toutes les maladies possibles

### ✔ Recommandation IA
- Propose automatiquement les prochains cas adaptés
- Recommande des cas similaires en difficulté/complexité
- Filtre les cas déjà complétés par l'étudiant

## Structure du projet

```
ai_python/
├─ data/
│  ├─ raw/                     # Datasets originaux (symptoms_disease.csv, etc.)
│  └─ processed/               # Datasets prêts à l'entraînement
│
├─ notebooks/
│  ├─ 01_explore_data.ipynb    # Exploration des données
│  └─ 02_train_experiment.ipynb # Entraînement et expérimentation
│
├─ src/
│  ├─ data_preparation.py      # Lecture, nettoyage, feature engineering
│  ├─ train_diagnostic.py      # Script d'entraînement pour classification (diagnostic)
│  ├─ train_recommender.py     # Script d'entraînement pour recommandation/clustering
│  ├─ models/                  # Code de définition de modèles
│  │   └─ __init__.py
│  ├─ utils.py                 # Helpers : métriques, sauvegarde, load
│  └─ api/
│      ├─ app.py               # Serveur FastAPI d'inférence
│      └─ requirements.txt
│
├─ experiments/
│  └─ best_models/             # Sorties d'entraînement (model.pkl, encoder.pkl)
│
├─ Dockerfile                  # Pour packager le microservice IA
├─ requirements.txt            # Dépendances globales
└─ README.md
```

## Installation

### 1. Installation des dépendances

```bash
pip install -r requirements.txt
```

### 2. Préparation des données

Placez votre fichier CSV de données dans `data/raw/symptoms_disease.csv`. Le format attendu est :
- Colonnes de symptômes (valeurs binaires 0/1 ou indices)
- Une colonne "disease" avec le nom de la maladie

### 3. Préparation des données

```bash
python -m src.data_preparation
```

Ou utilisez la fonction dans un script :

```python
from src.data_preparation import prepare_diagnostic_data

data = prepare_diagnostic_data(
    data_path="data/raw/symptoms_disease.csv",
    test_size=0.2
)
```

## Entraînement

### Modèle de diagnostic

Entraîne un modèle de classification pour prédire la maladie à partir des symptômes :

```bash
python -m src.train_diagnostic --data_path data/raw/symptoms_disease.csv --model all
```

Options :
- `--model`: Modèle à entraîner (`random_forest`, `gradient_boosting`, `svm`, `logistic_regression`, ou `all`)
- `--test_size`: Proportion du jeu de test (défaut: 0.2)
- `--output_dir`: Répertoire de sortie (défaut: `experiments/best_models`)

### Système de recommandation

Entraîne un système de recommandation basé sur le clustering :

```bash
python -m src.train_recommender --data_path data/raw/symptoms_disease.csv --n_clusters 5
```

Options :
- `--n_clusters`: Nombre de clusters (défaut: 5)
- `--use_pca`: Utiliser PCA pour la réduction de dimensionnalité

## API

### Démarrage du serveur

```bash
# Développement
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000

# Production
python -m src.api.app
```

### Endpoints

#### 1. Health Check
```bash
GET /health
```

#### 2. Prédiction de diagnostic
```bash
POST /predict
Content-Type: application/json

{
  "symptoms": [0, 1, 5, 12, 23],
  "symptom_names": null
}
```

Réponse :
```json
{
  "predicted_disease": "Disease Name",
  "confidence": 0.95,
  "all_probabilities": {
    "Disease 1": 0.95,
    "Disease 2": 0.03,
    ...
  }
}
```

#### 3. Vérification de réponse
```bash
POST /check_answer
Content-Type: application/json

{
  "symptoms": [0, 1, 5, 12, 23],
  "student_answer": "Disease Name",
  "expected_disease": null
}
```

Réponse :
```json
{
  "is_correct": true,
  "predicted_disease": "Disease Name",
  "confidence": 0.95,
  "feedback": "Correct! The disease is Disease Name."
}
```

#### 4. Recommandation de cas
```bash
POST /recommend
Content-Type: application/json

{
  "current_case": "Disease Name",
  "completed_cases": ["Disease 1", "Disease 2"],
  "n_recommendations": 3,
  "difficulty": null
}
```

Réponse :
```json
{
  "recommendations": ["Disease 3", "Disease 4", "Disease 5"],
  "current_cluster": 2
}
```

## Docker

### Construction de l'image

```bash
docker build -t e-learning-ai:latest .
```

### Exécution du conteneur

```bash
docker run -p 8000:8000 \
  -v $(pwd)/experiments/best_models:/app/experiments/best_models \
  -v $(pwd)/data:/app/data \
  e-learning-ai:latest
```

## Notebooks

Les notebooks Jupyter permettent d'explorer les données et d'expérimenter avec les modèles :

1. **01_explore_data.ipynb** : Exploration et visualisation des données
2. **02_train_experiment.ipynb** : Entraînement et évaluation des modèles

Pour lancer Jupyter :

```bash
jupyter notebook notebooks/
```

## Utilisation

### Exemple Python

```python
from src.data_preparation import prepare_diagnostic_data
from src.train_diagnostic import train_random_forest
from src.train_recommender import train_recommender

# Préparation
data = prepare_diagnostic_data()

# Entraînement diagnostic
model, metrics = train_random_forest(
    data["X_train"], data["y_train"],
    data["X_test"], data["y_test"]
)

# Entraînement recommandation
recommender = train_recommender()
recommendations = recommender.recommend_next_cases("Disease Name", n_recommendations=3)
```

### Exemple API (curl)

```bash
# Prédiction
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{"symptoms": [0, 1, 5, 12, 23]}'

# Vérification réponse
curl -X POST "http://localhost:8000/check_answer" \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": [0, 1, 5, 12, 23],
    "student_answer": "Disease Name"
  }'

# Recommandation
curl -X POST "http://localhost:8000/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "current_case": "Disease Name",
    "completed_cases": [],
    "n_recommendations": 3
  }'
```

## Modèles supportés

### Diagnostic
- Random Forest
- Gradient Boosting
- SVM (Support Vector Machine)
- Logistic Regression

### Recommandation
- K-Means Clustering
- PCA (optionnel)

## Métriques

Les modèles sont évalués avec :
- Accuracy
- Precision
- Recall
- F1-Score
- Classification Report
- Confusion Matrix

## Notes

- Assurez-vous que les modèles sont entraînés avant d'utiliser l'API
- Les preprocessors (encoders, scalers) sont sauvegardés automatiquement
- Les métadonnées des modèles sont sauvegardées en JSON
- Le système de recommandation utilise le clustering pour grouper les cas similaires

## Licence

Ce projet fait partie d'une plateforme d'e-learning.


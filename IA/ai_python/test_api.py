"""
Script de test pour l'API FastAPI du modèle de diagnostic.
"""
import requests
import json
import time

API_BASE_URL = "http://localhost:8000"

def test_health_check():
    """Test du endpoint de health check."""
    print("=" * 60)
    print("Test: Health Check")
    print("=" * 60)
    
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        response.raise_for_status()
        data = response.json()
        print(f"✓ Status: {data['status']}")
        print(f"✓ Modèles chargés: {data['models_loaded']}")
        return True
    except requests.exceptions.ConnectionError:
        print("✗ Erreur: Impossible de se connecter à l'API")
        print("  Assurez-vous que le serveur est démarré avec:")
        print("  uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000")
        return False
    except Exception as e:
        print(f"✗ Erreur: {e}")
        return False


def test_predict(symptoms):
    """Test du endpoint de prédiction."""
    print("\n" + "=" * 60)
    print("Test: Prédiction de diagnostic")
    print("=" * 60)
    
    try:
        payload = {"symptoms": symptoms}
        print(f"Requête: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            f"{API_BASE_URL}/predict",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        data = response.json()
        
        print(f"\n✓ Réponse:")
        print(f"  Maladie prédite: {data['predicted_disease']}")
        print(f"  Confiance: {data['confidence']:.4f}")
        
        if data.get('all_probabilities'):
            print(f"\n  Top 3 probabilités:")
            sorted_probs = sorted(
                data['all_probabilities'].items(),
                key=lambda x: x[1],
                reverse=True
            )[:3]
            for disease, prob in sorted_probs:
                print(f"    {disease}: {prob:.4f}")
        
        return data
    except Exception as e:
        print(f"✗ Erreur: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"  Détails: {e.response.text}")
        return None


def test_check_answer(symptoms, student_answer):
    """Test du endpoint de vérification de réponse."""
    print("\n" + "=" * 60)
    print("Test: Vérification de réponse")
    print("=" * 60)
    
    try:
        payload = {
            "symptoms": symptoms,
            "student_answer": student_answer
        }
        print(f"Requête: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            f"{API_BASE_URL}/check_answer",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        data = response.json()
        
        print(f"\n✓ Réponse:")
        print(f"  Correct: {data['is_correct']}")
        print(f"  Maladie prédite: {data['predicted_disease']}")
        print(f"  Confiance: {data['confidence']:.4f}")
        print(f"  Feedback: {data['feedback']}")
        
        return data
    except Exception as e:
        print(f"✗ Erreur: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"  Détails: {e.response.text}")
        return None


def test_recommend(current_case, completed_cases=None, n_recommendations=3):
    """Test du endpoint de recommandation."""
    print("\n" + "=" * 60)
    print("Test: Recommandation de cas")
    print("=" * 60)
    
    try:
        payload = {
            "current_case": current_case,
            "completed_cases": completed_cases or [],
            "n_recommendations": n_recommendations
        }
        print(f"Requête: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            f"{API_BASE_URL}/recommend",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        data = response.json()
        
        print(f"\n✓ Réponse:")
        print(f"  Recommandations: {data['recommendations']}")
        if data.get('current_cluster') is not None:
            print(f"  Cluster actuel: {data['current_cluster']}")
        
        return data
    except Exception as e:
        print(f"✗ Erreur: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"  Détails: {e.response.text}")
        return None


def main():
    """Exécute tous les tests."""
    print("\n" + "=" * 60)
    print("TESTS DE L'API - E-learning AI Microservice")
    print("=" * 60)
    
    # Test 1: Health check
    if not test_health_check():
        print("\n⚠️  L'API n'est pas accessible. Veuillez démarrer le serveur d'abord.")
        return
    
    # Attendre un peu pour s'assurer que l'API est prête
    time.sleep(1)
    
    # Test 2: Prédiction avec des symptômes d'exemple
    # Note: Les indices doivent correspondre aux features du modèle
    # Ici, on utilise des indices arbitraires - à adapter selon votre dataset
    test_symptoms = [0, 1, 5, 12, 23]  # Exemple d'indices de symptômes
    prediction = test_predict(test_symptoms)
    
    if prediction:
        # Test 3: Vérification de réponse
        predicted_disease = prediction['predicted_disease']
        test_check_answer(test_symptoms, predicted_disease)  # Réponse correcte
        test_check_answer(test_symptoms, "Wrong Disease")    # Réponse incorrecte
        
        # Test 4: Recommandation
        test_recommend(predicted_disease, completed_cases=[], n_recommendations=3)
    
    print("\n" + "=" * 60)
    print("TESTS TERMINÉS")
    print("=" * 60)


if __name__ == "__main__":
    main()


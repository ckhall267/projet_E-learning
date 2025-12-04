"""
Script simple pour tester l'API IA
Usage: python test_api_simple.py
"""
import requests
import json
import sys

BASE_URL = "http://localhost:8000"

def test_health():
    """Test du endpoint health"""
    print("=" * 50)
    print("Test: Health Check")
    print("=" * 50)
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Erreur: {e}")
        return False

def test_predict(symptoms):
    """Test du endpoint predict"""
    print("\n" + "=" * 50)
    print("Test: Predict Disease")
    print("=" * 50)
    try:
        response = requests.post(
            f"{BASE_URL}/predict",
            json={"symptoms": symptoms}
        )
        print(f"Status: {response.status_code}")
        print(f"Request: symptoms = {symptoms}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Erreur: {e}")
        return False

def test_check_answer(symptoms, student_answer):
    """Test du endpoint check_answer"""
    print("\n" + "=" * 50)
    print("Test: Check Answer")
    print("=" * 50)
    try:
        response = requests.post(
            f"{BASE_URL}/check_answer",
            json={
                "symptoms": symptoms,
                "student_answer": student_answer
            }
        )
        print(f"Status: {response.status_code}")
        print(f"Request: symptoms = {symptoms}, answer = '{student_answer}'")
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        
        if result.get("is_correct"):
            print("✅ Diagnostic CORRECT!")
        else:
            print("❌ Diagnostic INCORRECT")
        print(f"Confiance: {result.get('confidence', 0) * 100:.1f}%")
        
        return response.status_code == 200
    except Exception as e:
        print(f"Erreur: {e}")
        return False

def test_recommend(current_case, completed_cases=None):
    """Test du endpoint recommend"""
    print("\n" + "=" * 50)
    print("Test: Recommend Cases")
    print("=" * 50)
    try:
        response = requests.post(
            f"{BASE_URL}/recommend",
            json={
                "current_case": current_case,
                "completed_cases": completed_cases or [],
                "n_recommendations": 3
            }
        )
        print(f"Status: {response.status_code}")
        print(f"Request: current_case = '{current_case}'")
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        
        if result.get("recommendations"):
            print("\n📋 Cas recommandés:")
            for i, rec in enumerate(result["recommendations"], 1):
                print(f"  {i}. {rec}")
        
        return response.status_code == 200
    except Exception as e:
        print(f"Erreur: {e}")
        return False

def main():
    """Fonction principale de test"""
    print("\n" + "=" * 50)
    print("TESTS DE L'API IA")
    print("=" * 50)
    print(f"\nAssurez-vous que le serveur est démarré sur {BASE_URL}")
    print("Commande: uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000\n")
    
    results = []
    
    # Test 1: Health check
    results.append(("Health Check", test_health()))
    
    # Test 2: Prédiction (symptômes d'infarctus)
    # Symptômes: Douleur thoracique (0), Essoufflement (1), Transpiration (3), Palpitations (6)
    results.append(("Predict", test_predict([0, 1, 3, 6])))
    
    # Test 3: Vérification de diagnostic correct
    results.append(("Check Answer (Correct)", test_check_answer([0, 1, 3, 6], "Infarctus")))
    
    # Test 4: Vérification de diagnostic incorrect
    results.append(("Check Answer (Incorrect)", test_check_answer([0, 1, 3, 6], "Grippe")))
    
    # Test 5: Recommandations
    results.append(("Recommend", test_recommend("Infarctus", [])))
    
    # Résumé
    print("\n" + "=" * 50)
    print("RÉSUMÉ DES TESTS")
    print("=" * 50)
    for test_name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    total = len(results)
    passed = sum(1 for _, success in results if success)
    print(f"\nTotal: {passed}/{total} tests réussis")
    
    if passed == total:
        print("\n🎉 Tous les tests sont passés!")
        return 0
    else:
        print("\n⚠️  Certains tests ont échoué")
        return 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\nTests interrompus par l'utilisateur")
        sys.exit(1)
    except requests.exceptions.ConnectionError:
        print(f"\n❌ Erreur: Impossible de se connecter à {BASE_URL}")
        print("Assurez-vous que le serveur FastAPI est démarré:")
        print("  cd IA/ai_python")
        print("  uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000")
        sys.exit(1)



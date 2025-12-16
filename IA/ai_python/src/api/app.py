"""
FastAPI application for diagnostic and recommendation inference.
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
import os
import sys
import numpy as np
import joblib
import pickle

# Add parent directories to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from src.data_preparation import DataPreparator
from src.utils import prepare_symptoms_vector, load_model, load_metadata

app = FastAPI(
    title="E-learning AI Microservice",
    description="API for diagnostic classification and case recommendation",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables for loaded models
diagnostic_model = None
recommender_model = None
preparator = None
feature_columns = None
model_metadata = None


class SymptomsRequest(BaseModel):
    """Request model for diagnostic prediction."""
    symptoms: List[int] = Field(..., description="List of symptom indices (binary or indices)")
    symptom_names: Optional[List[str]] = Field(None, description="Alternative: list of symptom names")


class DiagnosticResponse(BaseModel):
    """Response model for diagnostic prediction."""
    predicted_disease: str
    confidence: float
    is_correct: Optional[bool] = Field(None, description="Whether the prediction matches expected disease")
    all_probabilities: Optional[dict] = None


class RecommendationRequest(BaseModel):
    """Request model for case recommendation."""
    current_case: str = Field(..., description="Current disease/case name")
    completed_cases: Optional[List[str]] = Field(default=[], description="List of completed cases")
    n_recommendations: int = Field(default=3, ge=1, le=10, description="Number of recommendations")
    difficulty: Optional[str] = Field(None, description="Difficulty level: easy, medium, hard")


class RecommendationResponse(BaseModel):
    """Response model for case recommendations."""
    recommendations: List[str]
    current_cluster: Optional[int] = None


class CheckAnswerRequest(BaseModel):
    """Request model for checking student answer."""
    symptoms: List[int] = Field(..., description="List of symptom indices")
    student_answer: str = Field(..., description="Disease name provided by student")
    expected_disease: Optional[str] = Field(None, description="Expected disease (for validation)")


class CheckAnswerResponse(BaseModel):
    """Response model for answer checking."""
    is_correct: bool
    predicted_disease: str
    confidence: float
    feedback: str


def load_models():
    """Load models and preprocessors at startup."""
    global diagnostic_model, recommender_model, preparator, feature_columns, model_metadata
    
    models_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 
                             "experiments", "best_models")
    
    # Load diagnostic model
    diagnostic_path = os.path.join(models_dir, "diagnostic_model.pkl")
    if os.path.exists(diagnostic_path):
        diagnostic_model = load_model(diagnostic_path)
        model_metadata = load_metadata(diagnostic_path)
        print(f"Diagnostic model loaded from {diagnostic_path}")
    else:
        print(f"Warning: Diagnostic model not found at {diagnostic_path}")
    
    # Load recommender model
    recommender_path = os.path.join(models_dir, "recommender_model.pkl")
    if os.path.exists(recommender_path):
        recommender_model = load_model(recommender_path)
        print(f"Recommender model loaded from {recommender_path}")
    else:
        print(f"Warning: Recommender model not found at {recommender_path}")
    
    # Load preprocessors
    preparator = DataPreparator()
    try:
        preparator.load_preprocessors(models_dir)
        print(f"Preprocessors loaded from {models_dir}")
        
        # Get feature columns from preparator
        global feature_columns
        feature_columns = preparator.feature_columns
        if feature_columns:
            print(f"Feature columns loaded: {len(feature_columns)} features")
    except Exception as e:
        print(f"Warning: Could not load preprocessors: {e}")


@app.on_event("startup")
async def startup_event():
    """Load models when the application starts."""
    load_models()


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "E-learning AI Microservice",
        "endpoints": {
            "diagnostic": "/predict",
            "recommendation": "/recommend",
            "check_answer": "/check_answer",
            "symptoms": "/symptoms",
            "health": "/health"
        }
    }


@app.get("/symptoms")
async def get_symptoms():
    """Get list of all supported symptoms."""
    if feature_columns is None:
         # Try to load if not loaded (should be loaded on startup)
         load_models()
         if feature_columns is None:
             raise HTTPException(status_code=503, detail="Feature columns not loaded")
    
    return {
        "symptoms": [{"id": i, "name": name} for i, name in enumerate(feature_columns)]
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    models_loaded = {
        "diagnostic": diagnostic_model is not None,
        "recommender": recommender_model is not None,
        "preprocessors": preparator is not None and preparator.label_encoder is not None
    }
    
    return {
        "status": "healthy" if all(models_loaded.values()) else "degraded",
        "models_loaded": models_loaded
    }


@app.post("/predict", response_model=DiagnosticResponse)
async def predict_disease(request: SymptomsRequest):
    """
    Predict disease based on symptoms.
    
    Args:
        request: Symptoms request
        
    Returns:
        Diagnostic prediction with confidence
    """
    if diagnostic_model is None:
        raise HTTPException(status_code=503, detail="Diagnostic model not loaded")
    
    if preparator is None or preparator.scaler is None:
        raise HTTPException(status_code=503, detail="Preprocessors not loaded")
    
    try:
        # Prepare feature vector
        if feature_columns is None:
            # Fallback: infer from model if feature columns not available
            n_features = diagnostic_model.n_features_in_ if hasattr(diagnostic_model, 'n_features_in_') else len(request.symptoms)
            feature_vector = np.zeros(n_features)
            
            # Set symptoms to 1 (assuming symptoms are indices)
            for symptom_idx in request.symptoms:
                if 0 <= symptom_idx < n_features:
                    feature_vector[symptom_idx] = 1
            feature_vector = feature_vector.reshape(1, -1)
        else:
            feature_vector = prepare_symptoms_vector(request.symptoms, feature_columns)
        
        # Scale features
        feature_vector_scaled = preparator.scaler.transform(feature_vector.reshape(1, -1))
        
        # Predict
        prediction = diagnostic_model.predict(feature_vector_scaled)[0]
        probabilities = None
        
        if hasattr(diagnostic_model, 'predict_proba'):
            proba = diagnostic_model.predict_proba(feature_vector_scaled)[0]
            probabilities = {
                preparator.label_encoder.inverse_transform([i])[0]: float(prob)
                for i, prob in enumerate(proba)
            }
            confidence = float(max(proba))
        else:
            confidence = 1.0
        
        # Decode prediction
        predicted_disease = preparator.label_encoder.inverse_transform([prediction])[0]
        
        return DiagnosticResponse(
            predicted_disease=predicted_disease,
            confidence=confidence,
            all_probabilities=probabilities
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@app.post("/check_answer", response_model=CheckAnswerResponse)
async def check_answer(request: CheckAnswerRequest):
    """
    Check if student's answer is correct.
    
    Args:
        request: Check answer request with symptoms and student answer
        
    Returns:
        Answer validation result with feedback
    """
    if diagnostic_model is None:
        raise HTTPException(status_code=503, detail="Diagnostic model not loaded")
    
    try:
        # Get prediction
        pred_request = SymptomsRequest(symptoms=request.symptoms)
        prediction = await predict_disease(pred_request)
        
        # Compare with student answer
        is_correct = prediction.predicted_disease.lower().strip() == request.student_answer.lower().strip()
        
        # Generate feedback
        if is_correct:
            feedback = f"Correct! The disease is {prediction.predicted_disease}."
        else:
            feedback = f"Incorrect. The correct answer is {prediction.predicted_disease}, but you answered {request.student_answer}."
        
        # If expected disease is provided, use it for validation
        if request.expected_disease:
            is_correct = prediction.predicted_disease.lower().strip() == request.expected_disease.lower().strip()
        
        return CheckAnswerResponse(
            is_correct=is_correct,
            predicted_disease=prediction.predicted_disease,
            confidence=prediction.confidence,
            feedback=feedback
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Answer checking error: {str(e)}")


@app.post("/recommend", response_model=RecommendationResponse)
async def recommend_cases(request: RecommendationRequest):
    """
    Recommend next cases for the student.
    
    Args:
        request: Recommendation request
        
    Returns:
        List of recommended cases
    """
    if recommender_model is None:
        raise HTTPException(status_code=503, detail="Recommender model not loaded")
    
    try:
        if request.difficulty:
            recommendations = recommender_model.recommend_by_difficulty(
                current_difficulty=request.difficulty,
                completed_cases=request.completed_cases,
                n_recommendations=request.n_recommendations
            )
            current_cluster = None
        else:
            recommendations = recommender_model.recommend_next_cases(
                current_case=request.current_case,
                completed_cases=request.completed_cases,
                n_recommendations=request.n_recommendations
            )
            
            # Get current case cluster if available
            if hasattr(recommender_model, 'case_features') and request.current_case in recommender_model.case_features.index:
                current_cluster = int(recommender_model.case_clusters[
                    recommender_model.case_features.index == request.current_case
                ][0])
            else:
                current_cluster = None
        
        return RecommendationResponse(
            recommendations=recommendations,
            current_cluster=current_cluster
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Recommendation error: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)


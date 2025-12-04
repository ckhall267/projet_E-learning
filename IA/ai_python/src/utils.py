"""
Utility functions for metrics, model saving/loading, and helpers.
"""
import pickle
import os
import json
import numpy as np
import pandas as pd
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    classification_report, confusion_matrix
)
from typing import Dict, Any, Optional
import joblib


def calculate_metrics(y_true: np.ndarray, y_pred: np.ndarray, average: str = "weighted") -> Dict[str, float]:
    """
    Calculate classification metrics.
    
    Args:
        y_true: True labels
        y_pred: Predicted labels
        average: Averaging strategy for multi-class metrics
        
    Returns:
        Dictionary of metrics
    """
    metrics = {
        "accuracy": accuracy_score(y_true, y_pred),
        "precision": precision_score(y_true, y_pred, average=average, zero_division=0),
        "recall": recall_score(y_true, y_pred, average=average, zero_division=0),
        "f1_score": f1_score(y_true, y_pred, average=average, zero_division=0)
    }
    
    return metrics


def print_classification_report(y_true: np.ndarray, y_pred: np.ndarray, 
                                class_names: Optional[list] = None):
    """
    Print detailed classification report.
    
    Args:
        y_true: True labels
        y_pred: Predicted labels
        class_names: Optional list of class names
    """
    print("\n" + "="*50)
    print("CLASSIFICATION REPORT")
    print("="*50)
    print(classification_report(y_true, y_pred, target_names=class_names))
    print("\nCONFUSION MATRIX:")
    print(confusion_matrix(y_true, y_pred))
    print("="*50 + "\n")


def save_model(model: Any, filepath: str, metadata: Optional[Dict] = None):
    """
    Save a trained model to disk.
    
    Args:
        model: Trained model object
        filepath: Path to save the model
        metadata: Optional metadata to save alongside the model
    """
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    # Save model
    joblib.dump(model, filepath)
    print(f"Model saved to {filepath}")
    
    # Save metadata if provided
    if metadata:
        metadata_path = filepath.replace(".pkl", "_metadata.json")
        with open(metadata_path, "w") as f:
            json.dump(metadata, f, indent=2)
        print(f"Metadata saved to {metadata_path}")


def load_model(filepath: str) -> Any:
    """
    Load a saved model from disk.
    
    Args:
        filepath: Path to the saved model
        
    Returns:
        Loaded model object
    """
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"Model file not found: {filepath}")
    
    model = joblib.load(filepath)
    print(f"Model loaded from {filepath}")
    return model


def load_metadata(filepath: str) -> Optional[Dict]:
    """
    Load model metadata.
    
    Args:
        filepath: Path to the model file (metadata will be searched alongside)
        
    Returns:
        Metadata dictionary or None if not found
    """
    metadata_path = filepath.replace(".pkl", "_metadata.json")
    
    if os.path.exists(metadata_path):
        with open(metadata_path, "r") as f:
            metadata = json.load(f)
        return metadata
    
    return None


def save_experiment_results(results: Dict[str, Any], filepath: str = "experiments/experiment_results.json"):
    """
    Save experiment results to JSON file.
    
    Args:
        results: Dictionary of experiment results
        filepath: Path to save results
    """
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    # Convert numpy types to native Python types for JSON serialization
    def convert_to_serializable(obj):
        if isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        elif isinstance(obj, dict):
            return {k: convert_to_serializable(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [convert_to_serializable(item) for item in obj]
        return obj
    
    serializable_results = convert_to_serializable(results)
    
    with open(filepath, "w") as f:
        json.dump(serializable_results, f, indent=2)
    
    print(f"Experiment results saved to {filepath}")


def load_experiment_results(filepath: str = "experiments/experiment_results.json") -> Dict[str, Any]:
    """
    Load experiment results from JSON file.
    
    Args:
        filepath: Path to results file
        
    Returns:
        Dictionary of experiment results
    """
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"Results file not found: {filepath}")
    
    with open(filepath, "r") as f:
        results = json.load(f)
    
    return results


def prepare_symptoms_vector(symptoms: list, feature_columns: list) -> np.ndarray:
    """
    Convert a list of symptoms to a feature vector matching the training data format.
    
    Args:
        symptoms: List of symptom indices or names
        feature_columns: List of feature column names from training
        
    Returns:
        Feature vector as numpy array
    """
    # Create a zero vector
    feature_vector = np.zeros(len(feature_columns))
    
    # If symptoms are indices
    if all(isinstance(s, (int, np.integer)) for s in symptoms):
        for symptom_idx in symptoms:
            if 0 <= symptom_idx < len(feature_columns):
                feature_vector[symptom_idx] = 1
    
    # If symptoms are column names or strings
    else:
        for symptom in symptoms:
            if symptom in feature_columns:
                idx = feature_columns.index(symptom)
                feature_vector[idx] = 1
    
    return feature_vector.reshape(1, -1)


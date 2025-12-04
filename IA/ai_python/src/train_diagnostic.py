"""
Training script for diagnostic classification model.
Predicts the disease based on symptoms.
"""
import os
import sys
import argparse
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import GridSearchCV, cross_val_score
import joblib

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.data_preparation import DataPreparator, prepare_diagnostic_data
from src.utils import (
    calculate_metrics, print_classification_report,
    save_model, save_experiment_results
)


def train_random_forest(X_train: pd.DataFrame, y_train: pd.Series, 
                       X_test: pd.DataFrame, y_test: pd.Series,
                       n_estimators: int = 100, max_depth: int = None,
                       random_state: int = 42) -> tuple:
    """
    Train a Random Forest classifier.
    
    Returns:
        Tuple of (trained_model, metrics_dict)
    """
    print("\n" + "="*50)
    print("Training Random Forest Classifier")
    print("="*50)
    
    model = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        random_state=random_state,
        n_jobs=-1,
        verbose=1
    )
    
    model.fit(X_train, y_train)
    
    # Predictions
    y_pred_train = model.predict(X_train)
    y_pred_test = model.predict(X_test)
    
    # Metrics
    train_metrics = calculate_metrics(y_train, y_pred_train)
    test_metrics = calculate_metrics(y_test, y_pred_test)
    
    print(f"\nTrain Metrics: {train_metrics}")
    print(f"Test Metrics: {test_metrics}")
    
    print_classification_report(y_test, y_pred_test)
    
    return model, {"train": train_metrics, "test": test_metrics}


def train_gradient_boosting(X_train: pd.DataFrame, y_train: pd.Series,
                           X_test: pd.DataFrame, y_test: pd.Series,
                           n_estimators: int = 100, learning_rate: float = 0.1,
                           random_state: int = 42) -> tuple:
    """
    Train a Gradient Boosting classifier.
    
    Returns:
        Tuple of (trained_model, metrics_dict)
    """
    print("\n" + "="*50)
    print("Training Gradient Boosting Classifier")
    print("="*50)
    
    model = GradientBoostingClassifier(
        n_estimators=n_estimators,
        learning_rate=learning_rate,
        random_state=random_state,
        verbose=1
    )
    
    model.fit(X_train, y_train)
    
    # Predictions
    y_pred_train = model.predict(X_train)
    y_pred_test = model.predict(X_test)
    
    # Metrics
    train_metrics = calculate_metrics(y_train, y_pred_train)
    test_metrics = calculate_metrics(y_test, y_pred_test)
    
    print(f"\nTrain Metrics: {train_metrics}")
    print(f"Test Metrics: {test_metrics}")
    
    print_classification_report(y_test, y_pred_test)
    
    return model, {"train": train_metrics, "test": test_metrics}


def train_svm(X_train: pd.DataFrame, y_train: pd.Series,
             X_test: pd.DataFrame, y_test: pd.Series,
             C: float = 1.0, kernel: str = "rbf",
             random_state: int = 42) -> tuple:
    """
    Train an SVM classifier.
    
    Returns:
        Tuple of (trained_model, metrics_dict)
    """
    print("\n" + "="*50)
    print("Training SVM Classifier")
    print("="*50)
    
    model = SVC(
        C=C,
        kernel=kernel,
        random_state=random_state,
        probability=True
    )
    
    model.fit(X_train, y_train)
    
    # Predictions
    y_pred_train = model.predict(X_train)
    y_pred_test = model.predict(X_test)
    
    # Metrics
    train_metrics = calculate_metrics(y_train, y_pred_train)
    test_metrics = calculate_metrics(y_test, y_pred_test)
    
    print(f"\nTrain Metrics: {train_metrics}")
    print(f"Test Metrics: {test_metrics}")
    
    print_classification_report(y_test, y_pred_test)
    
    return model, {"train": train_metrics, "test": test_metrics}


def train_logistic_regression(X_train: pd.DataFrame, y_train: pd.Series,
                             X_test: pd.DataFrame, y_test: pd.Series,
                             C: float = 1.0, random_state: int = 42) -> tuple:
    """
    Train a Logistic Regression classifier.
    
    Returns:
        Tuple of (trained_model, metrics_dict)
    """
    print("\n" + "="*50)
    print("Training Logistic Regression Classifier")
    print("="*50)
    
    model = LogisticRegression(
        C=C,
        random_state=random_state,
        max_iter=1000,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    
    # Predictions
    y_pred_train = model.predict(X_train)
    y_pred_test = model.predict(X_test)
    
    # Metrics
    train_metrics = calculate_metrics(y_train, y_pred_train)
    test_metrics = calculate_metrics(y_test, y_pred_test)
    
    print(f"\nTrain Metrics: {train_metrics}")
    print(f"Test Metrics: {test_metrics}")
    
    print_classification_report(y_test, y_pred_test)
    
    return model, {"train": train_metrics, "test": test_metrics}


def compare_models(X_train: pd.DataFrame, y_train: pd.Series,
                  X_test: pd.DataFrame, y_test: pd.Series) -> dict:
    """
    Train and compare multiple models.
    
    Returns:
        Dictionary with all models and their metrics
    """
    results = {}
    
    # Train all models
    models_to_train = [
        ("random_forest", train_random_forest),
        ("gradient_boosting", train_gradient_boosting),
        ("svm", train_svm),
        ("logistic_regression", train_logistic_regression)
    ]
    
    for model_name, train_func in models_to_train:
        try:
            model, metrics = train_func(X_train, y_train, X_test, y_test)
            results[model_name] = {
                "model": model,
                "metrics": metrics
            }
        except Exception as e:
            print(f"Error training {model_name}: {e}")
            continue
    
    # Find best model
    best_model_name = None
    best_f1 = 0
    
    for model_name, result in results.items():
        f1 = result["metrics"]["test"]["f1_score"]
        if f1 > best_f1:
            best_f1 = f1
            best_model_name = model_name
    
    if best_model_name:
        print(f"\n{'='*50}")
        print(f"Best Model: {best_model_name} (F1-Score: {best_f1:.4f})")
        print(f"{'='*50}\n")
        results["best_model"] = best_model_name
    
    return results


def main():
    """Main training pipeline."""
    parser = argparse.ArgumentParser(description="Train diagnostic classification model")
    parser.add_argument("--data_path", type=str, default="data/raw/symptoms_disease.csv",
                       help="Path to raw data CSV file")
    parser.add_argument("--output_dir", type=str, default="experiments/best_models",
                       help="Directory to save trained models")
    parser.add_argument("--model", type=str, default="all",
                       choices=["random_forest", "gradient_boosting", "svm", "logistic_regression", "all"],
                       help="Model to train")
    parser.add_argument("--test_size", type=float, default=0.2,
                       help="Proportion of test set")
    
    args = parser.parse_args()
    
    # Prepare data
    print("Preparing data...")
    data = prepare_diagnostic_data(
        data_path=args.data_path,
        test_size=args.test_size
    )
    
    X_train = data["X_train"]
    X_test = data["X_test"]
    y_train = data["y_train"]
    y_test = data["y_test"]
    preparator = data["preparator"]
    
    # Train model(s)
    if args.model == "all":
        results = compare_models(X_train, y_train, X_test, y_test)
        best_model_name = results.get("best_model", "random_forest")
        best_model = results[best_model_name]["model"]
        best_metrics = results[best_model_name]["metrics"]
    else:
        train_funcs = {
            "random_forest": train_random_forest,
            "gradient_boosting": train_gradient_boosting,
            "svm": train_svm,
            "logistic_regression": train_logistic_regression
        }
        best_model, best_metrics = train_funcs[args.model](X_train, y_train, X_test, y_test)
        best_model_name = args.model
        results = {best_model_name: {"model": best_model, "metrics": best_metrics}}
    
    # Save best model
    os.makedirs(args.output_dir, exist_ok=True)
    model_path = os.path.join(args.output_dir, "diagnostic_model.pkl")
    
    metadata = {
        "model_type": best_model_name,
        "metrics": best_metrics,
        "n_features": X_train.shape[1],
        "n_classes": len(preparator.label_encoder.classes_),
        "classes": preparator.label_encoder.classes_.tolist()
    }
    
    save_model(best_model, model_path, metadata)
    
    # Save experiment results
    save_experiment_results({
        "model": best_model_name,
        "metrics": best_metrics,
        "all_results": {k: {"metrics": v["metrics"]} for k, v in results.items() if k != "best_model"}
    })
    
    print(f"\nTraining completed! Best model saved to {model_path}")


if __name__ == "__main__":
    main()


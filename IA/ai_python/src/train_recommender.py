"""
Training script for recommendation system.
Recommends next cases based on student performance and difficulty progression.
"""
import os
import sys
import argparse
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score
import joblib

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.data_preparation import DataPreparator
from src.utils import save_model, save_experiment_results


class CaseRecommender:
    """Recommends next cases based on student performance and case similarity."""
    
    def __init__(self, n_clusters: int = 5, random_state: int = 42):
        """
        Initialize the recommender.
        
        Args:
            n_clusters: Number of clusters for case grouping
            random_state: Random seed
        """
        self.n_clusters = n_clusters
        self.random_state = random_state
        self.kmeans = KMeans(n_clusters=n_clusters, random_state=random_state, n_init=10)
        self.scaler = StandardScaler()
        self.pca = None
        self.case_features = None
        self.case_clusters = None
        
    def prepare_case_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Prepare features for each case (disease).
        
        Args:
            df: DataFrame with symptoms and diseases
            
        Returns:
            DataFrame with case features
        """
        # Group by disease and calculate statistics
        disease_col = [col for col in df.columns if 'disease' in col.lower()][0] if any('disease' in col.lower() for col in df.columns) else None
        if not disease_col:
            raise ValueError("Disease column not found in dataframe")
        
        symptom_cols = [col for col in df.columns if col != disease_col]
        
        case_features = df.groupby(disease_col)[symptom_cols].agg([
            'mean', 'std', 'sum', 'count'
        ]).fillna(0)
        
        # Flatten column names
        case_features.columns = ['_'.join(col).strip() for col in case_features.columns.values]
        
        # Add difficulty metrics
        case_features['total_symptoms'] = df.groupby(disease_col)[symptom_cols].sum().sum(axis=1)
        case_features['avg_symptoms_per_case'] = df.groupby(disease_col)[symptom_cols].sum().mean(axis=1)
        
        self.case_features = case_features
        return case_features
    
    def fit(self, case_features: pd.DataFrame, use_pca: bool = False, n_components: int = None):
        """
        Fit the recommender on case features.
        
        Args:
            case_features: DataFrame with case features
            use_pca: Whether to use PCA for dimensionality reduction
            n_components: Number of PCA components (if None, auto-select)
        """
        # Scale features
        features_scaled = self.scaler.fit_transform(case_features)
        
        # Apply PCA if requested
        if use_pca:
            if n_components is None:
                n_components = min(10, features_scaled.shape[1] // 2)
            
            self.pca = PCA(n_components=n_components, random_state=self.random_state)
            features_scaled = self.pca.fit_transform(features_scaled)
            print(f"Applied PCA: {case_features.shape[1]} -> {n_components} components")
        
        # Cluster cases
        self.case_clusters = self.kmeans.fit_predict(features_scaled)
        
        # Calculate silhouette score
        silhouette = silhouette_score(features_scaled, self.case_clusters)
        print(f"Clustering completed. Silhouette score: {silhouette:.4f}")
        print(f"Cluster distribution: {pd.Series(self.case_clusters).value_counts().to_dict()}")
        
        return silhouette
    
    def recommend_next_cases(self, current_case: str, completed_cases: list = None,
                            n_recommendations: int = 3) -> list:
        """
        Recommend next cases based on current case and student progress.
        
        Args:
            current_case: Current disease/case name
            completed_cases: List of already completed cases
            n_recommendations: Number of recommendations to return
            
        Returns:
            List of recommended case names
        """
        if completed_cases is None:
            completed_cases = []
        
        # Get current case cluster
        if current_case not in self.case_features.index:
            # If case not found, recommend from all cases
            available_cases = [case for case in self.case_features.index if case not in completed_cases]
            return available_cases[:n_recommendations]
        
        current_cluster = self.case_clusters[self.case_features.index == current_case][0]
        
        # Get cases in same cluster (similar difficulty/complexity)
        similar_cases = self.case_features.index[self.case_clusters == current_cluster].tolist()
        
        # Filter out completed cases
        available_cases = [case for case in similar_cases if case not in completed_cases and case != current_case]
        
        # If not enough cases in same cluster, add from adjacent clusters
        if len(available_cases) < n_recommendations:
            all_available = [case for case in self.case_features.index 
                           if case not in completed_cases and case != current_case]
            # Sort by similarity (same cluster first)
            available_cases = available_cases + [c for c in all_available if c not in available_cases]
        
        return available_cases[:n_recommendations]
    
    def recommend_by_difficulty(self, current_difficulty: str = "medium",
                               completed_cases: list = None,
                               n_recommendations: int = 3) -> list:
        """
        Recommend cases based on difficulty level.
        
        Args:
            current_difficulty: "easy", "medium", or "hard"
            completed_cases: List of already completed cases
            n_recommendations: Number of recommendations
            
        Returns:
            List of recommended case names
        """
        if completed_cases is None:
            completed_cases = []
        
        # Calculate difficulty for each case (based on symptom complexity)
        case_difficulties = self.case_features['total_symptoms'].copy()
        
        # Define difficulty thresholds
        q33 = case_difficulties.quantile(0.33)
        q66 = case_difficulties.quantile(0.66)
        
        if current_difficulty == "easy":
            mask = case_difficulties <= q33
        elif current_difficulty == "hard":
            mask = case_difficulties >= q66
        else:  # medium
            mask = (case_difficulties > q33) & (case_difficulties < q66)
        
        available_cases = [case for case in self.case_features.index[mask].tolist()
                          if case not in completed_cases]
        
        return available_cases[:n_recommendations]


def train_recommender(data_path: str = "data/raw/symptoms_disease.csv",
                     n_clusters: int = 5,
                     use_pca: bool = False,
                     output_dir: str = "experiments/best_models") -> CaseRecommender:
    """
    Train the recommendation system.
    
    Args:
        data_path: Path to raw data
        n_clusters: Number of clusters
        use_pca: Whether to use PCA
        output_dir: Directory to save model
        
    Returns:
        Trained CaseRecommender
    """
    print("Loading data for recommendation system...")
    preparator = DataPreparator(data_path)
    df = preparator.load_data()
    df_clean = preparator.clean_data(df)
    
    # Initialize recommender
    recommender = CaseRecommender(n_clusters=n_clusters)
    
    # Prepare case features
    print("Preparing case features...")
    case_features = recommender.prepare_case_features(df_clean)
    
    # Fit recommender
    print("Training recommender...")
    silhouette = recommender.fit(case_features, use_pca=use_pca)
    
    # Save model
    os.makedirs(output_dir, exist_ok=True)
    model_path = os.path.join(output_dir, "recommender_model.pkl")
    
    metadata = {
        "n_clusters": n_clusters,
        "n_cases": len(case_features),
        "silhouette_score": float(silhouette),
        "use_pca": use_pca
    }
    
    save_model(recommender, model_path, metadata)
    
    # Save experiment results
    save_experiment_results({
        "recommender": {
            "n_clusters": n_clusters,
            "silhouette_score": float(silhouette),
            "cluster_distribution": pd.Series(recommender.case_clusters).value_counts().to_dict()
        }
    }, filepath=os.path.join(output_dir, "recommender_results.json"))
    
    print(f"\nRecommender training completed! Model saved to {model_path}")
    
    return recommender


def main():
    """Main training pipeline."""
    parser = argparse.ArgumentParser(description="Train recommendation system")
    parser.add_argument("--data_path", type=str, default="data/raw/symptoms_disease.csv",
                       help="Path to raw data CSV file")
    parser.add_argument("--output_dir", type=str, default="experiments/best_models",
                       help="Directory to save trained model")
    parser.add_argument("--n_clusters", type=int, default=5,
                       help="Number of clusters for case grouping")
    parser.add_argument("--use_pca", action="store_true",
                       help="Use PCA for dimensionality reduction")
    
    args = parser.parse_args()
    
    recommender = train_recommender(
        data_path=args.data_path,
        n_clusters=args.n_clusters,
        use_pca=args.use_pca,
        output_dir=args.output_dir
    )
    
    # Example usage
    print("\n" + "="*50)
    print("Example Recommendations")
    print("="*50)
    if len(recommender.case_features) > 0:
        sample_case = recommender.case_features.index[0]
        recommendations = recommender.recommend_next_cases(sample_case, n_recommendations=3)
        print(f"\nFor case '{sample_case}', recommended next cases:")
        for i, rec in enumerate(recommendations, 1):
            print(f"  {i}. {rec}")


if __name__ == "__main__":
    main()


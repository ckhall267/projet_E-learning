"""
Data preparation module for cleaning, feature engineering, and preprocessing.
"""
import argparse
import os
import pickle
from typing import Dict, Optional, Tuple

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler


class DataPreparator:
    """Handles data loading, cleaning, and preprocessing."""
    
    def __init__(self, data_path: str = "data/raw/symptoms_disease.csv"):
        """
        Initialize the data preparator.
        
        Args:
            data_path: Path to the raw data CSV file
        """
        self.data_path = data_path
        self.label_encoder = LabelEncoder()
        self.scaler = StandardScaler()
        self.feature_columns = None
        self.target_column = None
        
    def load_data(self) -> pd.DataFrame:
        """
        Load raw data from CSV file.
        
        Returns:
            DataFrame with raw data
        """
        if not os.path.exists(self.data_path):
            raise FileNotFoundError(f"Data file not found: {self.data_path}")
        
        df = pd.read_csv(self.data_path)
        print(f"Loaded {len(df)} rows from {self.data_path}")
        return df
    
    def clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Clean the dataset: handle missing values, duplicates, etc.
        
        Args:
            df: Raw dataframe
            
        Returns:
            Cleaned dataframe
        """
        df_clean = df.copy()
        
        # Remove duplicates
        initial_len = len(df_clean)
        df_clean = df_clean.drop_duplicates()
        print(f"Removed {initial_len - len(df_clean)} duplicate rows")
        
        # Handle missing values
        if df_clean.isnull().sum().sum() > 0:
            print("Handling missing values...")
            # For symptoms columns, fill with 0 (symptom not present)
            symptom_cols = [col for col in df_clean.columns if 'symptom' in col.lower() or col.isdigit()]
            for col in symptom_cols:
                df_clean[col] = df_clean[col].fillna(0)
            
            # For disease column, drop rows with missing values
            disease_col = [col for col in df_clean.columns if 'disease' in col.lower()][0] if any('disease' in col.lower() for col in df_clean.columns) else None
            if disease_col:
                df_clean = df_clean.dropna(subset=[disease_col])
        
        print(f"Cleaned dataset: {len(df_clean)} rows")
        return df_clean
    
    def prepare_features(self, df: pd.DataFrame, target_column: str = "disease") -> Tuple[pd.DataFrame, pd.Series]:
        """
        Prepare features and target for training.
        
        Args:
            df: Cleaned dataframe
            target_column: Name of the target column
            
        Returns:
            Tuple of (features DataFrame, target Series)
        """
        # Identify feature columns (all except target)
        feature_cols = [col for col in df.columns if col != target_column]
        self.feature_columns = feature_cols
        self.target_column = target_column
        
        X = df[feature_cols].copy()
        y = df[target_column].copy()
        
        # Encode target labels
        y_encoded = self.label_encoder.fit_transform(y)
        
        print(f"Features shape: {X.shape}")
        print(f"Target classes: {len(self.label_encoder.classes_)}")
        print(f"Target distribution:\n{pd.Series(y).value_counts()}")
        
        return X, pd.Series(y_encoded, name=target_column)
    
    def scale_features(self, X_train: pd.DataFrame, X_test: Optional[pd.DataFrame] = None) -> Tuple[pd.DataFrame, Optional[pd.DataFrame]]:
        """
        Scale features using StandardScaler.
        
        Args:
            X_train: Training features
            X_test: Optional test features
            
        Returns:
            Tuple of scaled (X_train, X_test)
        """
        X_train_scaled = pd.DataFrame(
            self.scaler.fit_transform(X_train),
            columns=X_train.columns,
            index=X_train.index
        )
        
        if X_test is not None:
            X_test_scaled = pd.DataFrame(
                self.scaler.transform(X_test),
                columns=X_test.columns,
                index=X_test.index
            )
            return X_train_scaled, X_test_scaled
        
        return X_train_scaled, None
    
    def split_data(self, X: pd.DataFrame, y: pd.Series, test_size: float = 0.2, random_state: int = 42) -> Tuple:
        """
        Split data into train and test sets.

        - If all classes have at least 2 samples, use stratified split.
        - Otherwise, fall back to non-stratified split to avoid sklearn errors.
        
        Args:
            X: Features
            y: Target (encoded labels)
            test_size: Proportion of test set
            random_state: Random seed
            
        Returns:
            Tuple of (X_train, X_test, y_train, y_test)
        """
        # Check class distribution
        value_counts = y.value_counts()
        min_count = value_counts.min()

        use_stratify = min_count >= 2
        if not use_stratify:
            print(
                f"[WARN] Some classes have only {min_count} sample(s). "
                "Falling back to non-stratified train/test split."
            )

        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=test_size,
            random_state=random_state,
            stratify=y if use_stratify else None,
        )
        
        print(f"Train set: {len(X_train)} samples")
        print(f"Test set: {len(X_test)} samples")
        
        return X_train, X_test, y_train, y_test
    
    def save_preprocessors(self, output_dir: str = "experiments/best_models"):
        """
        Save label encoder and scaler for inference.
        
        Args:
            output_dir: Directory to save preprocessors
        """
        os.makedirs(output_dir, exist_ok=True)
        
        with open(os.path.join(output_dir, "label_encoder.pkl"), "wb") as f:
            pickle.dump(self.label_encoder, f)
        
        with open(os.path.join(output_dir, "scaler.pkl"), "wb") as f:
            pickle.dump(self.scaler, f)
        
        # Save feature columns for API inference
        if self.feature_columns is not None:
            with open(os.path.join(output_dir, "feature_columns.pkl"), "wb") as f:
                pickle.dump(self.feature_columns, f)
        
        print(f"Preprocessors saved to {output_dir}")
    
    def load_preprocessors(self, input_dir: str = "experiments/best_models"):
        """
        Load saved label encoder and scaler.
        
        Args:
            input_dir: Directory containing saved preprocessors
        """
        with open(os.path.join(input_dir, "label_encoder.pkl"), "rb") as f:
            self.label_encoder = pickle.load(f)
        
        with open(os.path.join(input_dir, "scaler.pkl"), "rb") as f:
            self.scaler = pickle.load(f)
        
        # Load feature columns if available
        feature_cols_path = os.path.join(input_dir, "feature_columns.pkl")
        if os.path.exists(feature_cols_path):
            with open(feature_cols_path, "rb") as f:
                self.feature_columns = pickle.load(f)
        
        print(f"Preprocessors loaded from {input_dir}")


def prepare_diagnostic_data(data_path: str = "data/raw/symptoms_disease.csv", 
                           output_dir: str = "data/processed",
                           test_size: float = 0.2) -> Dict:
    """
    Complete pipeline for preparing diagnostic data.
    
    Args:
        data_path: Path to raw data
        output_dir: Directory to save processed data
        test_size: Proportion of test set
        
    Returns:
        Dictionary with train/test splits and metadata
    """
    preparator = DataPreparator(data_path)
    
    # Load and clean
    df = preparator.load_data()
    df_clean = preparator.clean_data(df)
    # --------------------------------------------------
    # Reduce dataset to 10% to avoid memory issues
    # --------------------------------------------------
    df_clean = df_clean.sample(frac=0.10, random_state=42).reset_index(drop=True)
    print(f"[INFO] Dataset reduced to 10%: {len(df_clean)} rows")


    # Detect target column (disease label)
    target_col = None
    # Prefer explicit disease / diseases column names
    if "disease" in df_clean.columns:
        target_col = "disease"
    elif "diseases" in df_clean.columns:
        target_col = "diseases"
    else:
        # Fallback: use first column as target
        target_col = df_clean.columns[0]
        print(f"[WARN] No 'disease' column found. Using '{target_col}' as target column.")

    # Prepare features
    X, y = preparator.prepare_features(df_clean, target_column=target_col)
    
    # Split data
    X_train, X_test, y_train, y_test = preparator.split_data(X, y, test_size=test_size)
    
    # Scale features
    X_train_scaled, X_test_scaled = preparator.scale_features(X_train, X_test)
    
    # Save processed data
    os.makedirs(output_dir, exist_ok=True)
    X_train_scaled.to_csv(os.path.join(output_dir, "X_train.csv"), index=False)
    X_test_scaled.to_csv(os.path.join(output_dir, "X_test.csv"), index=False)
    y_train.to_csv(os.path.join(output_dir, "y_train.csv"), index=False)
    y_test.to_csv(os.path.join(output_dir, "y_test.csv"), index=False)
    
    # Save preprocessors
    preparator.save_preprocessors()
    
    return {
        "X_train": X_train_scaled,
        "X_test": X_test_scaled,
        "y_train": y_train,
        "y_test": y_test,
        "preparator": preparator,
        "feature_columns": preparator.feature_columns
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Prepare diagnostic dataset")
    parser.add_argument(
        "--data_path",
        type=str,
        default="data/raw/symptoms_disease.csv",
        help="Path to raw CSV file (symptoms + disease column)",
    )
    parser.add_argument(
        "--output_dir",
        type=str,
        default="data/processed",
        help="Directory where processed CSV files will be saved",
    )
    parser.add_argument(
        "--test_size",
        type=float,
        default=0.2,
        help="Proportion of data used for test set (between 0 and 1)",
    )

    args = parser.parse_args()

    data = prepare_diagnostic_data(
        data_path=args.data_path,
        output_dir=args.output_dir,
        test_size=args.test_size,
    )
    print("Data preparation completed!")


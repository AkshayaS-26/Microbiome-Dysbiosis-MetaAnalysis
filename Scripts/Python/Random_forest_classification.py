"""
Random Forest classification of gut microbiome data to identify
disease-associated microbial signatures.

Input:
- Relative abundance table with SampleID and disease_status

Output:
- Model performance metrics (Accuracy, Sensitivity, Precision, F1-score, AUC)
- Confusion matrix
- Important microbial taxa with mean abundance comparison
"""

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score,
    recall_score,
    roc_auc_score,
    confusion_matrix,
    precision_score,
    f1_score
)

# Load microbiome abundance data
microbiome_df = pd.read_csv("Random_forest-input-new.csv")

# Set SampleID as index
microbiome_df = microbiome_df.set_index("SampleID")

# Split features and target labels
X = microbiome_df.drop("disease_status", axis=1)
y = microbiome_df["disease_status"]

# Stratified train-test split to maintain class balance
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    stratify=y,
    random_state=42
)

# Initialize and train Random Forest model
rf = RandomForestClassifier(
    n_estimators=1000,
    random_state=42
)

rf.fit(X_train, y_train)


# Function to calculate model evaluation metrics
def calculate_metrics(model, X, y_true):
    y_pred = model.predict(X)
    y_proba = model.predict_proba(X)[:, 1]

    return {
        "accuracy": accuracy_score(y_true, y_pred),
        "sensitivity": recall_score(y_true, y_pred),
        "AUC": roc_auc_score(y_true, y_proba),
        "confusion_matrix": confusion_matrix(y_true, y_pred).tolist(),
        "precision": precision_score(y_true, y_pred),
        "F1_score": f1_score(y_true, y_pred)
    }


# Evaluate training data
train_metrics = calculate_metrics(rf, X_train, y_train)

print("\n=== Training Set Metrics ===")
for metric, value in train_metrics.items():
    if metric == "confusion_matrix":
        print(f"Confusion Matrix:\n{value[0]}\n{value[1]}")
    else:
        print(f"{metric}: {value:.4f}")


# Evaluate testing data
test_metrics = calculate_metrics(rf, X_test, y_test)

print("\n=== Testing Set Metrics ===")
for metric, value in test_metrics.items():
    if metric == "confusion_matrix":
        print(f"Confusion Matrix:\n{value[0]}\n{value[1]}")
    else:
        print(f"{metric}: {value:.4f}")


# Calculate feature importance
feature_importances = pd.Series(
    rf.feature_importances_,
    index=X.columns
).sort_values(ascending=False)


# Calculate mean abundance in healthy and disease groups
X_with_labels = X.copy()
X_with_labels["disease_status"] = y

mean_abundance = X_with_labels.groupby("disease_status").mean()


# Create summary table of important taxa
summary_df = pd.DataFrame({
    "Feature_Importance": feature_importances,
    "Mean_Abundance_Healthy": mean_abundance.loc[0, feature_importances.index],
    "Mean_Abundance_Disease": mean_abundance.loc[1, feature_importances.index]
})


# Display top 20 important taxa
print("\n=== Top 20 Important Microbial Features ===")
print(summary_df.head(20))


# Save complete feature importance results
summary_df.to_csv(
    "feature_importance_summary.csv"
)

print("\nFeature importance summary saved successfully.")

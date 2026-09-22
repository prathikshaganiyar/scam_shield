from pathlib import Path

import joblib
import pandas as pd
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)


DATA_PATH = Path("data/test_messages.csv")
MODEL_PATH = Path("model/scam_classifier.joblib")


# Load unseen test data and trained model
df = pd.read_csv(DATA_PATH)
model = joblib.load(MODEL_PATH)

X_test = df["text"]
y_test = df["label"]

# Predict unseen messages
predictions = model.predict(X_test)

# Calculate metrics
accuracy = accuracy_score(y_test, predictions)

report = classification_report(
    y_test,
    predictions,
    target_names=["Legitimate", "Scam"],
    zero_division=0,
)

matrix = confusion_matrix(y_test, predictions)


print("\n=== ScamShield Unseen-Test Evaluation ===")
print(f"Test dataset size: {len(df)}")
print(f"Accuracy: {accuracy:.2%}")

print("\nClassification Report:")
print(report)

print("Confusion Matrix:")
print(matrix)

print("\nImportant:")
print("This test set was not used to train the current model.")
print("The dataset is synthetic and small, so these metrics are")
print("development measurements, not real-world performance claims.")
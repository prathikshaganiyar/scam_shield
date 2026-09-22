from pathlib import Path

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)


# -----------------------------
# 1. Load dataset
# -----------------------------

DATA_PATH = Path("data/scam_messages.csv")
MODEL_DIR = Path("model")
MODEL_DIR.mkdir(exist_ok=True)

df = pd.read_csv(DATA_PATH)

X = df["text"]
y = df["label"]


# -----------------------------
# 2. Split into train/test data
# -----------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.25,
    random_state=42,
    stratify=y,
)


# -----------------------------
# 3. Build ML pipeline
# -----------------------------

model = Pipeline(
    [
        (
            "tfidf",
            TfidfVectorizer(
                lowercase=True,
                ngram_range=(1, 2),
                max_features=5000,
            ),
        ),
        (
            "classifier",
            LogisticRegression(
                max_iter=1000,
                random_state=42,
            ),
        ),
    ]
)


# -----------------------------
# 4. Train
# -----------------------------

model.fit(X_train, y_train)


# -----------------------------
# 5. Evaluate
# -----------------------------

predictions = model.predict(X_test)

accuracy = accuracy_score(y_test, predictions)

print("\n=== ScamShield ML Evaluation ===")
print(f"Accuracy: {accuracy:.2%}")

print("\nClassification Report:")
print(
    classification_report(
        y_test,
        predictions,
        target_names=["Legitimate", "Scam"],
        zero_division=0,
    )
)

print("Confusion Matrix:")
print(confusion_matrix(y_test, predictions))


# -----------------------------
# 6. Save model
# -----------------------------

model_path = MODEL_DIR / "scam_classifier.joblib"

joblib.dump(model, model_path)

print(f"\nModel saved to: {model_path}")
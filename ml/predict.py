import joblib

MODEL_PATH = "model/scam_classifier.joblib"

model = joblib.load(MODEL_PATH)


def analyze_text(text: str) -> dict:
    probabilities = model.predict_proba([text])[0]

    legitimate_probability = float(probabilities[0])
    scam_probability = float(probabilities[1])

    prediction = 1 if scam_probability >= 0.5 else 0

    return {
        "prediction": prediction,
        "scam_probability": scam_probability,
        "legitimate_probability": legitimate_probability,
    }


if __name__ == "__main__":
    message = input("Paste a message to analyze:\n> ")

    result = analyze_text(message)

    print("\n=== ScamShield ML Result ===")
    print(f"Prediction: {'SCAM' if result['prediction'] == 1 else 'LEGITIMATE'}")
    print(f"Scam probability: {result['scam_probability']:.2%}")
    print(f"Legitimate probability: {result['legitimate_probability']:.2%}")
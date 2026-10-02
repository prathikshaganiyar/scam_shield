from pathlib import Path

import joblib
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from .explain import get_scam_reasons
from .url_analyzer import analyze_url
from .risk_engine import calculate_final_risk
from .url_extractor import extract_urls


app = FastAPI(
    title="ScamShield API",
    description="Backend API for ScamShield fraud detection",
    version="1.0.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:8081",
        "http://127.0.0.1:8081",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


MODEL_PATH = (
    Path(__file__).resolve().parent.parent
    / "ml"
    / "model"
    / "scam_classifier.joblib"
)


model = joblib.load(MODEL_PATH)


class ScanRequest(BaseModel):
    text: str = Field(
        min_length=1,
        max_length=10000,
        description="Job message or suspicious text to analyze",
    )


class URLRequest(BaseModel):
    url: str = Field(
        min_length=1,
        max_length=5000,
        description="URL to analyze for phishing indicators",
    )


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "ScamShield API",
    }


@app.post("/predict")
def predict(request: ScanRequest):
    probabilities = model.predict_proba([request.text])[0]

    legitimate_probability = float(probabilities[0])
    scam_probability = float(probabilities[1])

    prediction = (
        "scam"
        if scam_probability >= 0.5
        else "legitimate"
    )

    reasons = get_scam_reasons(request.text)

    urls = extract_urls(request.text)

    url_results = []

    for url in urls:
        try:
            result = analyze_url(url)
            url_results.append(result)
        except ValueError:
            continue

    highest_url_risk = max(
        (
            result["risk_score"]
            for result in url_results
        ),
        default=0,
    )

    risk_result = calculate_final_risk(
        scam_probability=scam_probability,
        rule_reason_count=len(reasons),
        url_risk_score=highest_url_risk,
    )

    return {
        "prediction": prediction,
        "scam_probability": scam_probability,
        "legitimate_probability": legitimate_probability,
        "risk_level": risk_result["risk_level"],
        "final_risk_score": risk_result["final_risk_score"],
        "signals": risk_result["signals"],
        "reasons": reasons,
        "urls": url_results,
    }


@app.post("/analyze-url")
def analyze_url_endpoint(request: URLRequest):
    try:
        return analyze_url(request.url)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )
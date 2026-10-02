from fastapi.testclient import TestClient

from backend.main import app


client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200

    data = response.json()

    assert data["status"] == "ok"
    assert data["service"] == "ScamShield API"


def test_predict_endpoint_with_scam_message():
    response = client.post(
        "/predict",
        json={
            "text": (
                "Congratulations! You have been selected for a job. "
                "Pay ₹500 registration fee immediately to confirm your offer."
            )
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert "prediction" in data
    assert "scam_probability" in data
    assert "legitimate_probability" in data
    assert "risk_level" in data
    assert "final_risk_score" in data
    assert "signals" in data
    assert "reasons" in data
    assert "urls" in data


def test_predict_endpoint_with_url():
    response = client.post(
        "/predict",
        json={
            "text": (
                "Please verify your account at "
                "http://192.168.1.10/login/verify"
            )
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert len(data["urls"]) >= 1
    assert data["urls"][0]["risk_score"] > 0


def test_predict_rejects_empty_text():
    response = client.post(
        "/predict",
        json={
            "text": ""
        },
    )

    assert response.status_code == 422


def test_analyze_url_endpoint():
    response = client.post(
        "/analyze-url",
        json={
            "url": "https://example.com"
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert data["domain"] == "example.com"
    assert data["risk_score"] == 0
    assert data["risk_level"] == "low"


def test_analyze_url_invalid_url():
    response = client.post(
        "/analyze-url",
        json={
            "url": "http://"
        },
    )

    assert response.status_code == 400

    data = response.json()

    assert data["detail"] == "Invalid URL"
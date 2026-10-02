from backend.risk_engine import calculate_final_risk


def test_low_risk_score():
    result = calculate_final_risk(
        scam_probability=0.10,
        rule_reason_count=0,
        url_risk_score=0,
    )

    assert result["final_risk_score"] == 6
    assert result["risk_level"] == "low"


def test_medium_risk_score():
    result = calculate_final_risk(
        scam_probability=0.63,
        rule_reason_count=3,
        url_risk_score=40,
    )

    assert result["final_risk_score"] == 61
    assert result["risk_level"] == "medium"


def test_high_risk_score():
    result = calculate_final_risk(
        scam_probability=0.95,
        rule_reason_count=4,
        url_risk_score=100,
    )

    assert result["final_risk_score"] == 97
    assert result["risk_level"] == "high"


def test_score_never_exceeds_100():
    result = calculate_final_risk(
        scam_probability=1.0,
        rule_reason_count=100,
        url_risk_score=100,
    )

    assert result["final_risk_score"] <= 100


def test_signal_breakdown_is_returned():
    result = calculate_final_risk(
        scam_probability=0.50,
        rule_reason_count=2,
        url_risk_score=50,
    )

    assert "signals" in result
    assert "ml_score" in result["signals"]
    assert "rule_score" in result["signals"]
    assert "url_score" in result["signals"]
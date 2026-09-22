def calculate_final_risk(
    scam_probability: float,
    rule_reason_count: int,
    url_risk_score: int = 0,
) -> dict:
    """
    Combines ScamShield's independent signals into one transparent
    risk score.

    This is a heuristic risk score, not a calibrated probability.
    """

    # ML contribution: up to 60 points
    ml_score = scam_probability * 60

    # Rule-based contribution: up to 20 points
    rule_score = min(rule_reason_count * 5, 20)

    # URL contribution: up to 20 points
    url_score = (url_risk_score / 100) * 20

    final_score = round(
        ml_score + rule_score + url_score
    )

    final_score = min(max(final_score, 0), 100)

    if final_score >= 70:
        risk_level = "high"
    elif final_score >= 40:
        risk_level = "medium"
    else:
        risk_level = "low"

    return {
        "final_risk_score": final_score,
        "risk_level": risk_level,
        "signals": {
            "ml_score": round(ml_score),
            "rule_score": round(rule_score),
            "url_score": round(url_score),
        },
    }
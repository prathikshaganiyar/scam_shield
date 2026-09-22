def get_scam_reasons(text: str) -> list[str]:
    text_lower = text.lower()

    reasons = []

    if any(word in text_lower for word in [
        "registration fee",
        "processing fee",
        "pay ₹",
        "pay rs",
        "payment",
        "deposit",
        "fee",
    ]):
        reasons.append("Requests an upfront payment or fee.")

    if any(word in text_lower for word in [
        "urgent",
        "immediately",
        "today",
        "act now",
        "limited time",
    ]):
        reasons.append("Uses urgent or pressure-based language.")

    if any(word in text_lower for word in [
        "no interview",
        "without interview",
        "selected directly",
        "no experience required",
    ]):
        reasons.append(
            "Suggests an unusually easy or non-standard hiring process."
        )

    if any(word in text_lower for word in [
        "work from home",
        "earn ₹",
        "earn rs",
        "salary",
        "per day",
        "per month",
    ]):
        reasons.append(
            "Contains employment or earning claims that require verification."
        )

    if any(word in text_lower for word in [
        "otp",
        "password",
        "bank details",
        "account number",
        "card number",
        "cvv",
        "aadhaar",
        "pan number",
    ]):
        reasons.append(
            "Requests sensitive personal or financial information."
        )

    if not reasons:
        reasons.append(
            "No specific scam indicators were detected by the explanation rules."
        )

    return reasons


def get_risk_level(scam_probability: float) -> str:
    if scam_probability >= 0.70:
        return "high"
    elif scam_probability >= 0.40:
        return "medium"
    else:
        return "low"
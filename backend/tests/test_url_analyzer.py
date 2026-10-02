from backend.url_analyzer import analyze_url


def test_safe_example_url():
    result = analyze_url(
        "https://example.com"
    )

    assert result["risk_score"] == 0
    assert result["risk_level"] == "low"
    assert result["reasons"] == []


def test_ip_address_url_is_flagged():
    result = analyze_url(
        "http://192.168.1.10/login/verify"
    )

    assert result["risk_score"] > 0
    assert result["risk_level"] == "medium"

    assert any(
        "IP address" in reason
        for reason in result["reasons"]
    )


def test_brand_impersonation_is_flagged():
    result = analyze_url(
        "https://paypal-secure-login.com/verify/account"
    )

    assert result["risk_score"] > 0

    assert any(
        "brand name" in reason.lower()
        for reason in result["reasons"]
    )


def test_http_url_gets_risk_points():
    result = analyze_url(
        "http://example.com"
    )

    assert result["risk_score"] == 15
    assert result["risk_level"] == "low"

    assert any(
        "HTTPS" in reason
        for reason in result["reasons"]
    )


def test_empty_url_raises_error():
    try:
        analyze_url("")
        assert False, "Expected ValueError"
    except ValueError as error:
        assert str(error) == "URL cannot be empty"
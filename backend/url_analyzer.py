from urllib.parse import urlparse
import ipaddress
import re


SUSPICIOUS_KEYWORDS = [
    "login",
    "verify",
    "verification",
    "secure",
    "account",
    "update",
    "confirm",
    "password",
    "signin",
    "wallet",
    "payment",
    "bank",
]


SHORTENING_DOMAINS = {
    "bit.ly",
    "tinyurl.com",
    "t.co",
    "goo.gl",
    "ow.ly",
    "is.gd",
    "cutt.ly",
}


# Common brand names that attackers may try to imitate.
# This is only a heuristic — it does NOT prove that a domain is fraudulent.
BRAND_KEYWORDS = {
    "paypal",
    "amazon",
    "google",
    "microsoft",
    "apple",
    "instagram",
    "facebook",
    "linkedin",
    "netflix",
}


SUSPICIOUS_TLDS = {
    ".zip",
    ".mov",
    ".click",
    ".top",
    ".work",
    ".country",
    ".gq",
    ".tk",
    ".ml",
    ".cf",
}


def analyze_url(url: str) -> dict:
    url = url.strip()

    if not url:
        raise ValueError("URL cannot be empty")

    if not re.match(r"^https?://", url, re.IGNORECASE):
        url = "https://" + url

    parsed = urlparse(url)
    hostname = parsed.hostname or ""
    hostname_lower = hostname.lower()

    if not hostname:
        raise ValueError("Invalid URL")

    reasons = []
    score = 0

    # ---------------------------------------------------------
    # 1. HTTPS check
    # ---------------------------------------------------------
    if parsed.scheme.lower() != "https":
        score += 15
        reasons.append("URL does not use HTTPS.")

    # ---------------------------------------------------------
    # 2. IP address check
    # ---------------------------------------------------------
    is_ip_address = False

    try:
        ipaddress.ip_address(hostname)
        is_ip_address = True
        score += 30
        reasons.append(
            "URL uses an IP address instead of a domain name."
        )
    except ValueError:
        pass

    # ---------------------------------------------------------
    # 3. URL length
    # ---------------------------------------------------------
    if len(url) > 100:
        score += 10
        reasons.append("URL is unusually long.")

    # ---------------------------------------------------------
    # 4. Suspicious keywords
    # ---------------------------------------------------------
    found_keywords = [
        keyword
        for keyword in SUSPICIOUS_KEYWORDS
        if keyword in url.lower()
    ]

    if found_keywords:
        score += min(25, len(found_keywords) * 5)
        reasons.append(
            "URL contains suspicious keywords: "
            + ", ".join(found_keywords)
            + "."
        )

    # ---------------------------------------------------------
    # 5. Excessive subdomains
    # ---------------------------------------------------------
    if not is_ip_address:
        subdomain_parts = hostname.split(".")

        if len(subdomain_parts) >= 4:
            score += 15
            reasons.append(
                "Domain contains an unusually high number of subdomains."
            )

    # ---------------------------------------------------------
    # 6. URL shortener
    # ---------------------------------------------------------
    if hostname_lower in SHORTENING_DOMAINS:
        score += 20
        reasons.append(
            "URL uses a known URL shortening service."
        )

    # ---------------------------------------------------------
    # 7. @ symbol
    # ---------------------------------------------------------
    if "@" in url:
        score += 20
        reasons.append(
            "URL contains '@', which can hide the actual destination."
        )

    # ---------------------------------------------------------
    # 8. Punycode
    # ---------------------------------------------------------
    if hostname_lower.startswith("xn--") or ".xn--" in hostname_lower:
        score += 20
        reasons.append(
            "Domain uses punycode, which can be used in lookalike domains."
        )

    # ---------------------------------------------------------
    # 9. Suspicious port
    # ---------------------------------------------------------
    if parsed.port is not None and parsed.port not in {80, 443}:
        score += 10
        reasons.append(
            "URL uses a non-standard web port."
        )

    # ---------------------------------------------------------
    # 10. Very deep URL path
    # ---------------------------------------------------------
    path_parts = [
        part for part in parsed.path.split("/")
        if part
    ]

    if len(path_parts) >= 5:
        score += 10
        reasons.append(
            "URL contains an unusually deep path structure."
        )

    # ---------------------------------------------------------
    # 11. Encoded URL characters
    # ---------------------------------------------------------
    if "%" in url:
        score += 10
        reasons.append(
            "URL contains encoded characters that may obscure its destination."
        )

    # ---------------------------------------------------------
    # 12. Excessive hyphens
    # ---------------------------------------------------------
    if not is_ip_address:
        hyphen_count = hostname.count("-")

        if hyphen_count >= 3:
            score += 10
            reasons.append(
                "Domain contains multiple hyphens, which can be seen in "
                "lookalike or deceptive domains."
            )

    # ---------------------------------------------------------
    # 13. Brand-name impersonation heuristic
    # ---------------------------------------------------------
    if not is_ip_address:
        matched_brands = [
            brand
            for brand in BRAND_KEYWORDS
            if brand in hostname_lower
        ]

        if matched_brands:
            # Only flag when the brand appears in a domain that does
            # not exactly match the normal brand domain.
            suspicious_brand_domains = []

            for brand in matched_brands:
                legitimate_domains = {
                    f"{brand}.com",
                    f"www.{brand}.com",
                }

                if hostname_lower not in legitimate_domains:
                    suspicious_brand_domains.append(brand)

            if suspicious_brand_domains:
                score += 20
                reasons.append(
                    "Domain contains a recognizable brand name but does not "
                    "exactly match the expected brand domain."
                )

    # ---------------------------------------------------------
    # 14. Suspicious TLD
    # ---------------------------------------------------------
    if not is_ip_address:
        if any(
            hostname_lower.endswith(tld)
            for tld in SUSPICIOUS_TLDS
        ):
            score += 10
            reasons.append(
                "Domain uses a TLD that can be associated with "
                "higher-risk or disposable domains."
            )

    # ---------------------------------------------------------
    # Final score
    # ---------------------------------------------------------
    score = min(score, 100)

    if score >= 70:
        risk_level = "high"
    elif score >= 40:
        risk_level = "medium"
    else:
        risk_level = "low"

    return {
        "url": url,
        "domain": hostname,
        "risk_score": score,
        "risk_level": risk_level,
        "reasons": reasons,
    }
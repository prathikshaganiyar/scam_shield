# 🛡️ ScamShield

### Explainable Scam & Phishing Detection

ScamShield is a cybersecurity application that analyzes suspicious messages and URLs using a combination of **machine learning, rule-based detection, and URL security analysis**.

Instead of giving the user only a "scam" or "safe" label, ScamShield provides an **explainable risk assessment** showing the signals and reasons behind the result.

---

## 🚨 The Problem

Online scams increasingly use:

- Fake job offers
- Upfront registration fees
- Urgent verification requests
- Fake account-security messages
- Suspicious links
- Brand impersonation
- Requests for sensitive information

ScamShield provides an additional layer of awareness by analyzing suspicious content before the user acts on it.

---

## ✨ Features

### 🔍 Message Analysis

Analyze suspicious messages using machine learning and security rules.

ScamShield detects indicators such as:

- Upfront payment requests
- Urgent or pressure-based language
- Suspicious employment claims
- Unrealistic earning claims
- Requests for sensitive information
- Unusually easy hiring processes

### 🤖 Machine Learning Detection

The text classifier uses:

- **TF-IDF vectorization**
- **Unigrams and bigrams**
- **Logistic Regression**
- **scikit-learn**
- **joblib**

The model produces probabilities for:

- Legitimate
- Scam

### 🔗 URL Security Analysis

URLs found inside messages are analyzed for security indicators including:

- Missing HTTPS
- IP-address-based URLs
- Suspicious keywords
- URL shorteners
- Very long URLs
- `@` characters
- Punycode
- Non-standard ports
- Deep URL paths
- Encoded characters
- Multiple domain hyphens
- Brand-lookalike domains
- Selected higher-risk TLD patterns

Each analyzed URL receives a risk score from **0–100** with explanations.

> URL checks are heuristic indicators and do not independently prove that a website is malicious.

### 📊 Explainable Risk Score

ScamShield combines three signals:

```text
Machine Learning
       +
Security Rules
       +
URL Analysis
       ↓
Final Risk Score
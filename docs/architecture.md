# ScamShield Architecture

ScamShield is a fraud-detection application that combines machine learning, rule-based security checks, and URL analysis to provide an explainable risk assessment.

## System Architecture

```text
                    ┌─────────────────────┐
                    │    Flutter Web UI   │
                    │                     │
                    │  Scan │ Dashboard   │
                    │  Result │ History   │
                    └──────────┬──────────┘
                               │
                         HTTP / REST
                               │
                    ┌──────────▼──────────┐
                    │      FastAPI        │
                    │                     │
                    │  /predict          │
                    │  /analyze-url      │
                    │  /health            │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
       ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
       │ ML Model    │ │ Rule Engine │ │ URL Analyzer│
       │             │ │             │ │             │
       │ TF-IDF +    │ │ Scam        │ │ Phishing    │
       │ Logistic    │ │ indicators  │ │ indicators  │
       │ Regression  │ │ & reasons   │ │             │
       └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
              │                │                │
              └────────────────┼────────────────┘
                               │
                       ┌───────▼────────┐
                       │  Risk Engine   │
                       │                │
                       │ ML + Rules +   │
                       │ URL signals    │
                       └───────┬────────┘
                               │
                       Explainable JSON
                               │
                    ┌──────────▼──────────┐
                    │   Flutter Result    │
                    │       Screen        │
                    └─────────────────────┘
# Credora Finance — Credit Risk & Loan Approval Analytics Platform

An end-to-end credit risk analytics platform combining **SQL, Machine Learning, Explainable AI, risk scoring, and interactive analytics** to support data-driven lending decisions.

The platform integrates customer, credit history, loan application, and transaction data to estimate **probability of default**, generate a **0–100 risk score**, classify applications into **Low / Medium / High risk**, and monitor the lending portfolio through an interactive Streamlit dashboard.

## 🌐 Live Dashboard

### [Launch Credora Finance Dashboard](https://credora-credit-risk.streamlit.app)

Explore loan approvals, historical defaults, credit-risk segments, geographic patterns, monthly trends, and high-risk applications using interactive filters.

---

## Project Highlights

- **7,500** loan applications analyzed
- **5,000** customers with credit-history data
- **40,079** transaction records
- MySQL database with **10 business-focused SQL analyses**
- End-to-end EDA and feature engineering
- Multiple classification models compared
- Probability-of-default prediction
- **0–100 credit risk scoring**
- Low / Medium / High risk segmentation
- SHAP-based model explainability
- Interactive Streamlit + Plotly dashboard
- Model Card and Data Dictionary documentation

---

## Tech Stack

**Python · SQL · MySQL · Pandas · NumPy · scikit-learn · XGBoost · SHAP · Plotly · Streamlit · Git · GitHub**

---

## Project Workflow

```text
Customers + Credit History + Loan Applications + Transactions
                         ↓
                    MySQL Database
                         ↓
                 Data Validation & EDA
                         ↓
                 Feature Engineering
                         ↓
                 Machine Learning
                         ↓
                Probability of Default
                         ↓
                  Risk Score (0–100)
                         ↓
               Low / Medium / High Risk
                         ↓
                 SHAP Explainability
                         ↓
                Streamlit Dashboard
```

---

## Machine Learning

The modeling dataset contains **3,403 applications with known historical outcomes**. Applications without known outcomes were excluded from training rather than being incorrectly treated as non-defaults.

Models evaluated:

- Logistic Regression
- Decision Tree
- Random Forest
- XGBoost

A tuned, class-balanced **Logistic Regression** model was selected. The decision threshold was chosen using out-of-fold training predictions.

### Held-Out Test Results

| Metric | Result |
|---|---:|
| ROC-AUC | **0.7119** |
| Recall | **0.6981** |
| Precision | **0.3535** |
| F1 Score | **0.4693** |
| Decision Threshold | **0.45** |

The model identified **111 of 159 actual defaults** in the held-out test set.

The original project targets of ROC-AUC ≥ 0.80 and recall ≥ 0.70 were not fully achieved. Results are reported without tuning against the held-out test set.

---

## Risk Scoring & Explainability

Predicted default probabilities are converted into a **0–100 risk score** and grouped into:

**Low Risk · Medium Risk · High Risk**

Observed default rates increased across these risk groups on applications with known outcomes.

SHAP analysis is used to explain the factors contributing to model predictions and provide global feature importance.

---

## SQL Analytics

The MySQL database supports **10 business-focused analyses**, including:

- Loan approval and default summaries
- Default risk by loan type
- Credit-score risk analysis
- Employment and debt-to-income analysis
- Transaction behaviour analysis
- Monthly application trends
- Loan amount analysis
- High-risk customer profiling

See [`Credora_Database.sql`](Credora_Database.sql) for the complete database schema and queries.

---

## Interactive Dashboard

The Streamlit dashboard includes:

- Executive portfolio KPIs
- Loan approval analysis
- Historical default analysis
- Risk-category distribution
- Credit-score and loan-type analysis
- Monthly application and approval trends
- Geographic loan distribution
- High-risk application watchlist
- Interactive portfolio filters

### [Open Live Dashboard →](https://credora-credit-risk.streamlit.app)

---

## Project Structure

```text
Credora-Finance-Credit-Risk-Analytics/
│
├── EDA.ipynb
├── Feature_Engineering.ipynb
├── Model_Building.ipynb
├── Dashboard_Data_Preparation.ipynb
├── Credora_Database.sql
│
├── credora_modeling_dataset.csv
├── credora_master_7500.csv
├── credora_risk_results.csv
├── credora_shap_importance.csv
├── credora_final_model.pkl
│
├── dashboard/
│   ├── app.py
│   └── credora_dashboard_dataset.csv
│
├── MODEL_CARD.md
├── DATA_DICTIONARY.md
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Run Locally

```bash
git clone https://github.com/Akanksha-Bhalerao/Credora-Finance-Credit-Risk-Analytics.git
cd Credora-Finance-Credit-Risk-Analytics
pip install -r requirements.txt
streamlit run dashboard/app.py
```

---

## Documentation

- [`MODEL_CARD.md`](MODEL_CARD.md) — model design, evaluation, limitations, and responsible-use notes
- [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md) — dataset and feature definitions
- [`Credora_Database.sql`](Credora_Database.sql) — database schema and SQL analytics

---

## Limitations

- Historical outcomes are available for **3,403 of 7,500 applications**.
- Held-out ROC-AUC and recall did not fully reach the original project targets.
- Predictions for applications without observed outcomes are model-generated estimates, not observed defaults.
- Credora is designed for **decision support**, not automated lending decisions.

Future improvements could include additional validated data, probability calibration, fairness monitoring, drift detection, and production API/MLOps integration.

---

## Author

**Akanksha Bhalerao**

Computer Science & Engineering Graduate  
**Data Science · Machine Learning · AI · Python · SQL**
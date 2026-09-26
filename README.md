# Credora Finance — Credit Risk & Loan Approval Analytics Platform

Credora Finance is an end-to-end Data Science and Machine Learning project designed to analyze loan applications, assess credit risk, predict probability of default, and support data-driven lending decisions.

The project combines **Python, SQL, Machine Learning, Explainable AI, risk scoring, and Streamlit** into a complete credit-risk analytics workflow.

---

## Project Overview

Financial institutions need to evaluate loan applicants while balancing business growth and credit risk.

This project builds a credit-risk analytics platform that:

- Integrates customer, credit history, loan application, and transaction data
- Performs exploratory data analysis and data quality checks
- Engineers credit-risk and transaction-based features
- Predicts probability of loan default
- Generates a 0–100 risk score
- Segments applications into Low, Medium, and High risk
- Uses SHAP for model explainability
- Performs SQL-based business analysis
- Provides an interactive Streamlit dashboard for portfolio monitoring

The platform is designed as a **decision-support system** and does not replace human underwriting decisions.

---

## Dataset

The project integrates four datasets:

| Dataset | Records |
|---|---:|
| Customers | 5,000 |
| Credit History | 5,000 |
| Loan Applications | 7,500 |
| Transactions | 40,079 |

The final modeling dataset contains:

- **3,403 labeled loan applications**
- **41 predictor features**
- **797 defaults**
- **2,606 non-defaults**

The remaining **4,097 loan applications** have unknown default outcomes and are not used as labeled observations during supervised model training.

Missing target values are retained as unknown rather than incorrectly being treated as non-default cases.

---

## Project Workflow

```text
Customer Data
      +
Credit History
      +
Loan Applications
      +
Transactions
      |
      v
Data Cleaning & EDA
      |
      v
Feature Engineering
      |
      v
SQL Database & Business Analysis
      |
      v
Machine Learning
      |
      v
Probability of Default
      |
      v
Risk Score (0–100)
      |
      v
Low / Medium / High Risk
      |
      v
SHAP Explainability
      |
      v
Streamlit Dashboard
```

---

## Exploratory Data Analysis

EDA was performed across customer, credit, loan, and transaction data.

The analysis included:

- Data quality and missing-value analysis
- Customer demographic analysis
- Credit score and utilization analysis
- Loan application and default analysis
- Transaction behavior analysis
- Target distribution analysis

Among applications with known outcomes, the historical default rate was approximately **23.42%**.

---

## Feature Engineering

Features were created from customer, credit, loan, and transaction information.

Examples include:

- Debt-to-limit ratio
- Loan-to-income ratio
- Total inflow over six months
- Total outflow over six months
- EMI outflow
- Average account balance
- Transaction count
- Net cash flow
- Inflow-to-outflow ratio

Transaction-level records were aggregated at customer level before being joined to loan applications to prevent duplicate application records.

Potential leakage variables such as approval status, approved amount, decision date, and disbursement status were excluded from model training.

Identifiers, PII, raw dates, and redundant variables were also excluded where appropriate.

---

## Machine Learning

Four baseline classification models were evaluated:

- Logistic Regression
- Decision Tree
- Random Forest
- XGBoost

The workflow used:

- Stratified 80/20 train-test split
- 5-fold stratified cross-validation
- Numerical and categorical preprocessing
- Median imputation
- One-hot encoding
- Feature scaling where required
- Class imbalance handling
- Hyperparameter tuning
- Threshold optimization using out-of-fold training predictions

### Final Model

The final model was a tuned **Logistic Regression** classifier with class balancing.

Selected hyperparameter:

```text
C = 0.01
```

The final probability threshold was selected using out-of-fold predictions on the training data:

```text
Threshold = 0.45
```

### Held-Out Test Performance

The final model was evaluated on a held-out test set of **681 applications**.

| Metric | Score |
|---|---:|
| Accuracy | 0.6314 |
| Precision | 0.3535 |
| Recall | 0.6981 |
| F1-score | 0.4693 |
| ROC-AUC | 0.7119 |

The model correctly identified **111 of 159 actual defaults** in the held-out test set.

The predefined project targets were:

- ROC-AUC ≥ 0.80
- Recall ≥ 0.70

These targets were **not fully achieved**. Recall was close to the target, while ROC-AUC remained below the desired level. The results are reported transparently rather than repeatedly tuning against the held-out test set.

---

## Risk Scoring

Predicted default probabilities are converted into a 0–100 risk score:

```text
Risk Score = Predicted Default Probability × 100
```

Applications are grouped into:

| Risk Score | Risk Category |
|---|---|
| 0–33 | Low |
| 34–66 | Medium |
| 67–100 | High |

On the held-out test set, observed default rates increased across the risk groups:

| Risk Category | Observed Default Rate |
|---|---:|
| Low | 10.55% |
| Medium | 24.59% |
| High | 48.39% |

This monotonic increase indicates that the scoring framework separates lower-risk and higher-risk applications in the held-out sample.

The model was also used to generate risk scores for the full **7,500-application portfolio** for dashboard analysis. Predictions for applications with unknown outcomes are model-generated risk estimates and must not be interpreted as observed defaults.

---

## Explainable AI — SHAP

SHAP was used to explain model predictions at both global and individual levels.

Important model drivers included:

- Debt-to-income ratio
- Credit score
- Late-payment history
- Recent credit inquiries
- Requested loan amount
- Applicant monthly income
- Annual income
- Interest rate
- Loan term
- Employment information

SHAP provides additional transparency into the factors contributing to model-generated risk predictions.

Global feature-importance results are stored in:

```text
credora_shap_importance.csv
```

---

## SQL Database & Business Analysis

A relational database was created using **MySQL** with four primary tables:

- `customers`
- `credit_history`
- `loan_applications`
- `transactions`

Customer IDs maintain relationships between the datasets.

The final SQL layer contains **10 analytical business queries**:

1. Loan Approval Summary
2. Loan Default Summary
3. Default Rate by Loan Type
4. Default Rate by Credit Score Band
5. Default Rate by Employment Type
6. Transaction Behavior — Default vs Non-Default
7. Default Rate by Debt-to-Income Ratio
8. Monthly Loan Application Trend
9. Loan Amount Analysis by Loan Type
10. High-Risk Customer Profile

### Selected SQL Insights

Overall approval rate across all applications:

**45.37%**

Historical default rate among applications with known outcomes:

**23.42%**

Historical default rate by credit-score band:

| Credit Score Band | Default Rate |
|---|---:|
| Poor (<580) | 39.91% |
| Fair (580–669) | 30.99% |
| Good (670–739) | 21.27% |
| Very Good (740+) | 10.92% |

Historical default rates decreased substantially as credit scores improved.

Debt-to-income analysis also showed higher historical default rates in the highest DTI group.

Loan amount analysis showed that different loan products have substantially different requested-amount profiles.

A rule-based high-risk customer query was also created using credit score, prior defaults, and serious late-payment history.

---

## Streamlit Dashboard

An interactive **Streamlit dashboard** was developed for portfolio monitoring and credit-risk analysis.

### Executive KPIs

- Total applications
- Approval rate
- Historical default rate
- Average predicted risk score
- High-risk application count

### Interactive Filters

- Loan type
- State
- Risk category
- Approval status
- Application month

### Dashboard Visualizations

The dashboard includes:

- Portfolio risk distribution
- Loan approval distribution
- Historical default rate by credit-score band
- Historical default rate by loan type
- Credit score distribution
- Monthly loan application volume
- Monthly approval-status trends
- Geographic loan distribution

### High-Risk Application Watchlist

The dashboard provides a filterable high-risk application table containing fields such as:

- Application ID
- Loan type
- State
- Credit score
- Requested amount
- Risk score
- Approval status
- Outcome status

Historical default metrics are calculated only from applications with known outcomes.

Risk predictions for applications without known historical outcomes are treated as model-generated estimates and not as observed defaults.

---

## Documentation

The project includes additional documentation:

### Model Card

`MODEL_CARD.md`

Documents:

- Model purpose
- Training data
- Feature engineering
- Model selection
- Threshold selection
- Held-out performance
- Risk scoring
- SHAP explainability
- Limitations
- Intended use
- Future improvements

### Data Dictionary

`DATA_DICTIONARY.md`

Documents:

- Source datasets
- Important source fields
- Dataset relationships
- Engineered features
- Target definition
- Model-output fields
- Dashboard fields
- Data-quality and interpretation rules

---

## Technologies Used

### Programming & Data Analysis

- Python
- Pandas
- NumPy

### Machine Learning

- Scikit-learn
- XGBoost

### Explainability

- SHAP

### Data Visualization

- Matplotlib
- Seaborn
- Plotly

### Database

- MySQL
- SQL
- MySQL Workbench

### Dashboard

- Streamlit

### Development Tools

- Google Colab
- Git
- GitHub

---

## Project Structure

```text
Credora-Finance-Credit-Risk-Analytics/
│
├── EDA.ipynb
├── Feature_Engineering.ipynb
├── Model_Building.ipynb
├── Dashboard_Data_Preparation.ipynb
│
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
└── README.md
```

---

## Running the Dashboard

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Open the dashboard directory

```bash
cd dashboard
```

### 3. Start Streamlit

```bash
streamlit run app.py
```

The application will open in the browser.

---

## Key Business Findings

- Historical default rate among applications with known outcomes was approximately **23.42%**.
- Historical default rates decreased substantially as applicant credit scores improved.
- Applicants in the highest debt-to-income group showed higher historical default rates.
- Defaulted borrowers showed lower average account balances and lower transaction amounts than non-defaulted borrowers in this dataset.
- Home loans had the highest average requested amount among the analyzed loan types, while Gold loans had the lowest.
- Held-out test results showed increasing observed default rates from Low to Medium to High risk categories.
- The dashboard enables portfolio-level monitoring while keeping observed historical outcomes separate from model-generated risk estimates.

---

## Limitations & Future Improvements

The final model did not fully achieve the predefined ROC-AUC and recall targets.

Important limitations include:

- Limited labeled default data
- Unknown outcomes for rejected and under-review applications
- Project data may not represent a real-world lending population
- No regulatory or fair-lending certification
- No temporal/out-of-time validation
- Full-portfolio risk scores should not be treated as independent model-performance results

Potential improvements include:

- Increasing the amount of labeled default data
- Adding richer repayment-history features
- Developing additional behavioral transaction features
- Testing broader hyperparameter spaces and additional model families
- Evaluating probability calibration
- Performing temporal/out-of-time validation
- Conducting fairness and bias analysis
- Monitoring model performance and drift after deployment

---

## Author

**Akanksha Bhalerao**

Computer Science & Engineering Graduate  
Data Science | Machine Learning | AI
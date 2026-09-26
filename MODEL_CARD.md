# Credora Finance — Credit Risk Model Card

## 1. Model Overview

**Project:** Credora Finance – Credit Risk & Loan Approval Analytics Platform  
**Model Type:** Logistic Regression  
**Primary Task:** Binary Classification  
**Target Variable:** `loan_default`  
**Model Artifact:** `credora_final_model.pkl`

The model estimates the probability that a loan application will result in default. The predicted probability is also converted into a 0–100 risk score and a Low, Medium, or High risk category.

The model is designed as a decision-support tool and should not be treated as a replacement for human underwriting decisions.

---

## 2. Dataset

The project integrates four datasets:

- Customer information
- Credit history
- Loan applications
- Transaction history

The original loan application dataset contains **7,500 applications**.

Target availability:

- Known outcomes: **3,403**
- Non-default (`0`): **2,606**
- Default (`1`): **797**
- Unknown outcomes: **4,097**

Applications with missing `loan_default` values were excluded from supervised model training and evaluation rather than being incorrectly treated as non-default cases.

The final modeling dataset contains:

- **3,403 labeled applications**
- **41 predictor features**
- **1 target variable**

---

## 3. Modeling Grain

Each modeling record represents a **loan application**.

Customer and credit-history information were joined to the loan application data. Transaction-level data were first aggregated at customer level before being joined to applications to avoid duplicating application records.

---

## 4. Feature Engineering

Important engineered features include:

- `loan_to_income`
- `debt_to_limit`
- `total_inflow_6m`
- `total_outflow_6m`
- `emi_outflow_6m`
- `avg_balance`
- `transaction_count`
- `net_cash_flow_6m`
- `inflow_outflow_ratio`

Personally identifying fields, IDs, raw dates, leakage variables, and redundant variables were excluded from model training.

`credit_utilization` was excluded because it was almost perfectly correlated with the engineered `debt_to_limit` feature.

Customer tenure was evaluated but excluded because of temporal inconsistencies in the source data.

---

## 5. Models Evaluated

The following classification models were evaluated:

- Logistic Regression
- Decision Tree
- Random Forest
- XGBoost

Model selection considered:

- ROC-AUC
- Recall
- Precision
- F1-score
- Cross-validation performance
- Interpretability

Class imbalance was also considered during model development.

---

## 6. Final Model

The selected model is a **tuned Logistic Regression classifier with class balancing**.

Hyperparameter tuning selected:

**C = 0.01**

The final classification threshold was selected using **out-of-fold predictions on the training data** rather than tuning against the held-out test set.

**Selected probability threshold: 0.45**

This threshold was chosen to improve default detection while maintaining a practical balance between recall and precision.

---

## 7. Held-Out Test Performance

Final evaluation was performed on a stratified held-out test set of **681 applications**.

| Metric | Result |
|---|---:|
| Accuracy | 0.6314 |
| Precision | 0.3535 |
| Recall | 0.6981 |
| F1-score | 0.4693 |
| ROC-AUC | 0.7119 |

Confusion matrix:

| | Predicted Non-Default | Predicted Default |
|---|---:|---:|
| Actual Non-Default | 319 | 203 |
| Actual Default | 48 | 111 |

The model identified **111 of 159 actual defaults** in the held-out test set.

---

## 8. Performance Against Project Targets

The project PRD defined target performance of:

- ROC-AUC ≥ 0.80
- Recall ≥ 0.70

Final performance:

- ROC-AUC: **0.7119**
- Recall: **0.6981**

Therefore, the final model **did not fully achieve the predefined performance targets**.

Recall was close to the target, while ROC-AUC remained below the desired threshold. These results are reported without repeatedly tuning against the held-out test set.

---

## 9. Risk Scoring

Predicted default probability is converted into a **0–100 risk score**:

`Risk Score = Predicted Default Probability × 100`

Risk categories used in the dashboard are:

- **Low Risk:** 0–33
- **Medium Risk:** 34–66
- **High Risk:** 67–100

The full portfolio of 7,500 applications was scored for dashboard analysis.

Portfolio risk distribution:

| Risk Category | Applications | Percentage |
|---|---:|---:|
| Low | 1,236 | 16.48% |
| Medium | 2,843 | 37.91% |
| High | 3,421 | 45.61% |

---

## 10. Risk-Band Validation

Among the 3,403 applications with known historical outcomes:

| Risk Category | Applications | Actual Default Rate |
|---|---:|---:|
| Low | 1,060 | 6.79% |
| Medium | 1,799 | 24.62% |
| High | 544 | 51.84% |

Observed default rates increase monotonically from Low to Medium to High risk.

This analysis uses all labeled applications and is therefore a risk-band sanity check rather than an independent held-out performance estimate.

---

## 11. Explainability

SHAP was used to analyze model behavior and provide global and local explanations.

Important features included:

- Debt-to-income ratio
- Credit score
- 30-day late payments
- Recent credit inquiries
- Requested loan amount
- Applicant monthly income
- Annual income
- Interest rate
- Loan term
- Employment-related features

SHAP explanations help identify which variables contribute to higher or lower predicted risk.

Feature importance results are stored in:

`credora_shap_importance.csv`

---

## 12. Intended Use

The model is intended for:

- Credit-risk analytics
- Loan portfolio monitoring
- Identifying potentially high-risk applications
- Supporting underwriting analysis
- Demonstrating an end-to-end credit-risk machine learning workflow

The model should be used as **decision support**, not as an automatic loan approval or rejection system.

---

## 13. Limitations

Important limitations include:

1. The model did not achieve the project's target ROC-AUC of 0.80.
2. Recall of 0.6981 was slightly below the target of 0.70.
3. The dataset is project data and may not represent real-world lending populations.
4. Historical relationships may not remain stable over time.
5. The model has not undergone regulatory validation or fairness certification.
6. Risk scores for applications with unknown outcomes cannot be validated against observed defaults.
7. Rejected and under-review applications have unknown outcomes, so their predicted risk must not be interpreted as evidence that they would actually have defaulted.
8. Full-portfolio risk scoring includes records used during model development and must not be presented as independent model-performance evaluation.

---

## 14. Future Improvements

Possible future improvements include:

- Additional high-quality behavioral and repayment features
- More extensive hyperparameter optimization
- Alternative boosting and ensemble approaches
- Probability calibration
- Temporal/out-of-time validation
- Fairness and bias analysis
- Model drift monitoring
- Validation using larger real-world lending datasets

---

## 15. Reproducibility

Main modeling artifacts:

- `credora_modeling_dataset.csv`
- `Model_Building.ipynb`
- `credora_final_model.pkl`
- `credora_risk_results.csv`
- `credora_shap_importance.csv`

The final model artifact can be reused for prediction without retraining.

---

## 16. Author

**Akanksha Bhalerao**  
Computer Science & Engineering Graduate  
Data Science | Machine Learning | AI
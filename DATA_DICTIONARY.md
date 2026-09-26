# Credora Finance — Data Dictionary

## 1. Overview

This data dictionary documents the main datasets and important variables used in the Credora Finance Credit Risk & Loan Approval Analytics Platform.

The project integrates four primary data sources:

1. Customer data
2. Credit history data
3. Loan application data
4. Transaction data

The final machine-learning dataset is built at the **loan-application level**.

---

# 2. Customer Data

Source: `customers.csv`

Contains demographic, employment, residence, and KYC information for customers.

| Column | Description |
|---|---|
| `customer_id` | Unique identifier for each customer |
| `gender` | Customer gender |
| `age` | Customer age |
| `marital_status` | Marital status |
| `dependents` | Number of dependents |
| `education` | Education level |
| `employment_type` | Employment category |
| `occupation` | Customer occupation |
| `annual_income` | Customer annual income |
| `city` | Customer city |
| `state` | Customer state |
| `residence_type` | Type of residence |
| `years_at_residence` | Number of years at current residence |
| `kyc_status` | Know Your Customer verification status |
| `customer_since` | Date from which the customer relationship began |

Customer identifiers and other personally identifying information are not used as predictive model features.

---

# 3. Credit History Data

Source: `credit_history.csv`

Contains credit-bureau and previous repayment behavior.

| Column | Description |
|---|---|
| `credit_id` | Unique credit-history record identifier |
| `customer_id` | Customer identifier used to join with customer data |
| `credit_score` | Customer credit score |
| `num_open_accounts` | Number of currently open credit accounts |
| `num_credit_inquiries_6m` | Number of credit inquiries during the previous six months |
| `num_late_payments_30d` | Number of 30-day late payments |
| `num_late_payments_90d` | Number of 90-day late payments |
| `num_defaults_prior` | Number of previous defaults |
| `bankruptcies` | Number of recorded bankruptcies |
| `total_credit_limit` | Total available credit limit |
| `total_outstanding_debt` | Total outstanding credit debt |
| `credit_utilization` | Proportion of available credit currently utilized |
| `oldest_account_age_months` | Age of the oldest credit account in months |

`credit_utilization` was excluded from the final model because it was almost perfectly correlated with the engineered `debt_to_limit` feature.

---

# 4. Loan Application Data

Source: `loan_applications.csv`

Contains individual loan applications and their historical outcomes.

| Column | Description |
|---|---|
| `application_id` | Unique identifier for each loan application |
| `customer_id` | Customer submitting the application |
| `application_date` | Date the application was submitted |
| `loan_type` | Type of loan requested |
| `loan_purpose` | Purpose of the requested loan |
| `requested_amount` | Amount requested by the applicant |
| `loan_term_months` | Requested loan duration in months |
| `interest_rate` | Interest rate associated with the loan |
| `applicant_monthly_income` | Monthly income reported in the application |
| `existing_emi` | Existing monthly EMI obligations |
| `debt_to_income_ratio` | Existing debt obligation relative to income |
| `collateral_flag` | Indicates whether collateral is associated with the application |
| `approval_status` | Application status such as Approved, Rejected, or Under Review |
| `loan_default` | Historical default target: 1 = Default, 0 = Non-Default, NULL = outcome unavailable |

## Target Variable

`loan_default` is the supervised machine-learning target.

The source contains:

- 7,500 total applications
- 3,403 applications with known outcomes
- 2,606 non-default cases
- 797 default cases
- 4,097 applications with unknown outcomes

Unknown target values are retained as missing/NULL and are **not converted to non-default cases**.

Only applications with known outcomes are used for supervised model training and evaluation.

---

# 5. Transaction Data

Source: `transactions.csv`

Contains customer transaction activity.

Transaction-level records are not joined directly to loan applications because a customer can have multiple transactions and multiple applications.

Transactions are first aggregated at the customer level.

Important transaction concepts include:

| Field / Concept | Description |
|---|---|
| `transaction_id` | Unique transaction identifier |
| `customer_id` | Customer associated with the transaction |
| `transaction_date` | Date of transaction |
| `transaction_type` | Type/category of transaction |
| `amount` | Transaction amount |
| `balance_after_transaction` | Account balance following the transaction |

---

# 6. Engineered Transaction Features

The following customer-level transaction features were generated before joining with loan applications.

| Feature | Description |
|---|---|
| `total_inflow_6m` | Total incoming transaction amount over the available six-month period |
| `total_outflow_6m` | Total outgoing transaction amount over the available six-month period |
| `emi_outflow_6m` | Total EMI-related outgoing amount |
| `avg_balance` | Average observed account balance |
| `transaction_count` | Number of transactions |
| `net_cash_flow_6m` | Total inflow minus total outflow |
| `inflow_outflow_ratio` | Ratio of total inflow to total outflow |

For customers with zero outflow, non-finite inflow/outflow ratios were handled during feature engineering before model training.

---

# 7. Additional Engineered Features

## `loan_to_income`

Measures requested loan amount relative to annual income.

Conceptually:

`loan_to_income = requested_amount / annual_income`

Higher values indicate that the requested loan is larger relative to the applicant's income.

## `debt_to_limit`

Measures outstanding debt relative to the total available credit limit.

Conceptually:

`debt_to_limit = total_outstanding_debt / total_credit_limit`

This feature was retained instead of the highly redundant `credit_utilization` variable.

---

# 8. Final Modeling Dataset

File:

`credora_modeling_dataset.csv`

The final modeling dataset contains:

- 3,403 labeled loan applications
- 41 predictor features
- 1 target variable (`loan_default`)
- 42 columns in total

The modeling dataset contains only records where the historical target is known.

The following types of variables were excluded from predictive modeling where appropriate:

- Unique identifiers
- Personally identifying information
- Raw date fields
- Leakage variables
- Redundant variables
- Variables with identified temporal inconsistencies

---

# 9. Model Output Fields

The final model produces a probability of default for each scored application.

## `default_probability`

Estimated probability that an application belongs to the default class.

Range:

`0.0 – 1.0`

## `risk_score`

A 0–100 representation of the predicted default probability.

Conceptually:

`risk_score = default_probability × 100`

## `risk_category`

Applications are grouped into three risk categories:

| Risk Score | Risk Category |
|---:|---|
| 0–33 | Low |
| 34–66 | Medium |
| 67–100 | High |

These categories are used for portfolio monitoring and dashboard analysis.

## `outcome_status`

Indicates whether an application has an observed historical default outcome.

| Value | Meaning |
|---|---|
| Known | Historical `loan_default` is available |
| Unknown | Historical `loan_default` is unavailable |

This distinction prevents predicted risk from being confused with observed historical defaults.

---

# 10. Dashboard Dataset

File:

`dashboard/credora_dashboard_dataset.csv`

The dashboard dataset contains:

- 7,500 loan applications
- Historical application information
- Customer and credit information
- Engineered features
- Model-generated default probability
- Risk score
- Risk category
- Outcome-status indicator

The model scores all 7,500 applications for portfolio analysis.

However, historical default-rate calculations use only applications with **known outcomes**.

Predictions for rejected and under-review applications should be interpreted as model-generated risk estimates, not evidence that those applicants would actually have defaulted.

---

# 11. Dataset Relationships

The primary relational structure is:

`customers.customer_id`
→ `credit_history.customer_id`

`customers.customer_id`
→ `loan_applications.customer_id`

`customers.customer_id`
→ `transactions.customer_id`

Relationship types:

- Customer → Credit History: One-to-One
- Customer → Loan Applications: One-to-Many
- Customer → Transactions: One-to-Many

Transaction data is aggregated before being joined to application-level modeling data to prevent duplicate loan-application records.

---

# 12. Data Quality Rules

Important rules followed during data preparation:

1. Missing `loan_default` values are not replaced with zero.
2. Only known outcomes are used for supervised model training.
3. Transaction records are aggregated before joining with applications.
4. IDs and personally identifying fields are excluded from model features.
5. Non-finite engineered ratios are handled before modeling.
6. Duplicate application records are checked before final modeling.
7. Leakage-related fields are excluded from the predictor set.
8. Historical default metrics are calculated only from known outcomes.

---

# 13. Important Interpretation Note

Three concepts must remain separate:

**Historical Default**

An observed `loan_default` value from a known loan outcome.

**Predicted Default Probability**

The machine-learning model's estimated probability of default.

**Risk Score**

A 0–100 transformation of predicted default probability used for easier portfolio interpretation.

A predicted High Risk application should not automatically be described as an actual default.
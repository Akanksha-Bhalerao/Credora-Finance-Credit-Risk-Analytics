CREATE DATABASE credora_finance;

USE credora_finance;

SELECT DATABASE();

-- ==========================================
-- TABLE 1: CUSTOMERS
-- ==========================================

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(20),
    date_of_birth DATE,
    age INT,
    marital_status VARCHAR(30),
    dependents INT,
    education VARCHAR(50),
    employment_type VARCHAR(50),
    occupation VARCHAR(100),
    annual_income DECIMAL(15,2),
    city VARCHAR(100),
    state VARCHAR(100),
    residence_type VARCHAR(50),
    years_at_residence INT,
    email VARCHAR(150),
    phone VARCHAR(30),
    kyc_status VARCHAR(30),
    customer_since DATE
);

DESCRIBE customers;

-- ==========================================
-- TABLE 2: CREDIT HISTORY
-- ==========================================

CREATE TABLE credit_history (
    credit_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    as_of_date DATE,
    credit_score INT,
    num_open_accounts INT,
    num_credit_inquiries_6m INT,
    credit_utilization_ratio DECIMAL(6,4),
    num_late_payments_30d INT,
    num_late_payments_90d INT,
    num_defaults_prior INT,
    bankruptcies INT,
    total_credit_limit DECIMAL(15,2),
    total_outstanding_debt DECIMAL(15,2),
    oldest_account_age_months INT,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

DESCRIBE credit_history;

-- ==========================================
-- TABLE 3: LOAN APPLICATIONS
-- ==========================================

CREATE TABLE loan_applications (
    application_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    application_date DATE,
    loan_type VARCHAR(50),
    loan_purpose VARCHAR(100),
    requested_amount DECIMAL(15,2),
    loan_term_months INT,
    interest_rate DECIMAL(6,3),
    applicant_monthly_income DECIMAL(15,2),
    existing_emi DECIMAL(15,2),
    debt_to_income_ratio DECIMAL(8,4),
    collateral_flag INT,
    approval_status VARCHAR(30),
    approved_amount DECIMAL(15,2),
    decision_date DATE,
    disbursed_flag INT,
    loan_default INT,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

DESCRIBE loan_applications;

-- ==========================================
-- TABLE 4: TRANSACTIONS
-- ==========================================

CREATE TABLE transactions (
    transaction_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    transaction_date DATE,
    transaction_type VARCHAR(20),
    category VARCHAR(50),
    amount DECIMAL(15,2),
    balance_after_transaction DECIMAL(15,2),
    channel VARCHAR(50),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

DESCRIBE transactions;

SELECT COUNT(*) AS total_loan_rows
FROM loan_applications;

TRUNCATE TABLE loan_applications;

SELECT COUNT(*) AS total_loan_rows
FROM loan_applications;

SELECT 
    COUNT(*) AS total_rows,
    SUM(loan_default = 0) AS non_defaults,
    SUM(loan_default = 1) AS defaults,
    SUM(loan_default IS NULL) AS missing_defaults
FROM loan_applications;

DROP TABLE IF EXISTS loan_applications_staging;

CREATE TABLE loan_applications_staging (
    application_id VARCHAR(20),
    customer_id VARCHAR(20),
    application_date VARCHAR(30),
    loan_type VARCHAR(50),
    loan_purpose VARCHAR(100),
    requested_amount VARCHAR(50),
    loan_term_months VARCHAR(50),
    interest_rate VARCHAR(50),
    applicant_monthly_income VARCHAR(50),
    existing_emi VARCHAR(50),
    debt_to_income_ratio VARCHAR(50),
    collateral_flag VARCHAR(20),
    approval_status VARCHAR(30),
    approved_amount VARCHAR(50),
    decision_date VARCHAR(30),
    disbursed_flag VARCHAR(20),
    loan_default VARCHAR(20)
);

DESCRIBE loan_applications_staging;

SELECT 
    COUNT(*) AS total_rows,
    SUM(loan_default = '0.0') AS non_defaults,
    SUM(loan_default = '1.0') AS defaults,
    SUM(loan_default = '\\N') AS missing_defaults
FROM loan_applications_staging;


TRUNCATE TABLE loan_applications;

SELECT COUNT(*) AS real_table_rows
FROM loan_applications;

INSERT INTO loan_applications (
    application_id,
    customer_id,
    application_date,
    loan_type,
    loan_purpose,
    requested_amount,
    loan_term_months,
    interest_rate,
    applicant_monthly_income,
    existing_emi,
    debt_to_income_ratio,
    collateral_flag,
    approval_status,
    approved_amount,
    decision_date,
    disbursed_flag,
    loan_default
)
SELECT
    application_id,
    customer_id,
    STR_TO_DATE(application_date, '%Y-%m-%d'),
    loan_type,
    loan_purpose,
    CAST(requested_amount AS DECIMAL(15,2)),
    CAST(loan_term_months AS DECIMAL(10,0)),
    CAST(interest_rate AS DECIMAL(6,3)),
    CAST(applicant_monthly_income AS DECIMAL(15,2)),
    CAST(existing_emi AS DECIMAL(15,2)),
    CAST(debt_to_income_ratio AS DECIMAL(8,4)),

    CASE
        WHEN TRIM(collateral_flag) IN ('1', '1.0') THEN 1
        WHEN TRIM(collateral_flag) IN ('0', '0.0') THEN 0
        ELSE NULL
    END,

    approval_status,

    CAST(approved_amount AS DECIMAL(15,2)),

    CASE
        WHEN decision_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN STR_TO_DATE(decision_date, '%Y-%m-%d')
        ELSE NULL
    END,

    CASE
        WHEN TRIM(disbursed_flag) IN ('1', '1.0') THEN 1
        WHEN TRIM(disbursed_flag) IN ('0', '0.0') THEN 0
        ELSE NULL
    END,

    CASE
        WHEN TRIM(loan_default) IN ('0', '0.0') THEN 0
        WHEN TRIM(loan_default) IN ('1', '1.0') THEN 1
        ELSE NULL
    END

FROM loan_applications_staging;

SELECT 
    COUNT(*) AS total_rows,
    SUM(loan_default = 0) AS non_defaults,
    SUM(loan_default = 1) AS defaults,
    SUM(loan_default IS NULL) AS missing_defaults
FROM loan_applications;

SELECT 
    approval_status,
    COUNT(*) AS applications
FROM loan_applications
GROUP BY approval_status
ORDER BY applications DESC;

SELECT 
    COUNT(*) AS total_rows,
    SUM(loan_default = 0) AS non_defaults,
    SUM(loan_default = 1) AS defaults,
    SUM(loan_default IS NULL) AS missing_defaults
FROM loan_applications;


SELECT COUNT(*) AS customers_rows
FROM customers;

SELECT COUNT(*) AS credit_history_rows
FROM credit_history;

SELECT COUNT(*) AS loan_applications_rows
FROM loan_applications;

SELECT COUNT(*) AS transactions_rows
FROM transactions;


SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'credit_history', COUNT(*)
FROM credit_history

UNION ALL

SELECT 'loan_applications', COUNT(*)
FROM loan_applications

UNION ALL

SELECT 'transactions', COUNT(*)
FROM transactions;


-- Check customers ↔ credit history
SELECT COUNT(*) AS matched_credit_records
FROM customers c
INNER JOIN credit_history ch
    ON c.customer_id = ch.customer_id;

-- Check customers ↔ loan applications
SELECT COUNT(*) AS matched_loan_records
FROM customers c
INNER JOIN loan_applications l
    ON c.customer_id = l.customer_id;
    
    
    -- Check customers ↔ credit history
SELECT COUNT(*) AS matched_credit_records
FROM customers c
INNER JOIN credit_history ch
    ON c.customer_id = ch.customer_id;

-- Check customers ↔ transactions
SELECT COUNT(*) AS matched_transaction_records
FROM customers c
INNER JOIN transactions t
    ON c.customer_id = t.customer_id;
    
-- =====================================================
-- BUSINESS ANALYSIS
-- 1. Loan Approval Summary
-- =====================================================

SELECT
    approval_status,
    COUNT(*) AS total_applications,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_applications),
        2
    ) AS percentage
FROM loan_applications
GROUP BY approval_status
ORDER BY total_applications DESC;

-- =====================================================
-- 2. Loan Default Summary
-- =====================================================

SELECT
    COUNT(*) AS loans_with_known_outcome,
    SUM(loan_default = 0) AS non_defaults,
    SUM(loan_default = 1) AS defaults,
    ROUND(
        SUM(loan_default = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
FROM loan_applications
WHERE loan_default IS NOT NULL;

-- =====================================================
-- 3. Default Rate by Loan Type
-- =====================================================

SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(loan_default = 1) AS defaults,
    ROUND(
        SUM(loan_default = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
FROM loan_applications
WHERE loan_default IS NOT NULL
GROUP BY loan_type
ORDER BY default_rate_percentage DESC;

-- =====================================================
-- 4. Default Rate by Credit Score Band
-- =====================================================

SELECT
    CASE
        WHEN ch.credit_score < 580 THEN 'Poor (<580)'
        WHEN ch.credit_score < 670 THEN 'Fair (580-669)'
        WHEN ch.credit_score < 740 THEN 'Good (670-739)'
        ELSE 'Very Good (740+)'
    END AS credit_score_band,

    COUNT(*) AS total_loans,
    SUM(l.loan_default = 1) AS defaults,

    ROUND(
        SUM(l.loan_default = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage

FROM loan_applications l
INNER JOIN credit_history ch
    ON l.customer_id = ch.customer_id

WHERE l.loan_default IS NOT NULL

GROUP BY credit_score_band
ORDER BY default_rate_percentage DESC;

-- =====================================================
-- 5. Default Rate by Employment Type
-- =====================================================

SELECT
    c.employment_type,
    COUNT(*) AS total_loans,
    SUM(l.loan_default = 1) AS defaults,
    ROUND(
        SUM(l.loan_default = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
FROM loan_applications l
INNER JOIN customers c
    ON l.customer_id = c.customer_id
WHERE l.loan_default IS NOT NULL
GROUP BY c.employment_type
ORDER BY default_rate_percentage DESC;

-- =====================================================
-- 6. Transaction Behavior: Default vs Non-Default
-- =====================================================

WITH transaction_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS transaction_count,
        AVG(balance_after_transaction) AS avg_balance,
        SUM(amount) AS total_transaction_amount
    FROM transactions
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN l.loan_default = 1 THEN 'Default'
        WHEN l.loan_default = 0 THEN 'Non-Default'
    END AS loan_outcome,

    COUNT(*) AS total_loans,

    ROUND(AVG(ts.transaction_count), 2) AS avg_transaction_count,
    ROUND(AVG(ts.avg_balance), 2) AS avg_account_balance,
    ROUND(AVG(ts.total_transaction_amount), 2) AS avg_total_transaction_amount

FROM loan_applications l
INNER JOIN transaction_summary ts
    ON l.customer_id = ts.customer_id

WHERE l.loan_default IS NOT NULL

GROUP BY l.loan_default
ORDER BY l.loan_default;

-- =====================================================
-- 7. Default Rate by Debt-to-Income Ratio
-- =====================================================

SELECT
    CASE
        WHEN debt_to_income_ratio < 0.20 THEN 'Low (<20%)'
        WHEN debt_to_income_ratio < 0.40 THEN 'Moderate (20-40%)'
        WHEN debt_to_income_ratio < 0.60 THEN 'High (40-60%)'
        ELSE 'Very High (60%+)'
    END AS dti_band,

    COUNT(*) AS total_loans,
    SUM(loan_default = 1) AS defaults,

    ROUND(
        SUM(loan_default = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage

FROM loan_applications

WHERE loan_default IS NOT NULL

GROUP BY dti_band
ORDER BY default_rate_percentage DESC;

-- =====================================================
-- 8. Monthly Loan Application Trend
-- =====================================================

SELECT
    DATE_FORMAT(application_date, '%Y-%m') AS application_month,
    COUNT(*) AS total_applications,
    SUM(approval_status = 'Approved') AS approved,
    SUM(approval_status = 'Rejected') AS rejected,
    SUM(approval_status = 'Under Review') AS under_review
FROM loan_applications
GROUP BY DATE_FORMAT(application_date, '%Y-%m')
ORDER BY application_month;

-- =====================================================
-- 9. Loan Amount Analysis by Loan Type
-- =====================================================

SELECT
    loan_type,
    COUNT(*) AS total_applications,
    ROUND(AVG(requested_amount), 2) AS avg_requested_amount,
    ROUND(MIN(requested_amount), 2) AS min_requested_amount,
    ROUND(MAX(requested_amount), 2) AS max_requested_amount
FROM loan_applications
GROUP BY loan_type
ORDER BY avg_requested_amount DESC;

-- =====================================================
-- 10. High-Risk Customer Profile
-- =====================================================

SELECT
    c.customer_id,
    c.employment_type,
    c.state,
    ch.credit_score,
    ch.num_late_payments_90d,
    ch.num_defaults_prior,
    ROUND(ch.total_outstanding_debt, 2) AS total_outstanding_debt
FROM customers c
INNER JOIN credit_history ch
    ON c.customer_id = ch.customer_id
WHERE
    ch.credit_score < 580
    OR ch.num_defaults_prior >= 1
    OR ch.num_late_payments_90d >= 2
ORDER BY
    ch.credit_score ASC,
    ch.num_defaults_prior DESC
LIMIT 100;
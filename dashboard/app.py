import streamlit as st
import pandas as pd
import plotly.express as px

# -----------------------------------------------------
# Page Configuration
# -----------------------------------------------------
st.set_page_config(
    page_title="Credora Finance | Credit Risk Analytics",
    page_icon="📊",
    layout="wide"
)

# -----------------------------------------------------
# Load Dashboard Dataset
# -----------------------------------------------------
@st.cache_data
def load_data():
    return pd.read_csv("credora_dashboard_dataset.csv")

df = load_data()

df["application_date"] = pd.to_datetime(
    df["application_date"],
    errors="coerce"
)

# -----------------------------------------------------
# Sidebar Filters
# -----------------------------------------------------
st.sidebar.header("Dashboard Filters")

loan_types = sorted(df["loan_type"].dropna().unique())
selected_loan_types = st.sidebar.multiselect(
    "Loan Type",
    options=loan_types,
    default=loan_types
)

states = sorted(df["state"].dropna().unique())
selected_states = st.sidebar.multiselect(
    "State",
    options=states,
    default=states
)

risk_categories = ["Low", "Medium", "High"]
selected_risk_categories = st.sidebar.multiselect(
    "Risk Category",
    options=risk_categories,
    default=risk_categories
)

approval_statuses = sorted(df["approval_status"].dropna().unique())
selected_approval_statuses = st.sidebar.multiselect(
    "Approval Status",
    options=approval_statuses,
    default=approval_statuses
)

# Application Month Filter
df["application_month"] = (
    df["application_date"]
    .dt.to_period("M")
    .astype(str)
)

application_months = sorted(
    df["application_month"].dropna().unique()
)

selected_months = st.sidebar.multiselect(
    "Application Month",
    options=application_months,
    default=application_months
)

# Apply filters
filtered_df = df[
    df["loan_type"].isin(selected_loan_types)
    & df["state"].isin(selected_states)
    & df["risk_category"].isin(selected_risk_categories)
    & df["approval_status"].isin(selected_approval_statuses)
    & df["application_month"].isin(selected_months)
].copy()

# -----------------------------------------------------
# Dashboard Header
# -----------------------------------------------------
st.title("Credora Finance")
st.subheader("Credit Risk & Loan Approval Analytics Platform")

st.write(
    "Interactive portfolio monitoring dashboard for loan applications, "
    "approval analytics, and model-generated credit risk."
)

# -----------------------------------------------------
# Executive Overview
# -----------------------------------------------------
st.markdown("---")
st.header("Executive Overview")

# Total applications
total_applications = len(filtered_df)

# Approval rate
approved_applications = (
    filtered_df["approval_status"] == "Approved"
).sum()

approval_rate = (
    approved_applications / total_applications * 100
    if total_applications > 0 else 0
)

# Historical default rate
known_outcomes = filtered_df[
    filtered_df["loan_default"].notna()
]

historical_default_rate = (
    known_outcomes["loan_default"].mean() * 100
    if len(known_outcomes) > 0 else 0
)

# Portfolio risk metrics
average_risk_score = (
    filtered_df["risk_score"].mean()
    if total_applications > 0 else 0
)

high_risk_applications = (
    filtered_df["risk_category"] == "High"
).sum()

# KPI Cards
col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    st.metric(
        label="Total Applications",
        value=f"{total_applications:,}"
    )

with col2:
    st.metric(
        label="Approval Rate",
        value=f"{approval_rate:.2f}%"
    )

with col3:
    st.metric(
        label="Historical Default Rate",
        value=f"{historical_default_rate:.2f}%"
    )

with col4:
    st.metric(
        label="Average Risk Score",
        value=f"{average_risk_score:.1f}"
    )

with col5:
    st.metric(
        label="High Risk Applications",
        value=f"{high_risk_applications:,}"
    )

st.caption(
    "Historical default rate is calculated only from applications "
    "with known actual outcomes. Risk scores are model-generated "
    "estimates available for the complete portfolio."
)

# -----------------------------------------------------
# Portfolio Risk Distribution
# -----------------------------------------------------
st.markdown("---")
st.header("Portfolio Risk Analysis")

risk_distribution = (
    filtered_df["risk_category"]
    .value_counts()
    .reindex(["Low", "Medium", "High"], fill_value=0)
    .reset_index()
)

risk_distribution.columns = ["Risk Category", "Applications"]

fig_risk = px.bar(
    risk_distribution,
    x="Risk Category",
    y="Applications",
    text="Applications",
    title="Application Distribution by Risk Category",
    category_orders={
        "Risk Category": ["Low", "Medium", "High"]
    }
)

fig_risk.update_traces(
    textposition="outside"
)

fig_risk.update_layout(
    xaxis_title="Risk Category",
    yaxis_title="Number of Applications"
)

st.plotly_chart(
    fig_risk,
    use_container_width=True
)

# -----------------------------------------------------
# Loan Approval Analysis
# -----------------------------------------------------
st.markdown("---")
st.header("Loan Approval Analysis")

approval_distribution = (
    filtered_df["approval_status"]
    .value_counts()
    .reindex(["Approved", "Rejected", "Under Review"], fill_value=0)
    .reset_index()
)

approval_distribution.columns = ["Approval Status", "Applications"]

fig_approval = px.bar(
    approval_distribution,
    x="Approval Status",
    y="Applications",
    text="Applications",
    title="Application Distribution by Approval Status",
    category_orders={
        "Approval Status": ["Approved", "Rejected", "Under Review"]
    }
)

fig_approval.update_traces(
    textposition="outside"
)

fig_approval.update_layout(
    xaxis_title="Approval Status",
    yaxis_title="Number of Applications",
    yaxis_range=[0, approval_distribution["Applications"].max() * 1.15]
)

st.plotly_chart(
    fig_approval,
    use_container_width=True
)

# -----------------------------------------------------
# Credit Score & Default Risk Analysis
# -----------------------------------------------------
st.markdown("---")
st.header("Credit Score & Default Risk Analysis")

credit_df = filtered_df[
    filtered_df["loan_default"].notna()
].copy()

credit_df["credit_score_band"] = pd.cut(
    credit_df["credit_score"],
    bins=[0, 579, 669, 739, 900],
    labels=["Poor (<580)", "Fair (580-669)", "Good (670-739)", "Very Good (740+)"]
)

credit_default = (
    credit_df
    .groupby("credit_score_band", observed=False)["loan_default"]
    .agg(["count", "mean"])
    .reset_index()
)

credit_default["Default Rate (%)"] = credit_default["mean"] * 100

fig_credit = px.bar(
    credit_default,
    x="credit_score_band",
    y="Default Rate (%)",
    text="Default Rate (%)",
    title="Historical Default Rate by Credit Score Band"
)

fig_credit.update_traces(
    texttemplate="%{text:.2f}%",
    textposition="outside"
)

fig_credit.update_layout(
    xaxis_title="Credit Score Band",
    yaxis_title="Historical Default Rate (%)",
    yaxis_range=[0, credit_default["Default Rate (%)"].max() * 1.15]
)

st.plotly_chart(
    fig_credit,
    use_container_width=True
)

st.caption(
    "Default rates in this chart use only applications with known "
    "historical loan outcomes."
)

# -----------------------------------------------------
# Historical Default Rate by Loan Type
# -----------------------------------------------------

loan_type_default = (
    known_outcomes
    .groupby("loan_type")["loan_default"]
    .agg(["count", "mean"])
    .reset_index()
)

loan_type_default["Default Rate (%)"] = (
    loan_type_default["mean"] * 100
)

loan_type_default = loan_type_default.sort_values(
    "Default Rate (%)",
    ascending=False
)

fig_loan_default = px.bar(
    loan_type_default,
    x="loan_type",
    y="Default Rate (%)",
    text="Default Rate (%)",
    title="Historical Default Rate by Loan Type"
)

fig_loan_default.update_traces(
    texttemplate="%{text:.2f}%",
    textposition="outside"
)

fig_loan_default.update_layout(
    xaxis_title="Loan Type",
    yaxis_title="Historical Default Rate (%)"
)

st.plotly_chart(
    fig_loan_default,
    use_container_width=True
)

st.caption(
    "Default rates are calculated only from applications "
    "with known historical loan outcomes."
)

# -----------------------------------------------------
# Credit Score Distribution
# -----------------------------------------------------

fig_credit_distribution = px.histogram(
    filtered_df,
    x="credit_score",
    nbins=30,
    title="Credit Score Distribution"
)

fig_credit_distribution.update_layout(
    xaxis_title="Credit Score",
    yaxis_title="Number of Applications"
)

st.plotly_chart(
    fig_credit_distribution,
    use_container_width=True
)

st.caption(
    "Distribution of applicant credit scores for the currently "
    "selected portfolio filters."
)

# -----------------------------------------------------
# Monthly Application & Approval Trends
# -----------------------------------------------------
st.markdown("---")
st.header("Monthly Application & Approval Trends")

monthly_df = filtered_df.copy()

monthly_df["application_month"] = (
    monthly_df["application_date"]
    .dt.to_period("M")
    .astype(str)
)

# Monthly application volume
monthly_volume = (
    monthly_df
    .groupby("application_month")
    .size()
    .reset_index(name="Applications")
)

fig_monthly_volume = px.line(
    monthly_volume,
    x="application_month",
    y="Applications",
    markers=True,
    title="Monthly Loan Application Volume"
)

fig_monthly_volume.update_layout(
    xaxis_title="Application Month",
    yaxis_title="Applications"
)

# Monthly approval status trend
monthly_status = (
    monthly_df
    .groupby(
        ["application_month", "approval_status"]
    )
    .size()
    .reset_index(name="Applications")
)

fig_monthly_status = px.line(
    monthly_status,
    x="application_month",
    y="Applications",
    color="approval_status",
    markers=True,
    title="Monthly Approval Status Trend"
)

fig_monthly_status.update_layout(
    xaxis_title="Application Month",
    yaxis_title="Applications",
    legend_title="Approval Status"
)

# Display side by side
col1, col2 = st.columns(2)

with col1:
    st.plotly_chart(
        fig_monthly_volume,
        use_container_width=True
    )

with col2:
    st.plotly_chart(
        fig_monthly_status,
        use_container_width=True
    )

# -----------------------------------------------------
# Geographic Loan Distribution
# -----------------------------------------------------
st.markdown("---")
st.header("Geographic Loan Distribution")

state_distribution = (
    filtered_df
    .groupby("state")
    .size()
    .reset_index(name="Applications")
    .sort_values("Applications", ascending=True)
)

fig_state = px.bar(
    state_distribution,
    x="Applications",
    y="state",
    orientation="h",
    text="Applications",
    title="Loan Applications by State"
)

fig_state.update_traces(
    textposition="outside"
)

fig_state.update_layout(
    xaxis_title="Number of Applications",
    yaxis_title="State",
    height=500
)

st.plotly_chart(
    fig_state,
    use_container_width=True
)

# -----------------------------------------------------
# High-Risk Application Watchlist
# -----------------------------------------------------
st.markdown("---")
st.header("High-Risk Application Watchlist")

high_risk_df = filtered_df[
    filtered_df["risk_category"] == "High"
].copy()

high_risk_df = high_risk_df.sort_values(
    "risk_score",
    ascending=False
)

watchlist_columns = [
    "application_id",
    "loan_type",
    "state",
    "credit_score",
    "requested_amount",
    "risk_score",
    "approval_status",
    "outcome_status"
]

st.write(
    f"Showing {len(high_risk_df):,} high-risk applications "
    "based on the current dashboard filters."
)

st.dataframe(
    high_risk_df[watchlist_columns],
    use_container_width=True,
    hide_index=True
)

st.caption(
    "Risk scores are model-generated estimates. For applications "
    "without known historical outcomes, the predicted risk should "
    "not be interpreted as an observed default."
)
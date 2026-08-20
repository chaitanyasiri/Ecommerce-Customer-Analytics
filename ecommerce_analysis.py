# E-Commerce Customer Analytics
# Python Analysis
# Tools: Pandas, NumPy, Matplotlib

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# --------------------------------------------------
# 1. LOAD DATA
# --------------------------------------------------

df = pd.read_excel("ecommerce_customer_data.xlsx")

print("Dataset Shape:", df.shape)
print("\nFirst 5 Rows:")
print(df.head())

# --------------------------------------------------
# 2. DATA UNDERSTANDING
# --------------------------------------------------

print("\nDataset Information:")
print(df.info())

print("\nDescriptive Statistics:")
print(df.describe(include="all"))

print("\nUnique Values:")
print(df.nunique())

# --------------------------------------------------
# 3. DATA QUALITY CHECK
# --------------------------------------------------

print("\nMissing Values:")
print(df.isnull().sum())

print("\nDuplicate Rows:", df.duplicated().sum())

# --------------------------------------------------
# 4. DATA CLEANING
# --------------------------------------------------

# Remove duplicate records
df = df.drop_duplicates()

# Standardize column names
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)

print("\nShape After Cleaning:", df.shape)

# --------------------------------------------------
# 5. BASIC KPIs
# --------------------------------------------------

total_orders = df["order_id"].nunique()
total_customers = df["customer_id"].nunique()
total_revenue = df["revenue_inr"].sum()

average_order_value = (
    total_revenue / total_orders
    if total_orders > 0 else 0
)

print("\n========== BUSINESS KPIs ==========")
print("Total Orders:", total_orders)
print("Total Customers:", total_customers)
print("Total Revenue:", round(total_revenue, 2))
print("Average Order Value:", round(average_order_value, 2))

# --------------------------------------------------
# 6. CUSTOMER ORDER FREQUENCY
# --------------------------------------------------

customer_orders = (
    df.groupby("customer_id")["order_id"]
    .nunique()
    .reset_index(name="order_count")
)

print("\nCustomer Order Frequency:")
print(customer_orders.head())

# New Customers
new_customers = (customer_orders["order_count"] == 1).sum()

# Returning Customers
returning_customers = (customer_orders["order_count"] > 1).sum()

print("\nNew Customers:", new_customers)
print("Returning Customers:", returning_customers)

# --------------------------------------------------
# 7. CUSTOMER SEGMENT ANALYSIS
# --------------------------------------------------

segment_analysis = (
    df.groupby("customer_segment")
    .agg(
        customers=("customer_id", "nunique"),
        orders=("order_id", "nunique"),
        revenue=("revenue_inr", "sum")
    )
    .sort_values("revenue", ascending=False)
)

print("\nCustomer Segment Analysis:")
print(segment_analysis)

# --------------------------------------------------
# 8. PRODUCT CATEGORY ANALYSIS
# --------------------------------------------------

category_analysis = (
    df.groupby("product_category")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("revenue_inr", "sum")
    )
    .sort_values("revenue", ascending=False)
)

print("\nProduct Category Analysis:")
print(category_analysis)

# --------------------------------------------------
# 9. REGION ANALYSIS
# --------------------------------------------------

region_analysis = (
    df.groupby("region")
    .agg(
        customers=("customer_id", "nunique"),
        orders=("order_id", "nunique"),
        revenue=("revenue_inr", "sum")
    )
    .sort_values("revenue", ascending=False)
)

print("\nRegional Performance:")
print(region_analysis)

# --------------------------------------------------
# 10. SALES CHANNEL ANALYSIS
# --------------------------------------------------

channel_analysis = (
    df.groupby("sales_channel")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("revenue_inr", "sum")
    )
    .sort_values("revenue", ascending=False)
)

print("\nSales Channel Analysis:")
print(channel_analysis)

# --------------------------------------------------
# 11. ORDER STATUS ANALYSIS
# --------------------------------------------------

order_status = (
    df.groupby("order_status")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("revenue_inr", "sum")
    )
    .sort_values("orders", ascending=False)
)

print("\nOrder Status Analysis:")
print(order_status)

# --------------------------------------------------
# 12. DELIVERY PERFORMANCE
# --------------------------------------------------

if "delivery_days" in df.columns:

    delivery_analysis = (
        df.groupby("order_status")
        ["delivery_days"]
        .mean()
        .sort_values()
    )

    print("\nAverage Delivery Days:")
    print(delivery_analysis)

# --------------------------------------------------
# 13. MONTHLY REVENUE TREND
# --------------------------------------------------

if "order_date" in df.columns:

    df["order_date"] = pd.to_datetime(
        df["order_date"],
        errors="coerce"
    )

    monthly_revenue = (
        df.groupby(df["order_date"].dt.to_period("M"))
        ["revenue_inr"]
        .sum()
    )

    print("\nMonthly Revenue:")
    print(monthly_revenue)

    monthly_revenue.plot(
        kind="line",
        marker="o",
        figsize=(10, 5)
    )

    plt.title("Monthly Revenue Trend")
    plt.xlabel("Month")
    plt.ylabel("Revenue (INR)")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

# --------------------------------------------------
# 14. TOP CUSTOMERS
# --------------------------------------------------

top_customers = (
    df.groupby("customer_id")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("revenue_inr", "sum")
    )
    .sort_values("revenue", ascending=False)
    .head(10)
)

print("\nTop 10 Customers by Revenue:")
print(top_customers)

# --------------------------------------------------
# 15. TOP PRODUCTS / CATEGORIES
# --------------------------------------------------

print("\nTop Product Categories:")
print(category_analysis.head(10))

# --------------------------------------------------
# 16. BUSINESS INSIGHTS
# --------------------------------------------------

print("\n========== KEY BUSINESS INSIGHTS ==========")

print(
    "1. Customer purchasing behavior was analyzed using "
    "order frequency and customer-level revenue."
)

print(
    "2. Customer segments were compared based on orders, "
    "customers and revenue contribution."
)

print(
    "3. Product categories and regions were evaluated to "
    "identify high-performing areas."
)

print(
    "4. Sales channels were compared to understand where "
    "revenue is being generated."
)

print(
    "5. Order status and delivery performance were analyzed "
    "to identify potential operational issues."
)

print(
    "6. Top customers were identified based on total revenue "
    "contribution."
)

print("\nAnalysis Completed Successfully.")

# ============================================================
# E-COMMERCE CUSTOMER ANALYTICS
# Python Data Analysis
# Tools: Pandas, NumPy, Matplotlib
# ============================================================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# ============================================================
# 1. LOAD DATA
# ============================================================

df = pd.read_excel("ecommerce_dataset.xlsx")

print("Dataset Shape:", df.shape)
print("\nFirst 5 Records:")
print(df.head())


# ============================================================
# 2. STANDARDIZE COLUMN NAMES
# ============================================================

df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)

print("\nColumns:")
print(df.columns.tolist())


# ============================================================
# 3. DATA UNDERSTANDING
# ============================================================

print("\nDataset Information:")
df.info()

print("\nDescriptive Statistics:")
print(df.describe(include="all"))

print("\nUnique Values:")
print(df.nunique())


# ============================================================
# 4. DATA QUALITY CHECK
# ============================================================

print("\nMissing Values:")
print(df.isnull().sum())

print("\nDuplicate Rows:", df.duplicated().sum())


# ============================================================
# 5. REMOVE DUPLICATES
# ============================================================

df = df.drop_duplicates()

print("\nShape After Removing Duplicates:", df.shape)


# ============================================================
# 6. DATA TYPES
# ============================================================

df["order_date"] = pd.to_datetime(
    df["order_date"],
    errors="coerce"
)

numeric_columns = [
    "age",
    "quantity",
    "unit_price_inr",
    "discount_percent",
    "shipping_fee_inr",
    "order_total_inr",
    "delivery_days"
]

for column in numeric_columns:
    df[column] = pd.to_numeric(
        df[column],
        errors="coerce"
    )


# ============================================================
# 7. BUSINESS KPIs
# ============================================================

total_orders = df["order_id"].nunique()
total_customers = df["customer_id"].nunique()
total_revenue = df["order_total_inr"].sum()
total_quantity = df["quantity"].sum()

average_order_value = (
    total_revenue / total_orders
    if total_orders > 0 else 0
)

print("\n========== BUSINESS KPIs ==========")
print("Total Orders:", total_orders)
print("Total Customers:", total_customers)
print("Total Revenue:", round(total_revenue, 2))
print("Total Quantity:", total_quantity)
print("Average Order Value:", round(average_order_value, 2))


# ============================================================
# 8. CUSTOMER ORDER FREQUENCY
# ============================================================

customer_orders = (
    df.groupby("customer_id")["order_id"]
    .nunique()
    .reset_index(name="order_count")
)

customer_orders["customer_type"] = np.where(
    customer_orders["order_count"] == 1,
    "New Customer",
    "Returning Customer"
)

print("\nCustomer Type Distribution:")
print(
    customer_orders["customer_type"]
    .value_counts()
)


# ============================================================
# 9. CUSTOMER SEGMENT ANALYSIS
# ============================================================

segment_analysis = (
    df.groupby("customer_segment")
    .agg(
        customers=("customer_id", "nunique"),
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum"),
        quantity=("quantity", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nCustomer Segment Analysis:")
print(segment_analysis)


# ============================================================
# 10. PRODUCT CATEGORY ANALYSIS
# ============================================================

category_analysis = (
    df.groupby("product_category")
    .agg(
        orders=("order_id", "nunique"),
        quantity=("quantity", "sum"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nProduct Category Analysis:")
print(category_analysis)


# ============================================================
# 11. TOP PRODUCTS
# ============================================================

top_products = (
    df.groupby("product_name")
    .agg(
        orders=("order_id", "nunique"),
        quantity=("quantity", "sum"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
    .head(10)
)

print("\nTop 10 Products:")
print(top_products)


# ============================================================
# 12. REGIONAL ANALYSIS
# ============================================================

region_analysis = (
    df.groupby("region")
    .agg(
        customers=("customer_id", "nunique"),
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nRegional Performance:")
print(region_analysis)


# ============================================================
# 13. SALES CHANNEL ANALYSIS
# ============================================================

channel_analysis = (
    df.groupby("sales_channel")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum"),
        quantity=("quantity", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nSales Channel Analysis:")
print(channel_analysis)


# ============================================================
# 14. DEVICE TYPE ANALYSIS
# ============================================================

device_analysis = (
    df.groupby("device_type")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nDevice Type Analysis:")
print(device_analysis)


# ============================================================
# 15. PAYMENT METHOD ANALYSIS
# ============================================================

payment_analysis = (
    df.groupby("payment_method")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nPayment Method Analysis:")
print(payment_analysis)


# ============================================================
# 16. ORDER STATUS ANALYSIS
# ============================================================

status_analysis = (
    df.groupby("order_status")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "orders",
        ascending=False
    )
)

print("\nOrder Status Analysis:")
print(status_analysis)


# ============================================================
# 17. DELIVERY PERFORMANCE
# ============================================================

delivery_analysis = (
    df.groupby("order_status")["delivery_days"]
    .mean()
    .sort_values()
)

print("\nAverage Delivery Days by Order Status:")
print(delivery_analysis)


print("\nOverall Average Delivery Days:",
      round(df["delivery_days"].mean(), 2))


# ============================================================
# 18. MONTHLY REVENUE TREND
# ============================================================

monthly_revenue = (
    df.groupby(
        df["order_date"].dt.to_period("M")
    )["order_total_inr"]
    .sum()
)

print("\nMonthly Revenue:")
print(monthly_revenue)


plt.figure(figsize=(10, 5))

monthly_revenue.plot(
    kind="line",
    marker="o"
)

plt.title("Monthly Revenue Trend")
plt.xlabel("Month")
plt.ylabel("Revenue (INR)")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()


# ============================================================
# 19. TOP CUSTOMERS
# ============================================================

top_customers = (
    df.groupby(
        ["customer_id", "customer_name"]
    )
    .agg(
        orders=("order_id", "nunique"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
    .head(10)
)

print("\nTop 10 Customers by Revenue:")
print(top_customers)


# ============================================================
# 20. DISCOUNT ANALYSIS
# ============================================================

discount_analysis = (
    df.groupby("product_category")
    .agg(
        average_discount=("discount_percent", "mean"),
        revenue=("order_total_inr", "sum")
    )
    .sort_values(
        "revenue",
        ascending=False
    )
)

print("\nDiscount Analysis:")
print(discount_analysis)


# ============================================================
# 21. CUSTOMER TYPE VISUALIZATION
# ============================================================

customer_type_counts = (
    customer_orders["customer_type"]
    .value_counts()
)

plt.figure(figsize=(7, 5))

customer_type_counts.plot(
    kind="bar"
)

plt.title("New vs Returning Customers")
plt.xlabel("Customer Type")
plt.ylabel("Number of Customers")
plt.xticks(rotation=0)
plt.tight_layout()
plt.show()


# ============================================================
# 22. CATEGORY REVENUE VISUALIZATION
# ============================================================

plt.figure(figsize=(9, 5))

category_analysis["revenue"].plot(
    kind="bar"
)

plt.title("Revenue by Product Category")
plt.xlabel("Product Category")
plt.ylabel("Revenue (INR)")
plt.xticks(rotation=30)
plt.tight_layout()
plt.show()


# ============================================================
# 23. REGIONAL REVENUE VISUALIZATION
# ============================================================

plt.figure(figsize=(9, 5))

region_analysis["revenue"].plot(
    kind="bar"
)

plt.title("Revenue by Region")
plt.xlabel("Region")
plt.ylabel("Revenue (INR)")
plt.xticks(rotation=30)
plt.tight_layout()
plt.show()


# ============================================================
# 24. KEY BUSINESS INSIGHTS
# ============================================================

print("\n")
print("=" * 60)
print("KEY BUSINESS INSIGHTS")
print("=" * 60)

print("""
1. Customer purchasing behavior was analyzed using order
   frequency and customer-level revenue.

2. New and returning customers were compared to understand
   customer retention behavior.

3. Customer segments were evaluated based on revenue,
   orders and purchasing quantity.

4. Product categories and individual products were analyzed
   to identify high-performing areas.

5. Regional and sales-channel performance was compared.

6. Device type and payment method were analyzed to understand
   customer purchasing preferences.

7. Order status and delivery performance were evaluated to
   identify operational patterns.

8. Monthly revenue trends were analyzed to identify changes
   in business performance.

9. Top customers were identified based on revenue contribution.
""")


print("\nE-Commerce Analysis Completed Successfully.")            monthly_revenue.plot(
        

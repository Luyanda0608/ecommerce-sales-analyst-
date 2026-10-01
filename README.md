# E-commerce Sales Analysis — SQL Portfolio Project

## Project overview

This project analyzes sales data for a fictional online retailer using SQL. The goal is to answer practical management questions about revenue, products, customers, cities, repeat purchasing, and customer behavior.

The project was designed as a portfolio project for a junior Data Analyst role.

## Business questions

The analysis answers questions such as:

- How much revenue and how many units were sold?
- Which products generate the most revenue?
- Which categories perform best?
- Which customers spend the most?
- Which cities generate the most revenue?
- Which customers spend above the overall average?
- Which customers are repeat customers?
- Which customers spend above their city average?
- What percentage of revenue comes from each customer?
- How does revenue accumulate over time?
- Which customers make a second purchase within 14 days?
- Which customers have large gaps between orders?
- Which customers are both high-value and repeat buyers?
- What is the final management-level sales summary?

## Dataset

The project uses three tables:

### customers

| Column | Description |
|---|---|
| customer_id | Unique customer identifier |
| name | Customer name |
| city | Customer city |
| signup_date | Customer registration date |

### products

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_name | Product name |
| category | Product category |
| price | Product unit price |

### orders

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer identifier |
| product_id | Product identifier |
| quantity | Units purchased |
| order_date | Date of purchase |

## Key results

- Total customers: **8**
- Customers with orders: **8**
- Total orders: **15**
- Total units sold: **27**
- Total revenue: **7,525**
- Average order value: **501.67**

### Product performance

The highest-revenue product was **Laptop**, generating **4,800** in revenue.

### Category performance

- Electronics revenue: **7,050**
- Accessories revenue: **475**

### Customer performance

- Highest-spending customer: **Chloe — 3,260**
- Second-highest: **Frank — 1,500**
- Third-highest: **Alice — 1,425**

### City performance

- Johannesburg revenue: **4,935**
- Pretoria revenue: **1,550**
- Cape Town revenue: **800**
- Durban revenue: **240**

## SQL skills demonstrated

This project demonstrates practical use of:

- SELECT and filtering
- INNER JOIN and LEFT JOIN
- GROUP BY and HAVING
- Aggregate functions: SUM, COUNT, AVG, MIN
- COALESCE
- CASE WHEN
- CTEs (`WITH`)
- Subquery-style multi-step analysis
- Window functions
- RANK()
- LAG()
- LEAD()
- Running totals
- Partitioned averages
- Revenue percentages
- Customer segmentation logic
- Business-focused SQL analysis

## Portfolio value

The main focus of this project is not just writing SQL syntax. It demonstrates the ability to translate business questions into SQL analysis and turn raw transactional data into management-relevant metrics.

## Repository structure

```text
ecommerce-sales-analysis/
├── README.md
└── ecommerce_sales_analysis.sql
```

## Author

SQL portfolio project — Data Analyst learning portfolio.

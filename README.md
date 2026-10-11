# Customer Churn & Cohort Retention Analysis | MySQL · Power BI

A SQL-driven analysis of customer behaviour for an e-commerce dataset. It covers cohort retention, churn identification, customer lifetime value (CLV) and monthly revenue, with the results visualised in Power BI.

## Business Questions
- How many customers do we acquire each month, and how many keep buying?
- What is the retention rate of each monthly cohort over time?
- Which customers have churned (no purchase in 90+ days)?
- What is each customer's lifetime value and average order value?
- How does revenue build up for each cohort over its lifetime?

## Tools Used
| Tool | Purpose |
|------|---------|
| MySQL | Data cleaning, cohort analysis, churn and CLV queries |
| Power BI | Customer behaviour dashboard |
| GitHub | Version control and documentation |

## Dataset
| File | Description |
|------|-------------|
| `customers.csv` | Customer details (including country) |
| `orders.csv` | Order-level data: status, order date, total amount, discount, shipping fee |
| `order_items.csv` | Item-level data: category, quantity, unit price |

## Project Workflow
All queries are in [`Customer_churns_cohorts_project.sql`](Customer_churns_cohorts_project.sql).

### 1. Data Exploration & Quality Checks
- Joined `orders` with `order_items` using `order_id` to understand how the tables relate
- Checked for duplicate customer records
- Counted customers by country

### 2. Data Cleaning (`clean_sales` view)
Kept only valid sales by:
- Excluding **Cancelled, Returned and Refunded** orders
- Removing orders with zero or negative amounts
- Removing records without a customer ID
- Creating an `order_month` field for monthly analysis

### 3. Cohort Analysis
- **Customer cohorts:** assigned each customer to the month of their first order
- **Cohort activity:** calculated the number of months between a customer's first order and each later order
- **Retention rate:** calculated cohort size, active users per month and retention % using CTEs

### 4. Churn Identification
- Calculated days since each customer's last order, measured against the latest order date in the dataset
- Labelled customers as **Churned** (no order in more than 90 days) or **Active**

### 5. Customer Lifetime Value & Revenue
- Calculated total orders, historical CLV and average order value per customer
- Calculated monthly revenue and **cumulative revenue per cohort** using a window function (`SUM() OVER`)

### 6. Dashboard (Power BI)
File: [`Customer_behavior.pbix`](Customer_behavior.pbix)
- Visualises customer behaviour, retention and revenue trends



## SQL Concepts Used
`INNER JOIN` · `GROUP BY / HAVING` · `CTEs` · `Views` · `Window Functions` · `CASE WHEN` · `Date Functions (DATE_FORMAT, PERIOD_DIFF, DATEDIFF)` · `Cohort Analysis`

## Key Insights
> Findings.
- 99% of customers were classified as churned (no order in 90+ days)
- Month-1 retention averaged 1606%, dropping to 16% by month 10
- The best-performing cohort was Month 8

## Dashboard Preview
> - <img width="620" height="346" alt="Customer_behavior" src="https://github.com/user-attachments/assets/fcd85221-6f87-4302-bd6d-6d5008f038e3" /> `![Customer_behavior](Customer_behavior.png)`

## Repository Structure
```
SQL_Customer_churns_project/
├── customers.csv                        # Customer data
├── orders.csv                           # Order data
├── order_items.csv                      # Order item data
├── Customer_churns_cohorts_project.sql  # MySQL analysis queries
├── Customer_behavior.pbix               # Power BI dashboard
└── README.md
```

## How to Run
1. Import the three CSV files into MySQL (the tables used are `customers_details`, `orders` and `order_items`)
2. Run `Customer_churns_cohorts_project.sql` from top to bottom, since the later queries depend on the views created earlier
3. Open `Customer_behavior.pbix` in Power BI Desktop

## Author
**Varatharaj S.**, Data Research Analyst
[LinkedIn](#) · [GitHub](https://github.com/Varatha1)


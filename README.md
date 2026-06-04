# Online Retail Sales Database
## Introduction

In this project, I designed a relational database using SQL to store, manage, and analyze sales data. Using an online retail sales dataset, I analyzed and normalized the relationships among entities to design the database schema. Additional entities were added to create a more realistic analysis.

Various SQL reports were developed to reveal overall sales trends and patterns, evaluate sales performance by product and employee, conduct customer retention analysis, and identify customer purchasing behavior. I created database views to improve the efficiency and reusability of analytical queries. I implemented an index on a frequently queried column to enhance query performance. Query execution plans were reviewed to evaluate the impact of indexing and demonstrate performance optimization concepts.

In addition, a data quality audit report was created to identify potential data issues within the database. Database triggers were implemented to address the issue found during the audit.

Dataset Source: https://archive.ics.uci.edu/dataset/352/online+retail

## Database Design

### Entity Relationship Diagram (ERD)

The following ERD illustrates the relational database structure used in this project. The database contains 11 strong entities and 1 associative entity created to resolve a many-to-many relationship between invoices and products.

### The schema includes:

- One-to-many relationships
-	Many-to-many relationships
-	Unary relationships
-	Binary relationships
-	Supertype and subtype constructs

 <img width="70%" alt="Online_retail_ERD" src="https://github.com/user-attachments/assets/a7a0d7ce-d1fb-4da2-aa6e-aa4b01d7191f" />

### Database Schema Diagram (DBeaver)
<img width="70%" alt="Screenshot 2026-05-22 at 10 37 38" src="https://github.com/user-attachments/assets/2960cdc6-5973-4dfc-8b74-55b1fdc86bff" />

## Tools and Skills

### Database & Tools

- SQL
- DBeaver
- Relational Database Design
- Entity Relationship Diagram (ERD)

### Database Design Concepts

- Data Normalization
- Not Null Constraints
- CHECK Constraints
-	Views
-	Indexes
-	Triggers
### SQL Concepts

- Joins
- Aggregate Functions
- Common Table Expressions (CTEs)
- Subqueries
- Window Functions
- CASE Statements
- EXISTS / NOT EXISTS
- Date Functions
- Data Quality Validation
- Query Performance Optimization

## SQL Reports and Analysis

### Sales Data Analysis

This section focuses on overall sales performance across countries, products, employees, and time periods. The reports analyze key business metrics such as customer volume, total sales, average transaction value, monthly sales trends, product performance, and employee sales performance. These reports help identify top-performing countries, products, and employees while highlighting overall sales trends over time.

Included Reports:

- Report 2: Sales by Country
- Report 4: Product Performance Report
- Report 5: Employee Sales Performance
- Report 7: Monthly Sales Trend Analysis

### Customer Analysis

This section focuses on customer information, purchasing behavior, customer retention, and revenue contribution. The reports analyze customer purchase history, customer loyalty and revenue rankings to better understand customer value and purchasing behavior.

Included Reports:

- Report 1: Customer Directory Report
- Report 3: Customer Purchase History
- Report 8: Customer Retention Analysis
- Report 10: Customer Revenue Ranking

### Data Quality Verification

This report validates data quality across the database by identifying missing information, invalid references, and inconsistencies that may affect reporting accuracy.

Included Reports:

- Report 9: Data Quality Audit

## Key Findings

1. The United Kingdom generated the majority of total company revenue and represented the largest customer base.   
   <img width="70%" alt="Screenshot 2026-05-29 at 10 14 17" src="https://github.com/user-attachments/assets/d39c9482-7386-48d5-bbf7-e62104b381b1" />

2. Most customers were classified as new customers, while loyal customers contributed the highest proportion of total revenue.
   <img width="70%" alt="Screenshot 2026-05-29 at 10 14 55" src="https://github.com/user-attachments/assets/37400e97-5dd4-4a3f-9469-2c092a6f79be" />

3. The best-selling product by quantity sold was *World War 2 Gliders Asstd Designs*.
   <img width="70%" alt="Screenshot 2026-05-29 at 10 15 43" src="https://github.com/user-attachments/assets/fcb3303f-bfa2-4460-876c-b678a89e76da" />

4. Data quality auditing identified products with invalid pricing information, including records with a unit price of zero.
   <img width="70%" alt="Screenshot 2026-05-29 at 10 17 02" src="https://github.com/user-attachments/assets/92983788-7775-4212-a0d0-d45777d5e49f" />

## Database Features

### Views

Created a customer revenue view to summarize the number of orders, total revenue, and average order value for each customer. This view improves report reusability.

### Indexes

Implemented an index on the `country_id` column in the Customer table, which is frequently used in filtering and join operations. Before the index was created, SQLite performed a full table scan to locate customers from the United Kingdom. After the index was implemented, SQLite utilized the index to directly locate matching records, reducing the amount of data scanned and improving query performance.

### Triggers

Based on the findings of the Data Quality Audit Report (Report 9), triggers were implemented to prevent users from inserting or updating products with zero or negative unit prices in the Product table.







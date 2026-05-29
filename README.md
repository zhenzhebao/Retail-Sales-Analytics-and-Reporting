# Online Retail Sales Database
## Introduction

For this project, I created a relational database in SQL by analyzing the information within the online retail sales dataset. I normalized the relationships in the dataset and designed an entity relationship diagram (ERD) to structure the database before creating the tables and importing the data into the database. After building the database, I developed various SQL reports to conduct business analysis from different perspectives and identify trends and insights within the sales data.

The original dataset contains transactional retail information such as invoices, customers, products, quantities, pricing, and country information. I extended the original dataset by adding additional entities and relationships including employee, country, membership, position, department, category, and product department tables to create a more realistic and business-oriented relational database.

Dataset Source:

https://archive.ics.uci.edu/dataset/352/online+retail

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
- SQLite
- DBeaver
- Relational Database Design
- Entity Relationship Diagram (ERD)

### Database Design Concepts

- Data Normalization
- One-to-Many Relationships
- Many-to-Many Relationships
- Unary Relationships
- Binary Relationships
- Supertype and Subtype Constructs
- Not Null Constraints
- CHECK Constraints
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







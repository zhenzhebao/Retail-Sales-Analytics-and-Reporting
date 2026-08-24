# Retail Sales Analytics and Reporting
## Introduction

This project demonstrates how to design two different databases for different purposes: a relational database in PostgreSQL to store information efficiently and accurately, and a data warehouse in Snowflake using data warehousing concepts and a star schema to support analytical reporting. The original dataset was cleaned and prepared with Excel, and additional information was added to support more realistic analysis.

An Entity-Relationship Diagram (ERD) was created by identifying the entities and resolving relationships among them. Different database design techniques, such as associative entities, recursive relationship, and Supertype and subtype construct were implemented to represent business processes accurately. The tables were then created in PostgreSQL and the data was imported.

For the data warehouse, I identified the analyses I planned to perform, the information required, and the grain of each row to design the star schema. Slowly Changing Dimension Type 2 (SCD Type 2) was incorporated into the design to potentially support tracking information changes over time. Basic administration and table creation were performed in Snowflake to prepare the environment, while data for the warehouse was prepared by querying the existing database in PostgreSQL.

At the end of the project, various SQL reports were written using both databases to analyze retail sales performance from different perspectives, including overall trends, customers, products, and sales representatives.


Dataset Source: https://archive.ics.uci.edu/dataset/352/online+retail

## Tools and skills 

### Database & Tools

-	PostgreSQL
-	Snowflake
-	DBeaver
  
### Database Design

-	Relational Database Design
-	Entity Relationship Diagram (ERD)
-	Data Modeling
-	Data Normalization

### Data Warehousing
- Data Warehousing
- Dimensional Modeling
- Star Schema Design

### Database Objects & Constraints

-	NOT NULL Constraints
-	CHECK Constraints

### SQL Concepts
- Joins
- Aggregate Functions
- Common Table Expressions (CTEs)
- Subqueries
- Window Functions (RANK, DENSE_RANK, PERCENT_RANK, LAG)
- CASE Statements
- Conditional Aggregation
- Date Functions
- NULL Handling
- Data Type Conversion

## Database Design


### Entity Relationship Diagram (ERD)
The following ERD illustrates the relational database structure used in this project. The database contains eleven strong entities and one associative entity. The invoice_product associative entity was created to resolve the many-to-many relationship between invoice and product.

The schema includes:

- One-to-many relationships
- Many-to-many relationships
- Unary relationships
- Binary relationships
- Supertype and subtype constructs

<img width="70%" alt="Online_retail_ERD" src="https://github.com/user-attachments/assets/cf9332d4-67e5-4cae-b7d9-f3238536d360" />


### Database Schema Diagram (DBeaver)
<img width="70%" alt="Screenshot 2026-06-17 at 21 07 08" src="https://github.com/user-attachments/assets/708a707d-f258-4979-9ba7-a89d455e2436" />

### Star Schema

A star schema was designed to support analysis of sales and returns; therefore, each row represents one customer ordering or returning one product at a time. Three measures item quantity, item transaction price, and item order value were identified, along with four dimensions: customer, employee, date, and product. Since customer, employee, and product information can change over time, Slowly Changing Dimension Type 2 (SCD Type 2) was incorporated into the schema design to support potential information changes in the future.

### Entity Relationship Diagram (ERD)
<img width="70%" alt="star_schema_ERD" src="https://github.com/user-attachments/assets/dbb886ac-9a5a-439e-a9a8-b1818044b24a" />



# Retail Sales Analytics and Reporting
## Introduction

This project demonstrates how to design two different databases for different purposes: a relational database in PostgreSQL to store information efficiently and accurately, and a data warehouse in Snowflake using data warehousing concepts and a star schema to support analytical reporting. The original dataset was cleaned and prepared with Excel, and additional information was added to support more realistic analysis.

An Entity-Relationship Diagram (ERD) was created by identifying the entities and resolving relationships among them. Different database design techniques, such as associative entities, recursive relationship, and Supertype and subtype construct were implemented to represent business processes accurately. The tables were then created in PostgreSQL and the data was imported.

For the data warehouse, I identified the analyses I planned to perform, the information required, and the grain of each row to design the star schema. Slowly Changing Dimension Type 2 (SCD Type 2) was incorporated into the design to potentially support tracking information changes over time. Basic administration and table creation were performed in Snowflake to prepare the environment, while data for the warehouse was prepared by querying the existing database in PostgreSQL.

As part of the project, various SQL reports were written using both databases to analyze retail sales performance from different perspectives, including overall trends, customers, products, and sales representatives.

An AI Agent is built to allow users to analyze sales returns using data stored on a PostgreSQL server through natural language and receive a report that summarizes the important findings without any prior knowledge of SQL.

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


## Retail Returns Analysis Agent
### Overview

An AI Agent is built to allow users to analyze sales returns using data stored on a PostgreSQL server through natural language and receive a report that summarizes the important findings without any prior knowledge of SQL. The AI Agent has access to LLM models from OpenAI and a PostgreSQL server to accomplish this. The LLM model is responsible for determining what actions the AI Agent should perform. More specifically, the model can generate an analysis plan and relevant SQL queries based on the user's question. It can also adapt its behavior once it receives SQL results and clarification from the user to determine if additional analysis is needed. When the analysis is complete, it interprets the results and produces the final report.

### Architecture and Guardrails

#### PostgreSQL
The all_return_data view is created based on cleaned data and includes only relevant information needed for analysis.
The Python application has only SELECT permission on this view to prevent data modification by the LLM. The prepared view hides the underlying database structure from the LLM and improves the quality of SQL queries constructed by the LLM.

#### LLM
- Inexpensive model: gpt-6-luna
Classifies user questions to ensure the Agent only processes relevant questions.

- gpt-5.6-luna (all other tasks)
    - Generates analysis plans based on user questions, asks users to clarify ambiguous questions, and requests human approval before conducting analysis
    - Determines the appropriate predefined tools or constructs SQL queries when needed for analysis, generates correct arguments for predefined tools, and initiates tool calls
    - Processes SQL results to determine if additional analysis is needed or generates the final report when the analysis is complete

Structured Outputs with text format are implemented to ensure the model generates its responses in a consistent format.

#### Python Script

- Processes user questions or responses to exit the program, restart the conversation, or send them to the LLM.
    
- Processes text responses from the LLM, executes the appropriate next steps, and presents the results to the user.
    
- Processes tool call requests from the LLM, selects the appropriate predefined tools and validates the arguments provided by the LLM, or prepares customized SQL queries. Sends SQL requests to the PostgreSQL server, cleans the SQL query results, and sends them back to the LLM.
    
- Performs basic validation of LLM responses and SQL query results to check for missing or unexpected information, and raises exceptions when errors are detected.

### Technologies

- Python, SQL, PostgreSQL, OpenAI API
- Codex (prompt-based automated testing)

### Skills

#### AI Development
- Prompt Engineering
- Structured Outputs
- LLM Tool Calling

#### Software Development
- Application Development
- Control Flow and State Management
- API and Database Integration
- Error Handling and Data Validation 

### Execution Logic
The program displays instructions on how to use it for the first time.

The user input (question or response) will be checked to ensure it is not empty or one of the keywords (exit, help, reset). If the input is a keyword, the program will perform the appropriate action.

Other questions will go through question classification. An invalid question is rejected, and the user has some attempts to retry before the program stops. So, the API tokens will not be wasted on processing many irrelevant questions at this step. If the question is relevant, processing_request will be set to True so the program is ready to take a response from the user, and the question will be processed for the first time. If the LLM believes it can’t generate an analysis plan, the conversation will reset (e.g., analyze returns in 2024). Otherwise, the LLM response will be displayed, the user will need to approve the analysis plan, and the current response ID is saved as the previous message ID for the next request to the LLM to retain conversation history.

Once the program receives the user response, the LLM will process it. If the analysis status is cancel_analysis, the conversation is reset. If the LLM generates another text response, it will display it to the user and ask for their response. If that is a tool, a while loop will perform the tool call request, prepare SQL queries, send SQL requests, clean returned SQL data, and send it back to the LLM.

Once the LLM receives the tool result, if it believes the analysis is completed, analysis_status is final_report, and the report will be displayed. The user can press Enter or type reset to start a new conversation. The processing status will be set to False, the tool call loop will break, and the main while loop will continue. The user can also type exit to end the program. It sets the program status to False, breaks the tool call loop, and continues the main while loop. The main while loop needs the program status to be True to run, so the program stops.

The user can also ask a follow-up question about the final report. A text response will be displayed, the tool call loop will break, and the main loop will continue for a response. Cancel analysis will set processing_request to False, break the tool call loop, and continue the main loop for a new question. A tool call request will continue the current tool call loop.

If the LLM doesn’t generate the final report, a text response will be displayed, the tool call loop will break, and the program will ask for a response. A tool call will continue the current tool call loop and process the tool call again.

### Demonstration

#### Analysis Plan and Human Approval
<img width="70%" alt="Screenshot 2026-10-07 at 23 27 58" src="https://github.com/user-attachments/assets/91612da9-1b23-44af-9205-1295d76e2559" />

#### Final Report
<img width="70%" alt="Picsew_20261007233650" src="https://github.com/user-attachments/assets/1f9e23d2-9db9-40f7-97d2-1c842c822e89" />



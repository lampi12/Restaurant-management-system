# Restaurant-management-system

A full-featured backend database system that simulates the operations of a restaurant and food delivery platform. Built using PostgreSQL and PL/pgSQL, this project demonstrates real-world database modeling, transactional logic, audit logging, and reporting.

Technologies
  - PostgreSQL
  - SQL
  - PL/pgSQL (Stored Procedures, Triggers, Views)


Feautures 
Normalized Schema covering:
  - Customers, Orders, Payments, Deliveries, Promotions, and Reviews
Stored Procedures for:
  - Updating delivery statuses
  - Applying promotions
  - Applying promotions
Triggers for:
  - Audit logging deleted orders and contact info updates
  - Automatic status changes on payment success
  - Zeroing amounts on refunded payments
Views for:
  - Customer and restaurant analytics
  - Delivery statistics
  - Updatable customer profiles

Sample Data
Includes insert scripts for:
  - 10 sample customers, drivers, and restaurants
  - 10+ menu items and real orders
  - Example reviews and promotions

How to Use 
1. Clone the repository:
     - git clone https://github.com/lampi12/Restaurant-management-system.git
2. Open the SQL file in pgAdmin, DBeaver, or your preferred SQL tool.
3. Run the script in restaurant_management_system.sql to set up the database.
4. Query the views and run stored procedures for reporting and simulation.

Use Cases
  - Backend SQL development demo
  - Relational schema design
  - Entry-level database project for job portfolios

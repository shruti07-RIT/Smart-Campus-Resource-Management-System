# Smart Campus Resource Management System

## Database Team

This folder contains the MySQL database implementation
for the Smart Campus Resource Management System.

## Database

SMARTCAMPUS

## Technologies

- MySQL
- MySQL Workbench
- InnoDB

## Tables

- DEPARTMENT
- RESOURCE_TYPE
- LOCATION
- CAMPUS_NODE
- TIME_SLOT
- USERS
- RESOURCES
- BOOKINGS
- ROUTE_HISTORY
- CAMPUS_EDGE

## Database Features

- Primary Keys
- Foreign Keys
- UNIQUE constraints
- CHECK constraints
- Normalization verification
- Resource booking
- Booking cancellation
- Transaction management
- COMMIT
- ROLLBACK
- Exception handling
- FOR UPDATE row locking

## Transaction Management

The booking operation is implemented using a
transaction-safe stored procedure.

### Transaction Flow

START TRANSACTION
↓
Validate User
↓
Validate Resource
↓
Validate Time Slot
↓
Check Existing Booking
↓
INSERT Booking
↓
COMMIT

If an SQL exception occurs:

ROLLBACK

## ACID Properties

### Atomicity
The booking operation is handled as one transaction.

### Consistency
Primary keys, foreign keys, UNIQUE constraints
and CHECK constraints maintain valid data.

### Isolation
FOR UPDATE locks the selected resource row
during the transaction.

### Durability
After COMMIT, the booking is permanently stored.

## Files

| File | Description |
|---|---|
| 01_schema.sql | Database and table creation |
| 02_seed_data.sql | Initial/sample data |
| 03_procedures_transactions.sql | Stored procedures and transactions |
| 04_queries_reports.sql | Queries and reports |
| er_diagram | Database ER diagram |
| screenshots | Database and transaction demonstrations |


Team Leader :- Shruti Dabade

Team members:-          
Anam Patvekar
Shweta Jamdade
Atharv Hirave
                          


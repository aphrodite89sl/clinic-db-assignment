# Build a Complete Database Management System Assignment
Clinic Booking System — MySQL Database Project

## 📘 Overview

This project is a relational database management system (RDBMS) built using MySQL.
It is designed for a Clinic Booking System, enabling efficient management of patients, doctors, appointments, prescriptions, and billing.

### The database demonstrates:

Proper normalization and relational integrity
Realistic relationships between healthcare entities
Use of SQL constraints, foreign keys, and data validation

### This project fulfills the requirements for the Database Management System assignment.

## 🎯 Objectives

Design and implement a complete relational database using MySQL.
Demonstrate understanding of:
Primary & Foreign keys
One-to-One, One-to-Many, and Many-to-Many relationships
Constraints (NOT NULL, UNIQUE, CHECK, ENUM, etc.)
Provide a clear .sql file that can recreate the entire database schema.

## 🗂️ Files Included
| File Name       | Description                                                                                |
| --------------- | ------------------------------------------------------------------------------------------ |
| `clinic_db.sql` | SQL script containing all `CREATE DATABASE`, `CREATE TABLE`, and relationship constraints. |
| `README.md`     | Project documentation and setup guide.                                                     |

## 🧩 Database Schema Overview
The system contains the following key entities:
| Table                                 | Description                                            |
| ------------------------------------- | ------------------------------------------------------ |
| **users**                             | Stores clinic staff login and profile details.         |
| **doctors**                           | Holds doctor information and links to specialties.     |
| **specialties**                       | List of medical specialties.                           |
| **patients**                          | Patient demographic and contact information.           |
| **appointments**                      | Records of scheduled visits with doctors.              |
| **services**                          | Medical services offered (consultations, tests, etc.). |
| **appointment_services**              | Many-to-Many link between appointments and services.   |
| **prescriptions**                     | Prescription records tied to appointments and doctors. |
| **prescription_items**                | Medications prescribed per prescription.               |
| **medications**                       | List of available medications.                         |
| **invoices**                          | Billing records for appointments.                      |
| **invoice_items**                     | Itemized list of charges per invoice.                  |
| **payments**                          | Payment transactions for invoices.                     |
| **rooms**                             | Physical clinic rooms for appointments.                |
| **allergies** / **patient_allergies** | Records of patient allergies and severity.             |


## 🔗 Key Relationships

One-to-Many:
One patient → many appointments
One doctor → many appointments
One patient → many invoices

Many-to-Many:
Appointments ↔ Services (appointment_services)
Prescriptions ↔ Medications (prescription_items)
Patients ↔ Allergies (patient_allergies)

One-to-One:
Each invoice → one appointment (optional link)

## ⚙️ How to Run the Project

### 1️⃣ Requirements
MySQL Server 5.7+ or 8.0+
MySQL Workbench / phpMyAdmin / command-line client

### 2️⃣ Setup Steps
1. Clone or download this repository:

git clone https://github.com/<your-username>/clinic-db-assignment.git
cd clinic-db-assignment

2. Open MySQL and run the SQL script:

mysql -u root -p < clinic_db.sql

3. Verify the database:

SHOW DATABASES;
USE clinic_db;
SHOW TABLES;

Optionally, test the inserted sample data:

SELECT * FROM patients;
SELECT * FROM appointments;

## ✅ Constraints & Data Integrity

PRIMARY KEY and FOREIGN KEY constraints used across all tables.
NOT NULL, UNIQUE, and CHECK constraints ensure data validity.
ENUM used for controlled attributes (e.g. status, gender, role).
ON DELETE CASCADE / SET NULL to maintain referential integrity.

## 🧾 Example Data
Sample data for testing:
  1 doctor (Dr. Alice Mokoena)
  1 patient (Thabo Nkosi)
  1 appointment (2025-11-10)
  1 service (GP Consultation)
  1 invoice (linked to the appointment)

## 📚 References
[MySQL Documentation](https://dev.mysql.com/doc/)

[W3Schools MySQL Tutorial](https://www.w3schools.com/mysql/)

[DB Diagram IO](https://dbdiagram.io/) — for visual ERD design

# 👨‍💻 Author

Your Name: Siyamthanda Sifanele

Course: Database Systems / Software Development

Institution: PLP ACADEMY

# 🏁 License

This project is developed for educational purposes and is free to use or modify for learning.

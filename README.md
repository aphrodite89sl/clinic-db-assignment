# Clinic Management System Database

A comprehensive relational database system for managing clinic operations, including patient appointments, medical services, billing, and prescriptions.

## 📋 Overview

This MySQL database provides a complete backend solution for clinic management, supporting:

- Patient registration and medical history
- Doctor and staff management
- Appointment scheduling with conflict prevention
- Medical services and billing
- Prescription management
- Invoice and payment tracking
- Allergy tracking

## 🗄️ Database Schema

### Core Tables

| Table | Description |
|-------|-------------|
| `users` | Clinic staff (admins, receptionists, nurses, doctors) |
| `patients` | Patient demographic and contact information |
| `doctors` | Medical practitioners with specialties |
| `specialties` | Medical specialties (Cardiology, Pediatrics, etc.) |
| `appointments` | Scheduled patient visits with status tracking |
| `services` | Billable medical services and procedures |
| `appointment_services` | Services provided during appointments |
| `prescriptions` | Medication prescriptions |
| `medications` | Drug inventory and information |
| `invoices` | Billing and payment records |
| `allergies` | Patient allergy tracking |

## 🚀 Quick Start

### Prerequisites

- MySQL 5.7+ or MySQL 8.0 (recommended)
- MySQL command-line client or GUI tool (MySQL Workbench, phpMyAdmin, etc.)

### Installation

1. **Clone or download the SQL file**

   ```bash
   # Save the SQL file as clinic_db.sql
   ```

2. **Run the SQL script**

   ```bash
   mysql -u root -p < clinic_db.sql
   ```

   Or within MySQL client:

   ```sql
   SOURCE /path/to/clinic_db.sql;
   ```

3. **Verify installation**

   ```sql
   USE clinic_db;
   SHOW TABLES;
   ```

### Sample Data

The database includes sample data for testing:

- 3 medical specialties
- 3 clinic staff users
- 3 doctors with different specialties
- 3 sample patients
- 4 consultation rooms
- 4 medical services
- Sample appointments and invoices

## 🔧 Database Structure Details

### Key Features

- **UTF-8 Support**: Full Unicode support for international names
- **Referential Integrity**: Foreign key constraints with appropriate cascade rules
- **Data Validation**: Check constraints and ENUM types
- **Audit Trail**: Created/updated timestamps on all tables
- **Soft Delete**: `is_active` flags for non-destructive deletions
- **Performance**: Optimized indexes for common queries

### Important Constraints

- Appointment time validation (end > start)
- Doctor availability conflict prevention (via trigger)
- Unique constraints on critical fields (license numbers, national IDs)
- Appropriate foreign key cascade rules

## 📊 Sample Queries

### View Today's Appointments

```sql
SELECT * FROM appointment_overview 
WHERE DATE(scheduled_start) = CURDATE() 
ORDER BY scheduled_start;
```

### Find Patient Medical History

```sql
SELECT p.first_name, p.last_name, a.scheduled_start, a.status, s.name as service
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN appointment_services aps ON a.appointment_id = aps.appointment_id
LEFT JOIN services s ON aps.service_id = s.service_id
WHERE p.patient_id = 1;
```

### Generate Revenue Report

```sql
SELECT 
    DATE(i.invoice_date) as date,
    COUNT(*) as invoices,
    SUM(i.total) as daily_revenue
FROM invoices i
WHERE i.status = 'paid'
GROUP BY DATE(i.invoice_date)
ORDER BY date DESC;
```

## 🔐 User Management

### Default Users Created

| Username | Role | Purpose |
|----------|------|---------|
| `admin` | admin | Full system access |
| `reception1` | reception | Appointment management |
| `nurse1` | nurse | Patient care and vitals |

**Note**: Default passwords are hashed examples. Change passwords in production.

## 🛠️ Administration

### Backup Database

```bash
mysqldump -u username -p clinic_db > clinic_backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
mysql -u username -p clinic_db < clinic_backup.sql
```

### Monitor Performance

```sql
-- Check table sizes
SELECT table_name, table_rows, data_length, index_length 
FROM information_schema.tables 
WHERE table_schema = 'clinic_db';

-- Check active connections
SHOW PROCESSLIST;
```

## 📈 Extending the System

### Adding New Medical Specialties

```sql
INSERT INTO specialties (name, description) 
VALUES ('Neurology', 'Brain and nervous system specialist');
```

### Creating New Services

```sql
INSERT INTO services (code, name, description, base_price) 
VALUES ('MRI-BRAIN', 'MRI Brain Scan', 'Magnetic resonance imaging of brain', 1200.00);
```

### Custom Views

Create custom views for reporting:

```sql
CREATE VIEW monthly_financials AS
SELECT 
    YEAR(invoice_date) as year,
    MONTH(invoice_date) as month,
    SUM(total) as monthly_revenue,
    COUNT(*) as total_invoices
FROM invoices 
WHERE status = 'paid'
GROUP BY YEAR(invoice_date), MONTH(invoice_date);
```

## 🐛 Troubleshooting

### Common Issues

1. **Connection Errors**
   - Verify MySQL service is running
   - Check username/password permissions

2. **Constraint Violations**
   - Ensure foreign key relationships exist
   - Check for duplicate unique values

3. **Performance Issues**
   - Monitor query execution with EXPLAIN
   - Ensure indexes are being used

### Support Queries

```sql
-- Check database health
SHOW TABLE STATUS FROM clinic_db;

-- Verify constraints
SELECT TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME 
FROM information_schema.TABLE_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'clinic_db';

-- Check data consistency
SELECT COUNT(*) as patient_count FROM patients;
SELECT COUNT(*) as appointment_count FROM appointments;
```

## 📄 License

This database schema is provided for educational and commercial use. Please ensure compliance with healthcare data regulations (HIPAA, GDPR, etc.) in your jurisdiction.

## 🤝 Contributing

When extending this system:

1. Maintain consistent naming conventions
2. Add appropriate indexes for new query patterns
3. Include foreign key constraints for data integrity
4. Update this documentation accordingly

## 📞 Support

For database-related issues:

1. Check MySQL error logs
2. Verify user permissions
3. Confirm database version compatibility
4. Test with sample data provided

---

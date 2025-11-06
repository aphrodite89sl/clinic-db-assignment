-- 1) Create database and use it
CREATE DATABASE IF NOT EXISTS clinic_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE clinic_db;

-- 2) Enable strict mode recommendations (optional)
-- SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- 3) Table: users (clinic staff — receptionists, admins)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role ENUM('admin','reception','nurse','doctor') NOT NULL DEFAULT 'reception',
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4) Table: specialties (doctors' specialties)
CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

-- 5) Table: doctors
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL, -- optional link to users table if doctor is also a user account
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    license_number VARCHAR(50) UNIQUE,
    specialty_id INT,
    phone VARCHAR(20),
    email VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctor_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_doctor_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 6) Table: patients
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    date_of_birth DATE,
    gender ENUM('male','female','other') DEFAULT 'other',
    national_id VARCHAR(50) UNIQUE, -- may be SSN / national id
    email VARCHAR(150),
    phone VARCHAR(20),
    address VARCHAR(255),
    emergency_contact_name VARCHAR(150),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 7) Table: rooms (for on-site appointments)
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    floor VARCHAR(20),
    description VARCHAR(255)
) ENGINE=InnoDB;

-- 8) Table: services (consultation, x-ray, blood test, etc.)
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB;

-- 9) Table: appointments
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    scheduled_start DATETIME NOT NULL,
    scheduled_end DATETIME NOT NULL,
    room_id INT,
    status ENUM('scheduled','checked_in','in_progress','completed','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_room FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE SET NULL,
    CONSTRAINT chk_appointment_time CHECK (scheduled_end > scheduled_start)
) ENGINE=InnoDB;

-- 10) Many-to-Many: appointment_services (an appointment can include multiple billable services)
CREATE TABLE appointment_services (
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (appointment_id, service_id),
    CONSTRAINT fk_as_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_as_service FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11) Table: medications
CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    manufacturer VARCHAR(150),
    form VARCHAR(50), -- e.g., tablet, syrup
    strength VARCHAR(50),
    UNIQUE(name, strength)
) ENGINE=InnoDB;

-- 12) Table: prescriptions (each prescription linked to appointment and doctor)
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    prescribed_by INT NOT NULL, -- doctor_id
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    directions TEXT,
    CONSTRAINT fk_prescription_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_prescription_doctor FOREIGN KEY (prescribed_by) REFERENCES doctors(doctor_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 13) prescription_items (medications for each prescription) - many-to-many with extra fields
CREATE TABLE prescription_items (
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    dose VARCHAR(100),
    duration_days INT,
    PRIMARY KEY (prescription_id, medication_id),
    CONSTRAINT fk_pi_prescription FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
    CONSTRAINT fk_pi_medication FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 14) Table: invoices
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    invoice_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status ENUM('unpaid','paid','partially_paid','cancelled') NOT NULL DEFAULT 'unpaid',
    CONSTRAINT fk_invoice_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_invoice_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 15) Table: invoice_items (links services / prescription charges to invoice)
CREATE TABLE invoice_items (
    invoice_item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    CONSTRAINT fk_ii_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 16) Table: payments
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL,
    method ENUM('cash','card','insurance','eft') DEFAULT 'cash',
    reference VARCHAR(150),
    CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 17) Optional: patient_allergies (many-to-many)
CREATE TABLE allergies (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    notes TEXT
) ENGINE=InnoDB;

CREATE TABLE patient_allergies (
    patient_id INT NOT NULL,
    allergy_id INT NOT NULL,
    severity ENUM('mild','moderate','severe') DEFAULT 'moderate',
    PRIMARY KEY (patient_id, allergy_id),
    CONSTRAINT fk_pa_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_pa_allergy FOREIGN KEY (allergy_id) REFERENCES allergies(allergy_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 18) Indexes for common lookups (improves query perf)
CREATE INDEX idx_appointments_doctor_date ON appointments (doctor_id, scheduled_start);
CREATE INDEX idx_appointments_patient_date ON appointments (patient_id, scheduled_start);

-- 19) Sample data inserts (small amount to test)
INSERT INTO specialties (name, description) VALUES
    ('General Practice','Primary care physician'),
    ('Pediatrics','Child health specialist'),
    ('Dermatology','Skin specialist');

INSERT INTO users (username, password_hash, full_name, role, email) VALUES
    ('admin','<hashed_pw>','Clinic Admin','admin','admin@clinic.local'),
    ('reception1','<hashed_pw>','Reception One','reception','reception@clinic.local');

INSERT INTO doctors (user_id, first_name, last_name, license_number, specialty_id, phone, email)
VALUES (NULL,'Alice','Mokoena','DOC-20345',1,'+27101234567','alice.mokoena@clinic.local');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, national_id, phone, email)
VALUES ('Thabo','Nkosi','1984-05-12','male','8005121234080','+27102345678','thabo.nkosi@example.com');

INSERT INTO rooms (room_number, floor, description) VALUES ('101','1','Consult Room 1');

INSERT INTO services (code, name, description, base_price) VALUES
    ('CONS-GP','GP Consultation','General practitioner consultation',250.00),
    ('BLOOD-RT','Blood Test - Routine','Basic blood panel',350.00);

-- Create an appointment and attach a service
INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, room_id, status)
VALUES (1, 1, '2025-11-10 09:00:00', '2025-11-10 09:20:00', 1, 'scheduled');

INSERT INTO appointment_services (appointment_id, service_id, quantity, unit_price)
VALUES (1, 1, 1, 250.00);

-- Generate an invoice for the appointment
INSERT INTO invoices (patient_id, appointment_id, subtotal, tax, total, status)
VALUES (1, 1, 250.00, 0.00, 250.00, 'unpaid');

INSERT INTO invoice_items (invoice_id, description, quantity, unit_price)
VALUES (1, 'GP Consultation', 1, 250.00);




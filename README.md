Clinic Booking Database Management System
📌 Overview

This project implements a Clinic Booking System using MySQL.
It provides a relational database schema that supports patients, doctors, specialties, clinics, rooms, services, schedules, and appointments.

The database enforces constraints and relationships to ensure data consistency and integrity.

📂 Features

Well-structured tables for patients, doctors, clinics, services, etc.

Proper constraints:

PRIMARY KEY for unique identification.

FOREIGN KEY for relationships.

UNIQUE and NOT NULL for data integrity.

Relationships:

One-to-One → (doctor ↔ license number, patient ↔ email).

One-to-Many → (doctor → appointments, clinic → rooms, patient → appointments).

Many-to-Many → (doctors ↔ specialties).

⚙️ Installation & Setup

Clone this repository:

git clone https://github.com/graceygrayy/clinic-booking-dbms.git
cd clinic-booking-dbms


Open clinic_booking_schema.sql in MySQL Workbench.

Run the script to create the database and tables.

Verify by running:

SHOW DATABASES;
USE clinic_db;
SHOW TABLES;

📊 Database Schema (ERD Overview)

patients: Stores patient details.

doctors: Stores doctor details.

specialties: Medical specialties (e.g., Pediatrics, Cardiology).

doctor_specialties: Links doctors to their specialties (many-to-many).

clinics: Clinic branches/locations.

rooms: Rooms within each clinic.

services: Available medical services.

schedules: Doctor availability.

appointments: Patient bookings with doctors.

prescriptions: Records medications for appointments.

payments: Payment details for services.

DROP DATABASE IF EXISTS `clinic_db`;
CREATE DATABASE `clinic_db` CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
USE `clinic_db`;
CREATE TABLE `patients` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
`first_name` VARCHAR(100) NOT NULL,
`last_name` VARCHAR(100) NOT NULL,
`dob` DATE NULL,
`gender` ENUM('male','female','other') DEFAULT 'other',
`email` VARCHAR(255) NULL,
`phone` VARCHAR(50) NULL,
`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_patients_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `doctors` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
`first_name` VARCHAR(100) NOT NULL,
`last_name` VARCHAR(100) NOT NULL,
`email` VARCHAR(255) NULL,
`phone` VARCHAR(50) NULL,
`license_number` VARCHAR(100) NULL,
`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_doctors_email` (`email`),
UNIQUE KEY `uq_doctors_license` (`license_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `specialties` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`name` VARCHAR(150) NOT NULL,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_specialties_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `clinics` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`address` VARCHAR(500) NULL,
`phone` VARCHAR(50) NULL,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_clinics_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `rooms` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`clinic_id` INT UNSIGNED NOT NULL,
`room_number` VARCHAR(50) NOT NULL,
`room_type` VARCHAR(100) NULL,
PRIMARY KEY (`id`),
INDEX `idx_rooms_clinic` (`clinic_id`),
CONSTRAINT `fk_rooms_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics`(`id`) ON DELETE CASCADE,
UNIQUE KEY `uq_clinic_room` (`clinic_id`,`room_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `services` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`duration_minutes` INT UNSIGNED NOT NULL DEFAULT 30,
`price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_services_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `doctor_specialties` (
`doctor_id` BIGINT UNSIGNED NOT NULL,
`specialty_id` INT UNSIGNED NOT NULL,
PRIMARY KEY (`doctor_id`,`specialty_id`),
CONSTRAINT `fk_ds_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`id`) ON DELETE CASCADE,
CONSTRAINT `fk_ds_specialty` FOREIGN KEY (`specialty_id`) REFERENCES `specialties`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `doctor_clinics` (
`doctor_id` BIGINT UNSIGNED NOT NULL,
`clinic_id` INT UNSIGNED NOT NULL,
PRIMARY KEY (`doctor_id`,`clinic_id`),
CONSTRAINT `fk_dc_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`id`) ON DELETE CASCADE,
CONSTRAINT `fk_dc_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `doctor_schedules` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
`doctor_id` BIGINT UNSIGNED NOT NULL,
`clinic_id` INT UNSIGNED NOT NULL,
`day_of_week` TINYINT UNSIGNED NOT NULL COMMENT '0=Sunday..6=Saturday',
`start_time` TIME NOT NULL,
`end_time` TIME NOT NULL,
PRIMARY KEY (`id`),
INDEX `idx_sched_doctor` (`doctor_id`),
INDEX `idx_sched_clinic` (`clinic_id`),
CONSTRAINT `fk_sched_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`id`) ON DELETE CASCADE,
CONSTRAINT `fk_sched_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `appointments` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
`patient_id` BIGINT UNSIGNED NOT NULL,
`doctor_id` BIGINT UNSIGNED NOT NULL,
`clinic_id` INT UNSIGNED NOT NULL,
`room_id` INT UNSIGNED NULL,
`service_id` INT UNSIGNED NULL,
`scheduled_start` DATETIME NOT NULL,
`scheduled_end` DATETIME NOT NULL,
`status` ENUM('scheduled','checked_in','in_progress','completed','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
`notes` TEXT,
PRIMARY KEY (`id`),
INDEX `idx_appts_patient` (`patient_id`),
INDEX `idx_appts_doctor` (`doctor_id`),
INDEX `idx_appts_clinic` (`clinic_id`),
CONSTRAINT `fk_appts_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`id`) ON DELETE CASCADE,
CONSTRAINT `fk_appts_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`id`) ON DELETE RESTRICT,
CONSTRAINT `fk_appts_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics`(`id`) ON DELETE RESTRICT,
CONSTRAINT `fk_appts_room` FOREIGN KEY (`room_id`) REFERENCES `rooms`(`id`) ON DELETE SET NULL,
CONSTRAINT `fk_appts_service` FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `appointments` ADD CONSTRAINT `uq_doctor_start` UNIQUE (`doctor_id`,`scheduled_start`);

CREATE TABLE `prescriptions` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
`appointment_id` BIGINT UNSIGNED NOT NULL,
`doctor_id` BIGINT UNSIGNED NOT NULL,
`patient_id` BIGINT UNSIGNED NOT NULL,
`notes` TEXT,
`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_presc_appointment` (`appointment_id`),
CONSTRAINT `fk_presc_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`id`) ON DELETE CASCADE,
CONSTRAINT `fk_presc_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`id`) ON DELETE RESTRICT,
CONSTRAINT `fk_presc_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `payments` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
`appointment_id` BIGINT UNSIGNED NOT NULL,
`amount` DECIMAL(10,2) NOT NULL,
`method` ENUM('cash','card','insurance') NOT NULL,
`status` ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
`paid_at` DATETIME NULL,
PRIMARY KEY (`id`),
UNIQUE KEY `uq_payments_appointment` (`appointment_id`),
CONSTRAINT `fk_payments_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE VIEW `vw_upcoming_appointments` AS
SELECT
a.id AS appointment_id,
a.patient_id,
CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
a.doctor_id,
CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
a.clinic_id,
c.name AS clinic_name,
a.scheduled_start,
a.scheduled_end,
a.status
FROM `appointments` a
JOIN `patients` p ON p.id = a.patient_id
JOIN `doctors` d ON d.id = a.doctor_id
JOIN `clinics` c ON c.id = a.clinic_id
WHERE a.scheduled_start >= NOW();

INSERT INTO `specialties` (`name`) VALUES ('General Practice'), ('Pediatrics'), ('Cardiology');


INSERT INTO `clinics` (`name`, `address`, `phone`) VALUES
('Downtown Clinic','123 Main St, City','0244000000'),
('Uptown Health Center','45 Park Ave, City','0244111111');


INSERT INTO `services` (`name`, `duration_minutes`, `price`) VALUES
('General Consultation',30,20.00),
('Pediatric Consultation',30,25.00),
('Cardiology Follow-up',45,50.00);


INSERT INTO `doctors` (`first_name`,`last_name`,`email`,`license_number`) VALUES
('Samuel','Mensah','sam.mensah@example.com','LIC-001'),
('Ama','Owusu','ama.owusu@example.com','LIC-002');


INSERT INTO `doctor_specialties` (`doctor_id`,`specialty_id`) VALUES (1,1),(2,2);
INSERT INTO `doctor_clinics` (`doctor_id`,`clinic_id`) VALUES (1,1),(2,2);


INSERT INTO `patients` (`first_name`,`last_name`,`dob`,`email`,`phone`) VALUES
('Grace','Adjei','1990-06-12','grace.adjei@example.com','0244222222'),
('Kofi','Amoah','1985-11-02','kofi.amoah@example.com','0244333333');


-- Appointments (use string datetimes — MySQL will convert)
INSERT INTO `appointments` (`patient_id`,`doctor_id`,`clinic_id`,`service_id`,`scheduled_start`,`scheduled_end`,`status`) VALUES
(1,1,1,1, CONCAT(CURDATE(),' 09:00:00'), CONCAT(CURDATE(),' 09:30:00'),'scheduled'),
(2,2,2,2, CONCAT(CURDATE(),' 10:00:00'), CONCAT(CURDATE(),' 10:30:00'),'scheduled');



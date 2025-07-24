# 🏨 Hotel Management Database

**HotelManagerDB** is a relational database system designed to manage hotel operations. It supports customer registrations, room bookings, service usage, staff management, payments, and auditing.

---

## 📌 Purpose

This database is intended for a multi-user hotel management application used by both hotel staff (administrators, managers, cleaners) and clients (to make online bookings).

---

## 🗃️ Database Structure

The database includes the following tables:

### 1. `Clients` — Guest Information
| Field            | Data Type       | Description                |
|------------------|------------------|----------------------------|
| id_client        | INT (PK)         | Unique identifier          |
| full_name        | VARCHAR(150)     | Full name of the guest     |
| birth_date       | DATE             | Date of birth              |
| citizenship      | VARCHAR(100)     | Country of citizenship     |
| passport_number  | VARCHAR(50)      | Passport number            |
| phone            | VARCHAR(20)      | Phone number               |
| email            | VARCHAR(100)     | Email address              |
| address          | TEXT             | Residential address        |

---

### 2. `Room` — Hotel Rooms
| Field          | Data Type      | Description                         |
|----------------|-----------------|-------------------------------------|
| number_room    | VARCHAR(10) PK  | Room number                         |
| type           | VARCHAR(50)     | Type (e.g., suite, standard)        |
| capacity       | SMALLINT        | Maximum occupancy                   |
| price_room     | DECIMAL(10,2)   | Price per night                     |
| status_room    | VARCHAR(20)     | Status (available, occupied, etc.)  |
| comfort_level  | VARCHAR(50)     | Comfort level (e.g., deluxe)        |
| description    | TEXT            | Additional room description         |

---

### 3. `Booking` — Room Bookings
| Field             | Data Type      | Description                       |
|-------------------|----------------|-----------------------------------|
| id_booking        | VARCHAR(50) PK | Booking ID                        |
| id_client         | INT FK         | Linked guest ID                   |
| number_room       | VARCHAR(10) FK | Linked room number                |
| date_reservation  | DATE           | Reservation date                  |
| date_check_in     | DATE           | Check-in date                     |
| date_check_out    | DATE           | Check-out date                    |
| status_booking    | ENUM           | Status: reserved, canceled, completed |
| total_price       | DECIMAL(10,2)  | Total cost of booking             |

---

### 4. `Service` — Available Services
| Field       | Data Type       | Description              |
|-------------|------------------|---------------------------|
| id_service  | INT PK           | Service ID               |
| name        | VARCHAR(100)     | Service name             |
| description | TEXT             | Description              |
| price       | DECIMAL(10,2)    | Price                    |

---

### 5. `Booking_Services` — Services Used per Booking
| Field       | Data Type      | Description                     |
|-------------|----------------|----------------------------------|
| booking_id  | VARCHAR(50) FK | Linked booking ID               |
| service_id  | INT FK         | Linked service ID               |
| quantity    | SMALLINT       | Quantity used                   |

---

### 6. `Staff` — Hotel Employees
| Field         | Data Type      | Description                    |
|---------------|----------------|--------------------------------|
| id_staff      | INT PK         | Staff ID                       |
| full_name     | VARCHAR(150)   | Full name                      |
| job_title     | VARCHAR(100)   | Job title                      |
| phone         | VARCHAR(20)    | Contact number                 |
| home_address  | TEXT           | Home address                   |
| login         | VARCHAR(100)   | Login name                     |
| password      | VARCHAR(100)   | Password hash                  |
| role          | VARCHAR(50)    | Role (admin, staff, etc.)      |

---

### 7. `Payments` — Payment Records
| Field         | Data Type      | Description                    |
|---------------|----------------|--------------------------------|
| id_payment    | INT PK         | Payment ID                     |
| booking_id    | VARCHAR(50) FK | Related booking ID             |
| amount        | DECIMAL(10,2)  | Paid amount                    |
| payment_date  | DATE           | Payment date                   |
| method        | VARCHAR(50)    | Payment method (cash, card)    |
| status        | VARCHAR(50)    | Payment status                 |

---

### 8. `Maintenance` — Room Maintenance Log
| Field           | Data Type      | Description                     |
|------------------|----------------|----------------------------------|
| id_maintenance   | INT PK         | Maintenance record ID           |
| room_number      | VARCHAR(10) FK | Affected room number            |
| start_date       | DATE           | Maintenance start date          |
| end_date         | DATE           | Maintenance end date            |
| reason           | TEXT           | Reason (cleaning, repairs, etc.)|

---

### 9. `Users` — System Users (Login)
| Field         | Data Type      | Description                  |
|---------------|----------------|------------------------------|
| id_user       | INT PK         | User ID                      |
| username      | VARCHAR(100)   | Username                     |
| password_hash | VARCHAR(100)   | Password hash                |
| role          | VARCHAR(50)    | User role (admin, employee)  |
| last_login    | DATETIME       | Last login timestamp         |

---

### 10. `Logs` — Action Audit Log
| Field       | Data Type      | Description                       |
|-------------|----------------|------------------------------------|
| id_log      | INT PK         | Log record ID                     |
| user_id     | INT FK         | ID of user who performed action   |
| action      | TEXT           | Action type (INSERT, UPDATE, DELETE) |
| log_time    | DATETIME       | Timestamp                         |
| description | TEXT           | Action details                    |

---

## ⚙️ Requirements

- **MySQL 5.7+** (or MariaDB)
- InnoDB storage engine (for foreign keys)

---

## 📥 Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/PAG-0418/Hotel_Managment_BD.git
2. Import the database schema:
   ```bash
   mysql -u your_user -p your_database < schema.sql
3. Connect the database to your backend application.

---

## 🙋‍♂️ Author
Pascalov Alexandr  
📧 s.paskalovalex18@gmail.com  
📅 2025
# 🏨 Hotel Management Database — Stored Procedures & Transactions

## 📘 Overview
This project represents a **complete SQL-based hotel management system**.  
It focuses on **data integrity**, **automation**, and **realistic hotel operations** using **stored procedures**, **transactions**, and **error handling**.

Each procedure is designed to simulate real hotel management scenarios: client registration, staff management, room booking, check-in, maintenance logging, and service management.

---

## ⚙️ Core Features
- ✅ Secure client and staff registration (with unique checks)
- 🛏️ Booking creation and management
- 🧾 Service assignment to bookings
- 🧳 Client check-in logic
- 🔧 Room maintenance tracking
- 🔒 Transactions with rollback protection
- ⚠️ Error handling using `SIGNAL` and `EXIT HANDLER`

---

## 👤 AddClient
Adds a new client to the hotel database.  
Includes validation for **unique document number, phone, and email**.

### 🧠 Logic
- Checks for duplicates (document, phone, email)
- Rolls back transaction if any duplicate is found

### 💻 Code
```sql
CREATE PROCEDURE AddClient (
    IN p_last_name VARCHAR(100),
    IN p_first_name VARCHAR(100),
    IN p_middle_name VARCHAR(100),
    IN p_birth_date DATE,
    IN p_gender CHAR(1),
    IN p_citizenship VARCHAR(100),
    IN p_document_type VARCHAR(50),
    IN p_document_number VARCHAR(50),
    IN p_document_issued_by VARCHAR(150),
    IN p_document_issue_date DATE,
    IN p_address TEXT,
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE v_document_exists INT DEFAULT 0;
    DECLARE v_phone_exists INT DEFAULT 0;
    DECLARE v_email_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while adding client.' AS ErrorMessage;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_document_exists FROM Clients WHERE document_number = p_document_number;
    IF v_document_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client with this document already exists';
    END IF;

    SELECT COUNT(*) INTO v_phone_exists FROM Clients WHERE phone = p_phone;
    IF v_phone_exists > 0 THEN
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Client with this phone already exists';
    END IF;

    SELECT COUNT(*) INTO v_email_exists FROM Clients WHERE email = p_email;
    IF v_email_exists > 0 THEN
        SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Client with this email already exists';
    END IF;

    INSERT INTO Clients (
        last_name, first_name, middle_name, birth_date, gender, citizenship,
        document_type, document_number, document_issued_by, document_issue_date,
        address, phone, email
    ) VALUES (
        p_last_name, p_first_name, p_middle_name, p_birth_date, p_gender, p_citizenship,
        p_document_type, p_document_number, p_document_issued_by, p_document_issue_date,
        p_address, p_phone, p_email
    );

    COMMIT;
    SELECT 'Client successfully added.' AS Message;
END;
```

### ▶️ Example Call
```sql
CALL AddClient(
    'Ivanov', 'Ivan', 'Ivanovich', '1990-05-15', 'M', 'Russian',
    'Passport', '4510123456', 'MVD Russia', '2015-06-20',
    'Moscow, Lenina st. 25', '+79161234569', 'ivanovv@mail.ru'
);
```

---

## 👨‍💼 AddStaff
Registers a new hotel staff member with validation for unique **phone** and **login**.

### 💻 Code
```sql
CREATE PROCEDURE AddStaff (
    IN p_last_name_staff VARCHAR(100),
    IN p_first_name_staff VARCHAR(100),
    IN p_middle_name_staff VARCHAR(100),
    IN p_job_title ENUM('admin','receptionist','cleaner','manager'),
    IN p_phone VARCHAR(20),
    IN p_home_address TEXT,
    IN p_login VARCHAR(100),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    DECLARE v_phone_exists INT DEFAULT 0;
    DECLARE v_login_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while adding staff member.' AS ErrorMessage;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_phone_exists FROM Staff WHERE phone = p_phone;
    IF v_phone_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staff member with this phone already exists';
    END IF;

    SELECT COUNT(*) INTO v_login_exists FROM Staff WHERE login = p_login;
    IF v_login_exists > 0 THEN
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Staff member with this login already exists';
    END IF;

    INSERT INTO Staff (
        last_name_staff, first_name_staff, middle_name_staff, job_title, phone, home_address, login, password_hash
    ) VALUES (
        p_last_name_staff, p_first_name_staff, p_middle_name_staff, p_job_title, p_phone, p_home_address, p_login, p_password_hash
    );

    COMMIT;
    SELECT 'Staff member successfully added.' AS Message;
END;
```

### ▶️ Example Call
```sql
CALL AddStaff(
    'Popescu', 'Ion', 'Vasile', 'manager',
    '+37360111222', 'Chisinau, Stefan cel Mare 123',
    'ion.popescu', 'StrongPass123'
);
```

---

## 🏨 AddBooking
Creates a booking for a specific client and room, automatically calculating total cost.

### 💻 Code
```sql
CREATE PROCEDURE AddBooking (
    IN p_document_number VARCHAR(20),
    IN p_room_number VARCHAR(10),
    IN p_date_check_in DATE,
    IN p_date_check_out DATE
)
BEGIN
    DECLARE v_id_client INT;
    DECLARE v_room_price DECIMAL(10,2);
    DECLARE v_days INT;
    DECLARE v_total_price DECIMAL(10,2);
    DECLARE v_room_status ENUM('free','occupied','maintenance');

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while creating booking.' AS ErrorMessage;
    END;

    START TRANSACTION;
    SELECT id_client INTO v_id_client FROM Clients WHERE document_number = p_document_number LIMIT 1;

    IF v_id_client IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client with this document number was not found.';
    END IF;

    SELECT status_room, price_room INTO v_room_status, v_room_price FROM Room WHERE number_room = p_room_number;
    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Room not found.';
    END IF;

    IF v_room_status <> 'free' THEN
        SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Room is not available for booking.';
    END IF;

    SET v_days = DATEDIFF(p_date_check_out, p_date_check_in);
    SET v_total_price = v_days * v_room_price;

    INSERT INTO Booking (
        id_client, number_room, date_reservation, date_check_in, date_check_out, status_booking, total_price
    ) VALUES (
        v_id_client, p_room_number, CURRENT_DATE, p_date_check_in, p_date_check_out, 'reservat', v_total_price
    );

    COMMIT;
    SELECT 'Booking successfully created.' AS Message, v_total_price AS TotalPrice, v_days AS NightsCount;
END;
```

### ▶️ Example Call
```sql
CALL AddBooking('MD123456', 'A101', '2025-10-10', '2025-10-15');
```

---

## 🧳 CheckInClient
Marks the client as checked-in and updates room status to “occupied”.

```sql
CALL CheckInClient('MD123456', 'A101');
```

---

## 🔧 Maintenance Procedures
Three procedures manage room maintenance: **Add**, **Update**, and **Delete** records.

### 🧩 AddMaintenance
```sql
CALL AddMaintenance('101', '2025-10-01', NULL, 'Ventilation check');
```

### ✏️ UpdateMaintenance
```sql
CALL UpdateMaintenance(5, '102', '2025-10-05', NULL, 'Lamp replacement');
```

### ❌ DeleteMaintenance
```sql
CALL DeleteMaintenance(5);
```

---

## 🧾 Booking Service Management
These procedures manage services attached to active bookings (e.g., Breakfast, SPA, Transfer).

### ➕ AddBookingService
```sql
CALL AddBookingService('A101', 'Breakfast', 2);
```

### ✏️ UpdateBookingService
```sql
CALL UpdateBookingService('A101', 'Breakfast', 3);
```

### ❌ DeleteBookingService
```sql
CALL DeleteBookingService('A101', 'Breakfast');
```

---

## 🧠 Summary
| Procedure | Description |
|------------|-------------|
| `AddClient` | Adds a new client with validation |
| `AddStaff` | Registers new staff member |
| `AddBooking` | Creates a room booking |
| `CheckInClient` | Marks client as checked-in |
| `AddMaintenance` | Adds a maintenance record |
| `UpdateMaintenance` | Updates maintenance info |
| `DeleteMaintenance` | Removes maintenance record |
| `AddBookingService` | Adds extra service to booking |
| `UpdateBookingService` | Updates service quantity |
| `DeleteBookingService` | Removes service from booking |

---

## 🧩 Integration Tip
These stored procedures are ready for integration with any **C#**, **Java**,front-end via parameterized queries.  
Each includes built-in **error handling**, **rollback logic**, and **transaction management** ensuring data consistency.

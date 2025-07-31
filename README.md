# 🏨 Hotel Management Database — Performance & Query Enhancements

## 🔧 What's New in This Commit

This update focuses on **database optimization** and the addition of **useful SQL queries and views** that reflect real-world hotel operations.

---

## 🚀 Index Optimization

To speed up read operations and improve the overall performance of the database, several indexes were added:


### 👤 Clients Table
- `document_number` — used for quick lookups by passport or ID.
- `phone` — helps find clients by phone number efficiently  

```sql
CREATE INDEX idx_clients_document_number ON Clients(document_number);
CREATE INDEX idx_clients_phone ON Clients(phone);
```

---

### 🛏️ Room Table

- `status_room` — fast filtering for availability (free, reserved, maintenance).

- `comfort_level` — helps search for room types (standard, deluxe, suite).

- `Composite index: comfort_level + status_room` — improves queries filtering both.

- `price_room` — useful for sorting and filtering by price.

```sql
CREATE INDEX idx_room_status ON Room(status_room);
CREATE INDEX idx_room_comfort ON Room(comfort_level);
CREATE INDEX idx_room_comfort_status ON Room(comfort_level, status_room);
CREATE INDEX idx_room_price ON Room(price_room);
```

---

### 👨‍💼 Staff Table

- `job_title` — improves queries by position (e.g. cleaners, receptionists).

```sql
CREATE INDEX idx_staff_job ON Staff(job_title);
```

---

### 📅 Booking Table

- `id_client` — boosts join performance and filtering by client.

```sql
CREATE INDEX idx_boking_id_client ON Booking(id_client);
```

---

### 📊 SQL Queries
Below are practical and efficient queries reflecting hotel operations.

### 🟩 Room Availability

```sql
SELECT r.number_room  
FROM Room r
WHERE r.status_room = 'free';
```

➡️ Find all currently available rooms.

---

### 🧾 Active Reservations with Client Info

```sql
SELECT c.last_name, c.first_name, c.middle_name, r.number_room, b.date_check_in, b.date_check_out
FROM booking b
JOIN room r ON b.number_room = r.number_room
JOIN clients c ON b.id_client = c.id_client
WHERE b.status_booking = 'reservat';
``` 
➡️ Useful at reception to view all reserved rooms with check-in/out dates.

---

### 🧑‍🤝‍🧑 Client Activity & Booking Stats
#### Last Booking Per Client
```sql
SELECT c.last_name, c.first_name, c.middle_name, MAX(b.date_reservation) AS last_booking_date
FROM clients c
LEFT JOIN booking b ON c.id_client = b.id_client
GROUP BY c.id_client;
``` 
--- 

#### Total Number of Bookings per Client

```sql
SELECT c.last_name, c.first_name, c.middle_name, COUNT(*) AS count_booking
FROM booking b
JOIN clients c ON c.id_client = b.id_client
GROUP BY c.id_client;
```
---


### 💰 Services and Charges Breakdown
#### Services Used in Specific Booking
```sql
SELECT 
c.last_name,
 c.first_name, 
 c.middle_name,
r.number_room, 
s.name_services,
bs.quantity,
s.price_services, (s.price_services * bs.quantity) AS total_summ
FROM booking b
JOIN clients c ON b.id_client = c.id_client
JOIN room r ON b.number_room = r.number_room
JOIN booking_services bs ON b.id_booking = bs.id_booking
JOIN servicess s ON bs.id_services = s.id_services
WHERE b.id_booking = 1;
```

---

#### Most Popular Services
```sql
SELECT s.name_services, SUM(bs.quantity) AS total_quantity
FROM servicess s
JOIN booking_services bs ON s.id_services = bs.id_services
GROUP BY s.id_services
ORDER BY total_quantity DESC
LIMIT 5;
```

---

### 🏨 Room Usage and Maintenance
#### Booked Suites
```sql
SELECT c.last_name, c.first_name, c.middle_name, r.number_room, b.date_check_in, r.comfort_level
FROM booking b
JOIN clients c ON b.id_client = c.id_client
JOIN room r ON b.number_room = r.number_room
WHERE r.comfort_level = 'suite';
```

---

#### Maintenance + Free Room Insights (with last bookings)
```sql
SELECT r.number_room, r.status_room, MAX(b.date_reservation) AS date_last_booking, MAX(m.end_date) AS date_last_maintenance
FROM room r
LEFT JOIN booking b ON r.number_room = b.number_room
LEFT JOIN maintenance m ON r.number_room = m.number_room
WHERE r.status_room = 'maintenance'
GROUP BY r.number_room

UNION

SELECT r.number_room, r.status_room, MAX(b.date_reservation), NULL
FROM room r
JOIN booking b ON r.number_room = b.number_room
WHERE r.status_room = 'free'
GROUP BY r.number_room;
```
---

### 🥇 VIP Clients and Room Stats
#### Client with Highest Booking Price
```sql
SELECT c.last_name, c.first_name, c.middle_name, b.total_price
FROM clients c
JOIN booking b ON c.id_client = b.id_client
WHERE b.total_price = (
    SELECT MAX(b.total_price) FROM booking b
);
```

---

#### Rooms Without Bookings in Last 30 Days
```sql
SELECT r.number_room, r.status_room
FROM room r
LEFT JOIN booking b ON r.number_room = b.number_room
  AND b.date_reservation >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
WHERE b.id_booking IS NULL;
```
---

#### Most Expensive Service Per Category
```sql
SELECT s1.name_services, s1.price_services, s1.description_services
FROM servicess s1
WHERE s1.price_services = (
    SELECT MAX(s2.price_services)
    FROM servicess s2
    WHERE s2.description_services = s1.description_services
)
ORDER BY s1.description_services;
```

---

#### Clients with More Than 3 Bookings
```sql
SELECT c.last_name, c.first_name, c.middle_name
FROM clients c 
JOIN booking b ON c.id_client = b.id_client
GROUP BY c.id_client
HAVING COUNT(b.id_booking) > 3;
```

---

### 💳 Payments & Room Popularity

#### Total Revenue by Payment Type
```sql
SELECT p.payment_type, SUM(p.amount) AS total_for_group
FROM Payments p
GROUP BY p.payment_type;
```
--- 

#### Most Frequently Booked Rooms
```sql
SELECT r.number_room, COUNT(b.id_booking) AS total_booking
FROM room r
JOIN booking b ON r.number_room = b.number_room
GROUP BY r.number_room
ORDER BY total_booking DESC;
```
---
### 👁️ Views for Reuse and Simplification
--- 

### 🔍 view_active_bookings

#### Shows all currently active bookings.

```sql
CREATE VIEW view_active_bookings AS
SELECT 
    b.id_booking,
    c.last_name,
    c.first_name,
    c.middle_name,
    r.number_room,
    b.date_check_in,
    b.date_check_out,
    b.status_booking,
    b.total_price
FROM booking b
JOIN clients c ON b.id_client = c.id_client
JOIN room r ON b.number_room = r.number_room
WHERE b.status_booking = 'checked-in' OR b.status_booking = 'reservat';
```
---

### 📖 view_client_history
--- 
#### Displays each client’s full history of room bookings and services used.

```sql
CREATE VIEW view_client_history AS
SELECT 
    b.id_booking,
    b.id_client,
    r.number_room,
    r.comfort_level,
    b.date_reservation,
    b.total_price,
    GROUP_CONCAT(s.name_services SEPARATOR ', ') AS services_used
FROM booking b
JOIN room r ON b.number_room = r.number_room
LEFT JOIN booking_services bs ON b.id_booking = bs.id_booking
LEFT JOIN servicess s ON bs.id_services = s.id_services
GROUP BY b.id_booking, b.id_client, r.number_room, r.comfort_level, b.date_reservation, b.total_price;
```

### 📌 Summary
This commit introduces:

- `Indexes for better performance`

- `Advanced SQL queries to extract insights and operate the hotel effectively`

- `Views to simplify frequent reporting and improve maintainability`

All enhancements were made with performance, clarity, and real-life hotel management needs in mind.
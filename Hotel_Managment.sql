CREATE DATABASE HOTEL_MANAGMENT;

USE HOTEL_MANAGMENT;

CREATE TABLE Clients (
    id_client INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
	birth_date DATE NOT NULL,
	gender ENUM('M', 'F') NOT NULL,
	citizenship VARCHAR(100) NOT NULL,
	document_type VARCHAR(50) NOT NULL,
	document_number VARCHAR(50) NOT NULL,
    document_issued_by VARCHAR(150),
	document_issue_date DATE,
	address TEXT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('guest', 'staff', 'admin') NOT NULL,
    last_login DATETIME
);

CREATE TABLE Room (
    number_room VARCHAR(10) PRIMARY KEY,
    price_room DECIMAL(10,2) NOT NULL,
    capacity SMALLINT NOT NULL,
	status_room ENUM('free', 'occupied', 'maintenance') NOT NULL,
    comfort_level ENUM('standard', 'deluxe', 'suite') NOT NULL
);

CREATE TABLE Servicess (
    id_services SMALLINT PRIMARY KEY,
    name_services VARCHAR(255) NOT NULL,
    description_services TEXT,
    price_services DECIMAL(10,2) NOT NULL
);

CREATE TABLE Staff (
	id_Staff INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	last_name_staff VARCHAR(100) NOT NULL,
	first_name_staff VARCHAR(100) NOT NULL,
    middle_name_staff VARCHAR(100),
    job_title ENUM('admin', 'receptionist', 'cleaner', 'manager') DEFAULT 'receptionist',
 	phone VARCHAR(20) NOT NULL,
	home_address TEXT NOT NULL,
    login VARCHAR(100) UNIQUE NOT NULL,
	password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE Booking (
    id_booking INT PRIMARY KEY,
    id_client INT NOT NULL,
	number_room VARCHAR(10) NOT NULL,
    date_reservation DATE NOT NULL,
    date_check_in DATE NOT NULL,
    date_check_out DATE NOT NULL,
    status_booking ENUM ('reservat','canceled','completed') NOT NULL DEFAULT 'reservat',
    total_price DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT fk_id_client  
			FOREIGN KEY (id_client) REFERENCES Clients(id_client),
            
	CONSTRAINT fk_number_room 
			FOREIGN KEY (number_room) REFERENCES Room(number_room)
);

    
CREATE TABLE Booking_services (
	id_booking INT NOT NULL,
    id_services SMALLINT NOT NULL,
    quantity  SMALLINT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (id_booking, id_services),
    
	CONSTRAINT fk_id_booking 
		FOREIGN KEY (id_booking) REFERENCES Booking(id_booking),
        
	CONSTRAINT fk_id_services
		FOREIGN KEY (id_services) REFERENCES Servicess(id_services)
);

CREATE TABLE Payments (
    id_payment INT AUTO_INCREMENT PRIMARY KEY,
    id_booking INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_type ENUM('cash', 'card') NOT NULL,
    status ENUM('paid', 'unpaid') DEFAULT 'paid',

   CONSTRAINT fk_id_booking_payments
		FOREIGN KEY (id_booking) REFERENCES Booking(id_booking)
);

CREATE TABLE Maintenance (
    id_maintenance INT AUTO_INCREMENT PRIMARY KEY,
    number_room VARCHAR(10) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    reason TEXT,
    
    CONSTRAINT fk_number_room_maintenance
			FOREIGN KEY (number_room) REFERENCES Room(number_room)
);

CREATE TABLE logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action TEXT NOT NULL,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    
    CONSTRAINT fk_user_id
		FOREIGN KEY (user_id) REFERENCES users(id_user)
);


CREATE INDEX idx_clients_document_number ON Clients(document_number);
CREATE INDEX idx_clients_phone ON Clients(phone);

CREATE INDEX idx_room_status ON Room(status_room);                 
CREATE INDEX idx_room_comfort ON Room(comfort_level);
CREATE INDEX idx_room_comfort_status ON Room(comfort_level, status_room);              
CREATE INDEX idx_room_price ON Room(price_room); 

CREATE INDEX idx_staff_job ON Staff(job_title);                 

CREATE INDEX idx_boking_id_client ON Booking(id_client);

SELECT r.number_room  
FROM Room r
WHERE r.status_room = 'free';


SELECT c.last_name, c.first_name, c.middle_name, r.number_room, b.date_check_in, b.date_check_out
FROM booking b 
INNER JOIN 
	room r ON b.number_room = r.number_room 
INNER JOIN 
	clients c ON b.id_client = c.id_client 
WHERE b.status_booking = 'reservat';



SELECT c.last_name, c.first_name, c.middle_name,MAX(b.date_reservation) AS last_booking_date
FROM 
    clients c
LEFT JOIN 
 booking b ON c.id_client = b.id_client
GROUP BY
 c.id_client, c.last_name, c.first_name, c.middle_name;
    

SELECT c.last_name, c.first_name, c.middle_name,COUNT(*) AS count_booking
FROM
	booking b
INNER JOIN 
	clients c ON c.id_client = b.id_client
GROUP BY 
	 c.id_client;
     

	SELECT c.last_name, c.first_name, c.middle_name,r.number_room,s.name_services,bs.quantity,s.price_services,(s.price_services*bs.quantity) AS total_summ
	FROM booking b 
	INNER JOIN
		clients c ON b.id_client = c.id_client
    INNER JOIN
		room r ON b.number_room = r.number_room
	INNER JOIN
		booking_services bs ON b.id_booking = bs.id_booking
	INNER JOIN
		servicess s ON bs.id_services = s.id_services
	WHERE b.id_booking = 1;
    

SELECT s.name_services,SUM(bs.quantity) AS total_quantity
FROM servicess s
INNER JOIN
	booking_services bs ON s.id_services = bs.id_services
GROUP BY 
	 s.id_services
ORDER BY 
	total_quantity DESC
LIMIT 5;


	/*1- задание*/
	SELECT c.last_name, c.first_name, c.middle_name,r.number_room,b.date_check_in,r.comfort_level
	FROM booking b
	INNER JOIN 
		clients c ON b.id_client = c.id_client
	INNER JOIN 
		room r ON b.number_room = r.number_room
	WHERE 
		r.comfort_level = 'suite';
		
	/*2- задание*/  
	SELECT 
		r.number_room,
		r.status_room,
		MAX(b.date_reservation) AS date_last_booking,
		MAX(m.end_date) AS date_last_maintenance
	FROM 
		room r
	LEFT JOIN 
		booking b ON r.number_room = b.number_room
	LEFT JOIN 
		maintenance m ON r.number_room = m.number_room
	WHERE 
		r.status_room = 'maintenance'
	GROUP BY 
		r.number_room, r.status_room

	UNION

	SELECT 
		r.number_room,
		r.status_room,
		MAX(b.date_reservation) AS date_last_booking,
		NULL AS date_last_maintenance
	FROM 
		room r
	JOIN 
		booking b ON r.number_room = b.number_room
	WHERE 
		r.status_room = 'free'
	GROUP BY 
		r.number_room, r.status_room;
		
	/*4- задание*/
	SELECT c.last_name, c.first_name, c.middle_name,b.total_price
	FROM clients c
	INNER JOIN booking b ON c.id_client = b.id_client
	WHERE b.total_price = (
		SELECT MAX(b.total_price)
		FROM booking b
	);

	/*5- задание*/
	SELECT 
		r.number_room,
		r.status_room
	FROM 
		room r
	LEFT JOIN 
		booking b ON r.number_room = b.number_room
		AND b.date_reservation >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
	WHERE 
		b.id_booking IS NULL;
		
	/*6- задание*/
	SELECT 
		s1.name_services,
		s1.price_services,
		s1.description_services
	FROM 
		servicess s1
	WHERE 
		s1.price_services = (
			SELECT MAX(s2.price_services)
			FROM servicess s2
			WHERE s2.description_services = s1.description_services
		)
	ORDER BY 
		s1.description_services;
		
	/*7- задание*/
	SELECT c.last_name, c.first_name, c.middle_name
	FROM clients c 
	INNER JOIN booking b ON c.id_client = b.id_client
	GROUP BY c.id_client
	HAVING COUNT(b.id_booking)>3;

	/*8- задание*/
	SELECT p.payment_type,SUM(p.amount) AS total_for_group
	FROM Payments p
	GROUP BY p.payment_type;


	/*9- задание*/
	SELECT  r.number_room,COUNT(b.id_booking) AS total_booking
	FROM room r
	INNER JOIN 
		booking b ON r.number_room = b.number_room
	GROUP BY
		r.number_room
	ORDER BY total_booking 
		DESC;

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

SELECT * FROM view_active_bookings;

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

SELECT * FROM view_client_history WHERE id_client = 1;


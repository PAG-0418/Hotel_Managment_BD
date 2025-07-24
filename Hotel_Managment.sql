CREATE DATABASE HOTEL_MANAGER;

USE HOTEL_MANAGER;

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
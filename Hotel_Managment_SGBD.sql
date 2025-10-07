USE HOTEL_MANAGMENT;

drop procedure AddClient;

DELIMITER //
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

    SELECT COUNT(*) INTO v_document_exists
    FROM Clients WHERE document_number = p_document_number;

    IF v_document_exists > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Client with this document already exists';
    END IF;

    SELECT COUNT(*) INTO v_phone_exists
    FROM Clients WHERE phone = p_phone;

    IF v_phone_exists > 0 THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Client with this phone already exists';
    END IF;

    SELECT COUNT(*) INTO v_email_exists
    FROM Clients WHERE email = p_email;

    IF v_email_exists > 0 THEN
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Client with this email already exists';
    END IF;

    INSERT INTO Clients (
        last_name, first_name, middle_name, birth_date, gender, citizenship,
        document_type, document_number, document_issued_by, document_issue_date,
        address, phone, email
    )
    VALUES (
        p_last_name, p_first_name, p_middle_name, p_birth_date, p_gender, p_citizenship,
        p_document_type, p_document_number, p_document_issued_by, p_document_issue_date,
        p_address, p_phone, p_email
    );

    COMMIT;
    SELECT 'Client successfully added.' AS Message;
END //
DELIMITER ;

DELIMITER //
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

    SELECT COUNT(*) INTO v_phone_exists
    FROM Staff
    WHERE phone = p_phone;

    IF v_phone_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Staff member with this phone already exists';
    END IF;

    SELECT COUNT(*) INTO v_login_exists
    FROM Staff
    WHERE login = p_login;

    IF v_login_exists > 0 THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Staff member with this login already exists';
    END IF;

    INSERT INTO Staff (
        last_name_staff, first_name_staff, middle_name_staff, 
        job_title, phone, home_address, login, password_hash
    )
    VALUES (
        p_last_name_staff, p_first_name_staff, p_middle_name_staff, 
        p_job_title, p_phone, p_home_address, p_login, p_password_hash
    );

    COMMIT;
    SELECT 'Staff member successfully added.' AS Message;
END //
DELIMITER ;

DELIMITER //
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
    SELECT id_client INTO v_id_client
    FROM Clients
    WHERE document_number = p_document_number
    LIMIT 1;

    IF v_id_client IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Client with this document number was not found.';
    END IF;

    SELECT status_room, price_room INTO v_room_status, v_room_price
    FROM Room
    WHERE number_room = p_room_number;

    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Room not found.';
    END IF;

    IF v_room_status <> 'free' THEN
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Room is not available for booking.';
    END IF;

    SET v_days = DATEDIFF(p_date_check_out, p_date_check_in);
    SET v_total_price = v_days * v_room_price;

    INSERT INTO Booking (
        id_client, number_room, date_reservation,
        date_check_in, date_check_out, status_booking, total_price
    )
    VALUES (
        v_id_client, p_room_number, CURRENT_DATE,
        p_date_check_in, p_date_check_out, 'reservat', v_total_price
    );

    COMMIT;

    SELECT 
        'Booking successfully created.' AS Message,
        v_total_price AS TotalPrice,
        v_days AS NightsCount;

END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CheckInClient (
    IN p_document_number VARCHAR(20),   
    IN p_room_number VARCHAR(10)      
)
BEGIN
    DECLARE v_id_client INT;
    DECLARE v_booking_id INT;
    DECLARE v_status ENUM('reservat','canceled','completed');

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred during check-in process.' AS ErrorMessage;
    END;

    START TRANSACTION;

    SELECT id_client INTO v_id_client
    FROM Clients
    WHERE document_number = p_document_number
    LIMIT 1;

    IF v_id_client IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Client with this document number was not found.';
    END IF;

    SELECT id_booking, status_booking INTO v_booking_id, v_status
    FROM Booking
    WHERE id_client = v_id_client
      AND number_room = p_room_number
      AND CURRENT_DATE BETWEEN date_check_in AND date_check_out
      AND status_booking = 'reservat'
    LIMIT 1;

    IF v_booking_id IS NULL THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'No active reservation found for today.';
    END IF;

    UPDATE Booking
    SET status_booking = 'completed'
    WHERE id_booking = v_booking_id;

    UPDATE Room
    SET status_room = 'occupied'
    WHERE number_room = p_room_number;

    COMMIT;

    SELECT 'Client successfully checked in.' AS Message;

END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddMaintenance(
    IN p_number_room VARCHAR(10),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_reason TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while adding maintenance record.' AS ErrorMessage;
    END;

    START TRANSACTION;

    INSERT INTO maintenance (number_room, start_date, end_date, reason)
    VALUES (p_number_room, p_start_date, p_end_date, p_reason);

    COMMIT;
    SELECT 'Maintenance record successfully added.' AS Message;
END //
DELIMITER ;

CALL AddMaintenance('101', '2025-10-01', NULL, 'Проверка вентиляции');

DELIMITER //
CREATE PROCEDURE DeleteMaintenance(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while deleting maintenance record.' AS ErrorMessage;
    END;

    START TRANSACTION;

    DELETE FROM maintenance
    WHERE id_maintenance = p_id;

    COMMIT;
    SELECT 'Maintenance record successfully deleted.' AS Message;
END //
DELIMITER ;

CALL DeleteMaintenance(5);

DELIMITER //
CREATE PROCEDURE UpdateMaintenance(
    IN p_id INT,
    IN p_number_room VARCHAR(10),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_reason TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while updating maintenance record.' AS ErrorMessage;
    END;

    START TRANSACTION;

    UPDATE maintenance
    SET
        number_room = COALESCE(p_number_room, number_room),
        start_date  = COALESCE(p_start_date, start_date),
        end_date    = COALESCE(p_end_date, end_date),
        reason      = COALESCE(p_reason, reason)
    WHERE id_maintenance = p_id;

    COMMIT;
    SELECT 'Maintenance record successfully updated.' AS Message;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddBookingService (
    IN p_number_room VARCHAR(10),
    IN p_service_name VARCHAR(255),
    IN p_quantity SMALLINT
)
BEGIN
    DECLARE v_id_booking INT;
    DECLARE v_id_service SMALLINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while adding service to booking.' AS ErrorMessage;
    END;

    START TRANSACTION;

    SELECT id_booking INTO v_id_booking
    FROM Booking
    WHERE number_room = p_number_room
      AND status_booking IN ('reservat','completed')
    ORDER BY date_reservation DESC
    LIMIT 1;

    IF v_id_booking IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Active booking for this room not found.';
    END IF;

    SELECT id_services INTO v_id_service
    FROM Servicess
    WHERE name_services = p_service_name
    LIMIT 1;

    IF v_id_service IS NULL THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Service not found.';
    END IF;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Quantity must be greater than 0.';
    END IF;

    INSERT INTO Booking_services (id_booking, id_services, quantity)
    VALUES (v_id_booking, v_id_service, p_quantity);

    COMMIT;

    SELECT 'Service successfully added to booking.' AS Message;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateBookingService (
    IN p_number_room VARCHAR(10),
    IN p_service_name VARCHAR(255),
    IN p_new_quantity SMALLINT
)
BEGIN
    DECLARE v_id_booking INT;
    DECLARE v_id_service SMALLINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while updating service quantity.' AS ErrorMessage;
    END;

    START TRANSACTION;
    
    SELECT id_booking INTO v_id_booking
    FROM Booking
    WHERE number_room = p_number_room
      AND status_booking IN ('reservat','completed')
    ORDER BY date_reservation DESC
    LIMIT 1;

    IF v_id_booking IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Active booking for this room not found.';
    END IF;

    SELECT id_services INTO v_id_service
    FROM Servicess
    WHERE name_services = p_service_name
    LIMIT 1;

    IF v_id_service IS NULL THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Service not found.';
    END IF;

    IF p_new_quantity <= 0 THEN
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Quantity must be greater than 0.';
    END IF;

    UPDATE Booking_services
    SET quantity = p_new_quantity
    WHERE id_booking = v_id_booking
      AND id_services = v_id_service;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45003'
        SET MESSAGE_TEXT = 'This service is not linked to the booking.';
    END IF;

    COMMIT;

    SELECT 'Service quantity successfully updated.' AS Message;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE DeleteBookingService (
    IN p_number_room VARCHAR(10),
    IN p_service_name VARCHAR(255)
)
BEGIN
    DECLARE v_id_booking INT;
    DECLARE v_id_service SMALLINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while deleting service from booking.' AS ErrorMessage;
    END;

    START TRANSACTION;

    SELECT id_booking INTO v_id_booking
    FROM Booking
    WHERE number_room = p_number_room
      AND status_booking IN ('reservat','completed')
    ORDER BY date_reservation DESC
    LIMIT 1;

    IF v_id_booking IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Active booking for this room not found.';
    END IF;

    SELECT id_services INTO v_id_service
    FROM Servicess
    WHERE name_services = p_service_name
    LIMIT 1;

    IF v_id_service IS NULL THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Service not found.';
    END IF;

    DELETE FROM Booking_services
    WHERE id_booking = v_id_booking
      AND id_services = v_id_service;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'This service is not linked to the booking.';
    END IF;

    COMMIT;

    SELECT 'Service successfully deleted from booking.' AS Message;
END //
DELIMITER ;

CALL AddBookingService('A101', 'Breakfast', 2);

CALL UpdateBookingService('A101', 'Breakfast', 3);

CALL DeleteBookingService('A101', 'Breakfast');


CALL UpdateMaintenance(5, NULL, NULL, '2025-10-10', NULL);

CALL UpdateMaintenance(5, NULL, NULL, NULL, 'Замена лампы');

CALL UpdateMaintenance(5, '102', '2025-10-05', NULL, NULL);


CALL AddClient(
    'Ivanov',           -- last_name
    'Ivan',             -- first_name  
    'Ivanovich',        -- middle_name
    '1990-05-15',       -- birth_date
    'M',                -- gender
    'Russian',          -- citizenship
    'Passport',         -- document_type
    '4510123456',       -- document_number
    'MVD Russia',       -- document_issued_by
    '2015-06-20',       -- document_issue_date
    'Moscow, Lenina st. 25, kv. 10', -- address
    '+79161234569',     -- phone
    'ivanovv@mail.ru'    -- email
);

CALL AddStaff(
    'Popescu',
    'Ion',
    'Vasile',
    'manager',
    '+37360111222',
    'Chisinau, Stefan cel Mare 123',
    'ion.popescu',
    'StrongPass123'
);

CALL AddBooking(
    'MD123456',   
    'A101',       
    '2025-10-10', 
    '2025-10-15'
);

CALL CheckInClient(
    'MD123456',   
    'A101'       
);





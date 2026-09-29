USE SMARTCAMPUS;

-- ============================================================
-- TRANSACTION-SAFE BOOKING PROCEDURE
-- Validates user, resource, slot and availability.
-- FOR UPDATE locks the resource row until COMMIT/ROLLBACK.
-- Any SQL exception automatically rolls back the transaction.
-- ============================================================

DROP PROCEDURE IF EXISTS CREATE_BOOKING_TRANSACTION;

DELIMITER $$

CREATE PROCEDURE CREATE_BOOKING_TRANSACTION(
    IN p_UserId INT,
    IN p_ResourceId INT,
    IN p_SlotId INT,
    IN p_BookingDate DATE,
    IN p_Purpose VARCHAR(255)
)
BEGIN
    DECLARE v_user_count INT DEFAULT 0;
    DECLARE v_resource_count INT DEFAULT 0;
    DECLARE v_slot_count INT DEFAULT 0;
    DECLARE v_resource_status VARCHAR(30);
    DECLARE v_booking_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_user_count
    FROM USERS
    WHERE UserId=p_UserId AND Status='Active';

    IF v_user_count=0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Invalid or inactive user';
    END IF;

    SELECT Status INTO v_resource_status
    FROM RESOURCES
    WHERE ResourceId=p_ResourceId
    FOR UPDATE;

    IF v_resource_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Resource does not exist';
    END IF;

    IF v_resource_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Resource is not available';
    END IF;

    SELECT COUNT(*) INTO v_slot_count
    FROM TIME_SLOT
    WHERE SlotId=p_SlotId;

    IF v_slot_count=0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Invalid time slot';
    END IF;

    SELECT COUNT(*) INTO v_booking_count
    FROM BOOKINGS
    WHERE ResourceId=p_ResourceId
      AND SlotId=p_SlotId
      AND BookingDate=p_BookingDate
      AND Status IN ('Pending','Confirmed');

    IF v_booking_count>0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Resource already booked for this slot and date';
    END IF;

    INSERT INTO BOOKINGS
    (UserId,ResourceId,SlotId,BookingDate,Purpose,Status)
    VALUES
    (p_UserId,p_ResourceId,p_SlotId,p_BookingDate,p_Purpose,'Confirmed');

    COMMIT;

    SELECT LAST_INSERT_ID() AS BookingId,
           'Booking committed successfully' AS Message;
END$$

DELIMITER ;


-- ============================================================
-- CANCELLATION TRANSACTION
-- ============================================================

DROP PROCEDURE IF EXISTS CANCEL_BOOKING_TRANSACTION;

DELIMITER $$

CREATE PROCEDURE CANCEL_BOOKING_TRANSACTION(IN p_BookingId INT)
BEGIN
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT Status INTO v_status
    FROM BOOKINGS
    WHERE BookingId=p_BookingId
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Booking does not exist';
    END IF;

    IF v_status='Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Booking is already cancelled';
    END IF;

    UPDATE BOOKINGS
    SET Status='Cancelled'
    WHERE BookingId=p_BookingId;

    COMMIT;

    SELECT p_BookingId AS BookingId,
           'Booking cancelled successfully' AS Message;
END$$

DELIMITER ;


-- ============================================================
-- TRANSACTION TEST 1: SUCCESS / COMMIT
-- ============================================================

SELECT * FROM BOOKINGS;

CALL CREATE_BOOKING_TRANSACTION(
    2403140,
    1,
    1,
    '2026-10-01',
    'DBMS Practical'
);

SELECT * FROM BOOKINGS;


-- ============================================================
-- TRANSACTION TEST 2: MANUAL ROLLBACK
-- ============================================================

START TRANSACTION;

INSERT INTO BOOKINGS
(UserId,ResourceId,SlotId,BookingDate,Purpose,Status)
VALUES
(2403142,1,2,'2026-10-02',
 'Rollback Demonstration','Confirmed');

SELECT * FROM BOOKINGS;

ROLLBACK;

SELECT * FROM BOOKINGS;


-- ============================================================
-- TRANSACTION TEST 3: CANCELLATION
-- ============================================================

CALL CANCEL_BOOKING_TRANSACTION(1);

SELECT * FROM BOOKINGS;
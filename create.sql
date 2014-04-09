CREATE TABLE City (
    city VARCHAR(64) PRIMARY KEY
);


CREATE TABLE Branch (
    branch_code VARCHAR(64) PRIMARY KEY,
    city VARCHAR(64),
    location VARCHAR(255),
    FOREIGN KEY (city) REFERENCES City(city) ON UPDATE CASCADE
);


CREATE TABLE VehicleType (
    type VARCHAR(64) PRIMARY KEY,
    is_trunk BIT NOT NULL,
    feature TEXT
);


CREATE TABLE RentalRate (
    rate_id INT PRIMARY KEY IDENTITY(1,1),
    w_rate DECIMAL(10,2) NOT NULL CHECK(w_rate >= 0),
    d_rate DECIMAL(10,2) NOT NULL CHECK(d_rate >= 0),
    h_rate DECIMAL(10,2) NOT NULL CHECK(h_rate >= 0),
    CHECK (w_rate <= d_rate*24 AND d_rate <= h_rate*24),
    w_ins DECIMAL(10,2) NOT NULL CHECK(w_ins >= 0),
    d_ins DECIMAL(10,2) NOT NULL CHECK(d_ins >= 0),
    h_ins DECIMAL(10,2) NOT NULL CHECK(h_ins >= 0),
    CHECK (w_ins <= d_ins*24 AND d_ins <= h_ins*24)
);


CREATE TABLE Maintains (
    branch_code VARCHAR(64),
    type VARCHAR(64) NOT NULL,
    rate_id INT NOT NULL,
    PRIMARY KEY (branch_code, type),
    FOREIGN KEY (branch_code) REFERENCES Branch(branch_code)
            ON UPDATE CASCADE,
    FOREIGN KEY (type) REFERENCES VehicleType(type)
            ON UPDATE CASCADE,
    FOREIGN KEY (rate_id) REFERENCES RentalRate(rate_id)
            ON UPDATE CASCADE
);


CREATE TABLE Customer (
    phone VARCHAR(20) PRIMARY KEY,
    address VARCHAR(255),
    license_number VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    UNIQUE(license_number)
);


CREATE TABLE Member (
    phone VARCHAR(20) PRIMARY KEY,
    points INT NOT NULL DEFAULT 0 CHECK (points >= 0),
    fees DECIMAL(32,2) NOT NULL,
    valid_through DATE NOT NULL,
    FOREIGN KEY (phone) REFERENCES Customer(phone)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);


CREATE TABLE Agent (
    agent_name VARCHAR(64) PRIMARY KEY
);


CREATE TABLE Vehicle (
    vehicle_id INT PRIMARY KEY IDENTITY(1,1),
    branch_code VARCHAR(64) NOT NULL,
    type VARCHAR(64) NOT NULL,
    bought_date DATE,
    original_price DECIMAL(32,2) CHECK(original_price > 0),
    mileage INT CHECK(mileage >= 0),
    FOREIGN KEY (branch_code) REFERENCES Branch(branch_code)
);


CREATE TABLE VehicleForSale (
    vehicle_id INT PRIMARY KEY,
    added_date DATE DEFAULT GETDATE(),
    agent_name VARCHAR(64),
    phone VARCHAR(20),
    sold_date  DATE,
    sold_price DECIMAL(32,2) CHECK(sold_price > 0),
    point_used INT CHECK(point_used >= 0),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
            ON UPDATE CASCADE,
    FOREIGN KEY (agent_name) REFERENCES Agent(agent_name)
            ON UPDATE CASCADE,
    FOREIGN KEY (phone) REFERENCES Customer(phone)
            ON UPDATE CASCADE,
    CHECK(sold_date > added_date)
);


CREATE TABLE CreditCard (
    card_number VARCHAR(64) PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    expired_date DATE NOT NULL,
    FOREIGN KEY (phone) REFERENCES Customer(phone)
            ON UPDATE CASCADE
);


CREATE TABLE ReservationRecord (
    confirmation_number VARCHAR(64) PRIMARY KEY,
    branch_code VARCHAR(64) NOT NULL,
    type VARCHAR(64) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    expected_pick_up_time SMALLDATETIME NOT NULL,    
    expected_return_time SMALLDATETIME NOT NULL,
    is_insurance_covered BIT NOT NULL DEFAULT 1,
    estimated_charge DECIMAL(32, 2),
    canceled BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (branch_code) REFERENCES Branch(branch_code)
            ON UPDATE CASCADE,
    FOREIGN KEY (type) REFERENCES VehicleType(type)
            ON UPDATE CASCADE,
    FOREIGN KEY (phone) REFERENCES Customer(phone)
            ON UPDATE CASCADE,
    CHECK(expected_pick_up_time < expected_return_time)
);


CREATE TABLE RentRecord (
    rent_id BIGINT PRIMARY KEY IDENTITY(1,1),
    confirmation_number VARCHAR(64),
    phone VARCHAR(20),
    card_number VARCHAR(64),
    vehicle_id INT NOT NULL,
    rate_id INT,
    pick_up_time SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    expected_return_time SMALLDATETIME,
    actual_return_time SMALLDATETIME,
    odometer INT CHECK(odometer >= 0),
    is_tank_full BIT,
    point_used INT CHECK(point_used >= 0),
    point_earned INT CHECK(point_earned >= 0),
    is_insurance_covered BIT,
    charge DECIMAL(32, 2),
    FOREIGN KEY (confirmation_number)
            REFERENCES ReservationRecord(confirmation_number),
    FOREIGN KEY (phone) REFERENCES Customer(phone)
            ON UPDATE CASCADE,
    FOREIGN KEY (card_number) REFERENCES CreditCard(card_number),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
            ON UPDATE CASCADE,
    FOREIGN KEY (rate_id) REFERENCES RentalRate(rate_id)
            ON UPDATE CASCADE,
    CHECK(pick_up_time < expected_return_time),
    CHECK(pick_up_time < actual_return_time),
    CHECK(point_earned = FLOOR(charge/5))
);

GO


-- To make sure the added_date of a VehicleForSale record
-- is after the bought date of the vehicle.

CREATE TRIGGER CheckAddedDate
    ON VehicleForSale
 AFTER INSERT,UPDATE
AS 
BEGIN
    IF EXISTS (
        SELECT *
          FROM Vehicle 
          JOIN INSERTED
            ON Vehicle.vehicle_id = INSERTED.vehicle_id
         WHERE Vehicle.bought_date > INSERTED.added_date
        )
        ROLLBACK TRANSACTION;
END
GO

-- 奇怪的 View 们


CREATE VIEW ReservationView
AS
SELECT confirmation_number,
       expected_pick_up_time,
       expected_return_time,
       is_insurance_covered,
       estimated_charge,
       canceled,
       C.*,
       T.*,
       B.*
  FROM ReservationRecord RS
       JOIN Customer C
         ON RS.phone = C.phone
       JOIN VehicleType T
         ON T.type = RS.type
       JOIN Branch B
         ON B.branch_code = RS.branch_code
GO



-- Create reservation.
-- One reservation at a time.

CREATE TRIGGER CreateReservation
    ON ReservationView
    INSTEAD OF INSERT
AS
BEGIN
    -- No for-each-row implememtation in MS SQL server.
    -- We can achieve the same goal with cursor.
    -- But in this case it is rarely happen.
    -- So we only allow insert one row per statement.
    SET NOCOUNT ON;
    DECLARE @estimated_charge DECIMAL(32, 2)
    DECLARE @rate_id INT
    DECLARE @length INT
    -- get length
    SELECT @length = DATEDIFF(hour, expected_pick_up_time,
                              expected_return_time)
      FROM INSERTED
    -- get rate_id
    SELECT @rate_id = rate_id
      FROM Maintains, INSERTED
     WHERE Maintains.branch_code = INSERTED.branch_code
           AND Maintains.type = INSERTED.type
    SELECT @estimated_charge = d_rate * @length
      FROM RentalRate, INSERTED
     WHERE RentalRate.rate_id = @rate_id
    INSERT INTO ReservationRecord
        (
        confirmation_number,
        branch_code,
        type,
        phone,
        expected_pick_up_time,    
        expected_return_time,
        is_insurance_covered,
        estimated_charge
        )
        SELECT SUBSTRING(CONVERT(varchar(40), NEWID()),0,9),
               branch_code,
               type,
               phone,
               expected_pick_up_time,
               expected_return_time,
               is_insurance_covered,
               @estimated_charge
          FROM INSERTED

END
GO

CREATE VIEW RentView
AS
SELECT rent_id,
       confirmation_number,
       pick_up_time,
       expected_return_time,
       actual_return_time,
       odometer,
       is_tank_full,
       point_used,
       point_earned,
       is_insurance_covered,
       charge,
       C.*,
       RT.*,
       CC.card_number AS card_number,
       CC.expired_date AS expired_date,
       V.*
  FROM RentRecord RE
       JOIN Customer C
         ON RE.phone = C.phone
       JOIN RentalRate RT
         ON RT.rate_id = RE.rate_id
       JOIN CreditCard CC
         ON CC.card_number = RE.card_number
       JOIN Vehicle V
         ON V.vehicle_id = RE.vehicle_id
       JOIN Branch B
         ON B.branch_code = V.branch_code
         
GO


CREATE VIEW RentFromReservation
AS
SELECT REV.*,
       expected_pick_up_time,
       RS.expected_return_time AS expected_return_time_when_reserve
  FROM RentView REV,
       ReservationRecord RS
 WHERE REV.confirmation_number = RS.confirmation_number;
GO


-- They only need to provide
-- (confirmation_number, card_number, vehicle_id, expected_return_time?)
-- One rental at a time.

CREATE TRIGGER CreateRentFromReservation
    ON RentFromReservation
    INSTEAD OF INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @confirmation_number VARCHAR(64)
    DECLARE @phone VARCHAR(20)
    DECLARE @expected_return_time SMALLDATETIME
    DECLARE @rate_id INT
    DECLARE @branch_code VARCHAR(64)
    DECLARE @type VARCHAR(64)
    -- get reservation data
    if UPDATE (confirmation_number)
    BEGIN
        SELECT @phone                = phone,
               @confirmation_number  = confirmation_number,
               @expected_return_time = expected_return_time,
               @branch_code          = branch_code,
               @type                 = type
          FROM ReservationRecord RS
         WHERE RS.confirmation_number = (SELECT confirmation_number
                                           FROM INSERTED)
    END
    -- get rental rate
    SELECT @rate_id = rate_id
      FROM Maintains
     WHERE type = @type AND branch_code = @branch_code
    -- insert data
    INSERT INTO RentRecord
        (
        confirmation_number,
        phone,
        card_number,
        vehicle_id,
        rate_id,
        expected_return_time
        )
        SELECT confirmation_number,
               @phone,
               card_number,
               vehicle_id,
               @rate_id,
               @expected_return_time
          FROM INSERTED
END;
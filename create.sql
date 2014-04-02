CREATE TABLE City (
    city VARCHAR(64) PRIMARY KEY
);


CREATE TABLE Branch (
    branch_code VARCHAR(64) PRIMARY KEY,
    city VARCHAR(64) NOT NULL,
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
    points INT DEFAULT 0 CHECK (points >= 0),
    fees DECIMAL(32,2) NOT NULL,
    valid_through SMALLDATETIME NOT NULL,
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
    agent_name VARCHAR(64) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    added_date DATE DEFAULT GETDATE(),
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
    estimated_charge DECIMAL(32, 2),
    canceled BIT DEFAULT 0,
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
    phone VARCHAR(20) NOT NULL,
    card_number VARCHAR(64) NOT NULL,
    vehicle_id INT NOT NULL,
    rate_id INT NOT NULL,
    pick_up_time SMALLDATETIME NOT NULL,
    expected_return_time SMALLDATETIME NOT NULL,
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
    CHECK(pick_up_time < actual_return_time)
);
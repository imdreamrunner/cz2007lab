INSERT INTO City VALUES
    ('Singapore'),
    ('New York'),
    ('Los Angeles'),
    ('Chicago'),
    ('Houston');


INSERT INTO Branch VALUES
    ('sgp1', 'Singapore', '8 Nanyang Drive'),
    ('sgp2', 'Singapore', '41 Nanyang Walk');


INSERT INTO VehicleType (type, is_trunk) VALUES
    ('Economy', 0),
    ('Compact', 0),
    ('Mid-size', 0),
    ('Standard', 0),
    ('Full- size', 0),
    ('Premium', 0),
    ('Luxury', 0),
    ('SUV', 0),
    ('Van', 0),
    ('24-foot', 1),
    ('15-foot', 1),
    ('12-foot', 1),
    ('Box Trunk', 1),
    ('Cargo', 1);


INSERT INTO RentalRate (w_rate, d_rate, h_rate, w_ins, d_ins, h_ins) VALUES
    (70, 10, 1, 70, 10, 1),
    (140, 20, 2, 140, 20, 2),
    (210, 30, 4, 140, 20, 2);


INSERT INTO Maintains VALUES
    ('sgp1', 'Economy', 1),
    ('sgp1', 'Compact', 2),
    ('sgp1', '15-foot', 3);


INSERT INTO Customer VALUES
    ('12345678', 'Address1', 'L1234567', 'I Am Member'),
    ('23456789', 'Address2', 'L2345678', 'I Am NOT Member');


INSERT INTO Member VALUES
    ('12345678', 500, 20, '2018-04-02');


INSERT INTO Agent VALUES
    ('agent1'),
    ('agent2');


INSERT INTO Vehicle (branch_code, type, bought_date, original_price, mileage) VALUES
    ('sgp1', 'Economy', '2002-12-01', 5000, 256),
    ('sgp1', 'Economy', '2012-12-01', 8000, 256);


INSERT INTO VehicleForSale VALUES
    (1, 'agent1', '12345678', '2014-04-01', '2014-04-02', 2000, 200);


INSERT INTO CreditCard VALUES
    ('1234123412341234', '12345678', '2018-10-01');


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
    VALUES
    (
        '6423786782385',
        'sgp1',
        'Economy',
        '12345678',
        '2014-04-01 08:00',
        '2014-04-02 08:00',
        1,
        20
    );


INSERT INTO RentRecord
    (
        confirmation_number,
        phone,
        card_number,
        vehicle_id,
        rate_id,
        pick_up_time,
        expected_return_time,
        actual_return_time,
        odometer,
        is_tank_full,
        point_used,
        point_earned,
        is_insurance_covered,
        charge
    )
    VALUES
    (
        '6423786782385',
        '12345678',
        '1234123412341234',
        1,
        1,
        '2014-04-01 08:00',
        '2014-04-02 08:00',
        '2014-04-02 08:00',
        100,
        1,
        0,
        100,
        1,
        20
    );
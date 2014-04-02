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
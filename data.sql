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
    (140, 20, 2, 140, 20, 2);
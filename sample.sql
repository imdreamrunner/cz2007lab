-- test insert reservation

INSERT INTO ReservationView
(
    branch_code,
    type,
    phone,
    expected_pick_up_time,    
    expected_return_time,
    is_insurance_covered
)
VALUES
(
    'sgp1',
    'Economy',
    '12345678',
    '2014-1-1',
    '2014-1-9 10:00',
    1
)

-- make rent

INSERT INTO RentFromReservation
(confirmation_number, card_number, vehicle_id)
VALUES
('F811FD6E', '1234123412341234', 1)

-- return car

UPDATE RentRecord
   SET actual_return_time = GETDATE()
 WHERE confirmation_number = 'F811FD6E'
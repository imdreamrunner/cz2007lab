CREATE TRIGGER CheckSoldDate
BEFORE INSERT ON VehicleForSale
REFERENCING NEW ROW AS N
FOR EACH ROW
WHEN (SELECT bought_date FROM Vehicle V WHERE V.vehicle_id = N.vehicle_id)
      > N.sold_date
ROLLBACK;
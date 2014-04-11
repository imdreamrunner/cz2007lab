-- Q1

WITH RentOut
AS
(SELECT *
  FROM RentView
 WHERE pick_up_time BETWEEN '2001-1-1' AND '2020-1-1'
)
SELECT vehicle_id,
       branch_code,
       [type]
  FROM VehicleView
 WHERE vehicle_id IN (SELECT vehicle_id FROM RentOut)
 ORDER BY branch_code, [type];

WITH RentOut
AS
(SELECT *
  FROM RentView
 WHERE pick_up_time BETWEEN '2001-1-1' AND '2020-1-1'
)

SELECT branch_code,
       COUNT(*) AS Number
  FROM VehicleView
WHERE vehicle_id IN (SELECT vehicle_id FROM RentOut)
 GROUP BY branch_code
 ORDER BY branch_code;

WITH RentOut
AS
(SELECT *
  FROM RentView
 WHERE pick_up_time BETWEEN '2001-1-1' AND '2020-1-1'
)
SELECT branch_code, [type],
       COUNT(*) AS Number
  FROM VehicleView
 WHERE vehicle_id IN (SELECT vehicle_id FROM RentOut)
 GROUP BY branch_code, [type]
 ORDER BY branch_code, [type];

-- Q2

SELECT vehicle_id
  FROM VehicleForSale
 WHERE DATEDIFF(month, added_date, GETDATE())>3
   AND sold_date IS NULL

 -- Q3

  SELECT vehicle_id,
         branch_code,
         [type]
    FROM VehicleView
   WHERE DATEDIFF(year, bought_date, GETDATE()) >= 5
ORDER BY branch_code, [type];

 -- Q4

 SELECT name,
       points,
       city
  FROM MemberView, City
 WHERE phone IN (
    SELECT phone
      FROM RentView
     WHERE RentView.city = City.city
     GROUP BY phone
    HAVING SUM(point_used) >=
        ALL (SELECT SUM(point_used)
               FROM RentView
              WHERE RentView.city = City.city
              GROUP BY phone)
 );

 -- Q5

SELECT DISTINCT phone
           FROM Member
EXCEPT
SELECT DISTINCT phone
           FROM RentRecord
          WHERE pick_up_time BETWEEN '2014-04-11' AND '2014-05-01'
            AND point_used != 0

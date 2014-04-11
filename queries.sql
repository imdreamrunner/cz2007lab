-- Q1

SELECT vehicle_id,
       branch_code,
       [type]
  FROM VehicleView
 WHERE vehicle_id IN (SELECT vehicle_id FROM VehicleNotReturned)
 ORDER BY branch_code, [type];

SELECT branch_code,
       COUNT(*) AS Number
  FROM VehicleView
 WHERE vehicle_id IN (SELECT vehicle_id FROM VehicleNotReturned)
 GROUP BY branch_code
 ORDER BY branch_code, [type];
 
SELECT branch_code, [type],
       COUNT(*) AS Number
  FROM VehicleView
 WHERE vehicle_id IN (SELECT vehicle_id FROM VehicleNotReturned)
 GROUP BY branch_code, [type]
 ORDER BY branch_code, [type];

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
       branch_code
  FROM MemberView, Branch B
 WHERE phone = (
    SELECT phone
      FROM RentView REV
     WHERE B.branch_code = REV.branch_code
     GROUP BY phone
    HAVING SUM(point_used) >=
        ALL(SELECT COUNT(point_used)
        FROM RentView REV2
        WHERE B.branch_code = REV2.branch_code)
 );

 -- Q5
 SELECT name,
       points,
       branch_code
  FROM MemberView, Branch
 WHERE phone IN (
    SELECT phone
      FROM RentView
     WHERE RentView.branch_code = Branch.branch_code 
     GROUP BY phone, branch_code
    HAVING SUM(point_used) >=
        ALL (SELECT SUM(point_used)
               FROM RentView
              WHERE RentView.branch_code = Branch.branch_code 
              GROUP BY phone, branch_code)
 );
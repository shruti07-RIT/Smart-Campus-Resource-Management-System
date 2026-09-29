USE SMARTCAMPUS;

-- ============================================================
-- 1. NORMALIZATION VERIFICATION - 1NF
-- ============================================================

SELECT UserId, Password, Role, Status
FROM USERS;

SELECT ResourceId, ResourceName, DepartmentId,
       LocationId, TypeId, Capacity, Status
FROM RESOURCES;

SELECT BookingId, UserId, ResourceId, SlotId,
       BookingDate, Purpose, Status
FROM BOOKINGS;


-- ============================================================
-- 2. NORMALIZATION VERIFICATION - 2NF / PRIMARY KEYS
-- ============================================================

SELECT TABLE_NAME,
       COLUMN_NAME,
       CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'SMARTCAMPUS'
ORDER BY TABLE_NAME, COLUMN_NAME;


-- ============================================================
-- 3. NORMALIZATION VERIFICATION - 3NF / FOREIGN KEYS
-- ============================================================

SELECT TABLE_NAME,
       COLUMN_NAME,
       REFERENCED_TABLE_NAME,
       REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'SMARTCAMPUS'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;


-- ============================================================
-- 4. RESOURCE AVAILABILITY QUERY
-- ============================================================

SELECT R.ResourceId,
       R.ResourceName,
       R.Status
FROM RESOURCES R
WHERE R.ResourceId = 1
  AND R.Status = 'Available'
  AND NOT EXISTS (
      SELECT 1
      FROM BOOKINGS B
      WHERE B.ResourceId = R.ResourceId
        AND B.SlotId = 1
        AND B.BookingDate = '2026-09-27'
        AND B.Status IN ('Pending', 'Confirmed')
  );


-- ============================================================
-- 5. STUDENT BOOKING HISTORY
-- ============================================================

SELECT B.BookingId,
       R.ResourceName,
       B.BookingDate,
       TS.StartTime,
       TS.EndTime,
       B.Purpose,
       B.Status
FROM BOOKINGS B
JOIN RESOURCES R
    ON B.ResourceId = R.ResourceId
JOIN TIME_SLOT TS
    ON B.SlotId = TS.SlotId
WHERE B.UserId = 2403140
ORDER BY B.BookingDate, TS.StartTime;


-- ============================================================
-- 6. CAMPUS ROUTE QUERY
-- ============================================================

SELECT E.EdgeId,
       N1.NodeName AS FromLocation,
       N2.NodeName AS ToLocation,
       E.Distance,
       E.Latency,
       E.Capacity,
       E.Availability
FROM CAMPUS_EDGE E
JOIN CAMPUS_NODE N1
    ON E.FromNodeId = N1.NodeId
JOIN CAMPUS_NODE N2
    ON E.ToNodeId = N2.NodeId
WHERE E.FromNodeId = 'N4'
ORDER BY E.Distance;


-- ============================================================
-- 7. RESOURCE UTILIZATION REPORT
-- ============================================================

SELECT R.ResourceId,
       R.ResourceName,
       COUNT(B.BookingId) AS TotalBookings
FROM RESOURCES R
LEFT JOIN BOOKINGS B
    ON R.ResourceId = B.ResourceId
   AND B.Status = 'Confirmed'
GROUP BY R.ResourceId, R.ResourceName
ORDER BY TotalBookings DESC, R.ResourceId;


-- ============================================================
-- 8. DEPARTMENT-WISE RESOURCE REPORT
-- ============================================================

SELECT D.DepartmentId,
       D.DepartmentName,
       COUNT(R.ResourceId) AS TotalResources
FROM DEPARTMENT D
LEFT JOIN RESOURCES R
    ON D.DepartmentId = R.DepartmentId
GROUP BY D.DepartmentId, D.DepartmentName
ORDER BY D.DepartmentId;


-- ============================================================
-- 9. BOOKING-STATUS REPORT
-- ============================================================

SELECT Status,
       COUNT(*) AS TotalBookings
FROM BOOKINGS
GROUP BY Status
ORDER BY Status;


-- ============================================================
-- 10. BASIC DATABASE CHECKS
-- ============================================================

SHOW TABLES;

SELECT * FROM DEPARTMENT;

SELECT * FROM RESOURCE_TYPE;

SELECT * FROM LOCATION;

SELECT * FROM USERS;

SELECT * FROM TIME_SLOT;

SELECT * FROM CAMPUS_NODE;

SELECT * FROM CAMPUS_EDGE;

SELECT * FROM RESOURCES;


-- ============================================================
-- 11. FINAL DATABASE ROW COUNT CHECK
-- ============================================================

SELECT 'Departments' AS TableName,
       COUNT(*) AS TotalRows
FROM DEPARTMENT

UNION ALL

SELECT 'Resource Types',
       COUNT(*)
FROM RESOURCE_TYPE

UNION ALL

SELECT 'Locations',
       COUNT(*)
FROM LOCATION

UNION ALL

SELECT 'Users',
       COUNT(*)
FROM USERS

UNION ALL

SELECT 'Time Slots',
       COUNT(*)
FROM TIME_SLOT

UNION ALL

SELECT 'Campus Nodes',
       COUNT(*)
FROM CAMPUS_NODE

UNION ALL

SELECT 'Campus Edges',
       COUNT(*)
FROM CAMPUS_EDGE

UNION ALL

SELECT 'Resources',
       COUNT(*)
FROM RESOURCES

UNION ALL

SELECT 'Bookings',
       COUNT(*)
FROM BOOKINGS;
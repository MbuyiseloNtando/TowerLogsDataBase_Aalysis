USE TowerLogsDB;
GO

SELECT * FROM dbo.TowerLogs

--Total Landings
SELECT 
	SUM(t.NUMBER_OF_LANDINGS) AS Total_landings
FROM dbo.TowerLogs t
join.dbo.Airports a
on t.ICAO_ID = a.ICAOID

--Total operational airports
SELECT 
    COUNT(DISTINCT ICAOID) AS TotalOperationalAirports
from dbo.Airports
WHERE ICAOID IN (SELECT DISTINCT ICAO_ID FROM dbo.TowerLogs)

--EOBT% Comploiance
SELECT 
    EOBT_COMPLIANCE, 
    ROUND(
        (CAST(SUM(NUMBER_OF_LANDINGS) AS FLOAT) / 
        (SELECT SUM(NUMBER_OF_LANDINGS) FROM dbo.TowerLogs WHERE EOBT_COMPLIANCE IS NOT NULL)) * 100, 
        2
    ) AS PercentageOfTotal 
FROM dbo.TowerLogs 
WHERE EOBT_COMPLIANCE IS NOT NULL AND TOWER_LOG_TYPE = 'DEP' AND [IFR/VFR] = 'I'
GROUP BY EOBT_COMPLIANCE;

-- Percentage of departures and arrivals
SELECT 
    ROUND(
        (CAST(SUM(CASE WHEN TOWER_LOG_TYPE = 'DEP' THEN NUMBER_OF_LANDINGS ELSE 0 END) AS FLOAT) / 
        (SELECT SUM(NUMBER_OF_LANDINGS) FROM dbo.TowerLogs)) * 100, 
        2
    ) AS PercentageDepartures,
    ROUND(
        (CAST(SUM(CASE WHEN TOWER_LOG_TYPE = 'ARR' THEN NUMBER_OF_LANDINGS ELSE 0 END) AS FLOAT) / 
        (SELECT SUM(NUMBER_OF_LANDINGS) FROM dbo.TowerLogs)) * 100, 
        2
    ) AS PercentageArrivals
FROM dbo.TowerLogs;

--Deparures Over Time
SELECT 
    ATDDate as DepartureDate, 
    SUM(NUMBER_OF_LANDINGS)AS TotalDepartures
FROM dbo.TowerLogs 
WHERE TOWER_LOG_TYPE = 'DEP' 
GROUP BY ATDDate
ORDER BY ATDDate DESC;

--None Clustered Index for TowerLogType
CREATE NONCLUSTERED INDEX idx_TowerLogType 
ON dbo.TowerLogs(TOWER_LOG_TYPE, NUMBER_OF_LANDINGS);

--Number of Movements per month
--Running total overtime
WITH MonthlyDepartures AS (
    SELECT 
        DATETRUNC(month, ATDDate) AS MonthStart,
        SUM(NUMBER_OF_LANDINGS) AS TotalLandings
    FROM dbo.TowerLogs
    WHERE TOWER_LOG_TYPE = 'DEP'
    GROUP BY DATETRUNC(month, ATDDate)
)
SELECT 
    MonthStart AS ATDDate,
    TotalLandings AS total_landings,
    SUM(TotalLandings) OVER (ORDER BY MonthStart) AS running_total_landings
FROM MonthlyDepartures
ORDER BY MonthStart;



--Arrivals Over Time
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT 
    ATADate as DepartureDate, 
    SUM(NUMBER_OF_LANDINGS)AS TotalDepartures
FROM dbo.TowerLogs 
WHERE TOWER_LOG_TYPE = 'ARR' 
GROUP BY ATADate
ORDER BY ATADate DESC;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

CREATE NONCLUSTERED INDEX IX_TowerLogs_Optimization
ON dbo.TowerLogs (TOWER_LOG_TYPE, ATADate)
INCLUDE (NUMBER_OF_LANDINGS);

--Number of Movements per month
--Running total overtimez
SELECT 
    ATADate, 
    total_arrivals, 
    SUM(total_arrivals) OVER(ORDER BY ATADate) AS running_total_landings 
FROM (
    SELECT 
        DATETRUNC(month, ATADate) AS ATADate, 
        SUM(NUMBER_OF_LANDINGS) AS total_arrivals 
    FROM dbo.TowerLogs 
    WHERE TOWER_LOG_TYPE = 'ARR' 
    GROUP BY DATETRUNC(month, ATADate)
) AS MonthlyArr;

--Number of Movements For each airport
SELECT 
    a.Name as DepartureDate, 
    SUM(t.NUMBER_OF_LANDINGS)AS TotalDepartures
FROM dbo.TowerLogs t
JOIN dbo.Airports a
ON t.ICAO_ID = a.ICAOID
GROUP BY a.Name

--Movements percentage for each airport
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
WITH AirportMovements AS ( 
    SELECT 
        a.name AS Name, 
        SUM(t.NUMBER_OF_LANDINGS) AS TotalMovements 
    FROM TowerLogs t 
    LEFT JOIN Airports a ON t.ICAO_ID = a.ICAOID 
    GROUP BY a.Name
), 
GrandTotal AS ( 
    SELECT 
        SUM(TotalMovements) AS OverallMovements 
    FROM AirportMovements 
) 
SELECT 
    m.Name, 
    m.TotalMovements, 
    g.OverallMovements, 
    ROUND((CAST(m.TotalMovements AS FLOAT) / g.OverallMovements) * 100, 2) AS percentage_of_total 
FROM AirportMovements m 
CROSS JOIN GrandTotal g 
ORDER BY m.TotalMovements DESC;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

CREATE NONCLUSTERED INDEX IX_TowerLogs_ICAO_Landings
ON dbo.TowerLogs (ICAO_ID)
INCLUDE (NUMBER_OF_LANDINGS);


--Tower Log landings per types for each airport
SELECT
    a.Name,
    TOWER_LOG_TYPE,
    SUM(NUMBER_OF_LANDINGS) AS Landings
FROM dbo.TowerLogs t
JOIN Airports a
ON t.ICAO_ID=a.ICAOID
GROUP BY Name, TOWER_LOG_TYPE

--IFR/VFR for each Airport
SELECT
   a.Name,
   t.[IFR/VFR],
   SUM(NUMBER_OF_LANDINGS)
FROM TowerLogs t
JOIN Airports a
ON t.ICAO_ID=a.ICAOID
group by Name, [IFR/VFR]

--WTC for each airport
SELECT
   a.Name,
   t.WAKE_TURBULENCE,
   SUM(NUMBER_OF_LANDINGS) AS TotalMovements
FROM TowerLogs t
JOIN Airports a
ON t.ICAO_ID=a.ICAOID
group by Name, WAKE_TURBULENCE

--EOBT compliant
SELECT EOBT_COMPLIANCE,
SUM(NUMBER_OF_LANDINGS) AS TotalMovements
FROM dbo.TowerLogs
WHERE EOBT_COMPLIANCE IS NOT NULL
GROUP BY EOBT_COMPLIANCE

   
--DELAY REASONS
SELECT 
    DELAY_REASON,
    SU_DELAY,
    SUM(NUMBER_OF_LANDINGS) AS TotalDelayes
FROM 
    dbo.TowerLogs 
WHERE 
    DELAY_REASON IS NOT NULL 
    AND EOBT_COMPLIANCE = 'DELAYED' 
    AND [IFR/VFR] = 'I' 
    AND TOWER_LOG_TYPE = 'DEP' 
GROUP BY SU_DELAY, DELAY_REASON;

--BusiestRoutes
SELECT TOP 10
    Route,
    sum(NUMBER_OF_LANDINGS) as TotalMovements
FROM dbo.TowerLogs
GROUP BY Route
ORDER BY TotalMovements DESC


--Airports Summary CTE
SET STATISTICS TIME ON; 
SET STATISTICS IO ON;

WITH CombinedAggregates AS (
    SELECT 
        t.ICAO_ID, 
        SUM(t.NUMBER_OF_LANDINGS) AS TotalLandingsLogs, 
        MAX(t.SU_DELAY) AS MaxDelay, 
        MIN(t.SU_DELAY) AS MinDelay, 
        COUNT(DISTINCT t.AGENCY_DESIGNATOR) AS NumberOfAirlines,
        COUNT(DISTINCT t.AIRCRAFT_TYPE) AS AircraftTypeOperating
    FROM dbo.TowerLogs t 
    GROUP BY t.ICAO_ID 
)
SELECT 
    a.name, 
    a.CityName, 
    a.Altitude, 
    b.TotalLandingsLogs, 
    b.MaxDelay, 
    b.MinDelay, 
    b.NumberOfAirlines, 
    b.AircraftTypeOperating 
FROM CombinedAggregates b 
JOIN dbo.Airports a ON b.ICAO_ID = a.ICAOID 
ORDER BY b.TotalLandingsLogs ASC, a.CityName DESC;

SET STATISTICS TIME OFF; 
SET STATISTICS IO OFF;

--
SELECT * FROM TowerLogs


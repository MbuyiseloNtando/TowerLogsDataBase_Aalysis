-- Creating the database
CREATE DATABASE TowerLogsDB;
GO

USE TowerLogsDB;
GO

-- Verify creation
SELECT * FROM sys.databases 
WHERE name = 'TowerLogsDB';
GO

-- Create the Customers table
CREATE TABLE dbo.TowerLogs (
    TowerLogID VARCHAR(10) PRIMARY KEY,
    ICAO_ID VARCHAR(4) ,
    TOWER_LOG_TYPE VARCHAR(20),
    AGENCY_DESIGNATOR VARCHAR(15),
    FLIGHT_NUMBER VARCHAR(10),
    AIRCRAFT_REGISTRATION VARCHAR(15),
    AIRCRAFT_TYPE VARCHAR(8),
    FITYPE VARCHAR(15) CHECK (FITYPE IN ('Scheduled', 'General', 'Other', 'Mercy', 'Military', 'Non Scheduled')),
    FLIGHT_CLASS VARCHAR (15) CHECK (FLIGHT_CLASS in ('DOMESTIC', 'INTERNATIONAL', 'REGIONAL')),
    WAKE_TURBULENCE VARCHAR(1) CHECK(WAKE_TURBULENCE in('H', 'M', 'L')),
    [IFR/VFR] VARCHAR(1) CHECK([IFR/VFR] in ('I','V')),
    DEPARTURE_AIRPORT VARCHAR(4),
    ARRIVAL_AIRPORT VARCHAR(4),
    ATDDate DATE DEFAULT CAST(GETDATE() AS DATE),
    ATD TIME(0),
    ATADate  DATE DEFAULT CAST(GETDATE() AS DATE),
    ATA TIME(0),
    NUMBER_OF_LANDINGS INT,
    DELAY_TYPE VARCHAR(20),
    DELAY_REASON VARCHAR(100),
    SU_DELAY TIME(0),
    EOBT_COMPLIANCE VARCHAR(15),
    [Route] VARCHAR(15)
);
GO

--Creating Airports table
CREATE TABLE dbo.Airports(
    ICAOID VARCHAR(4) PRIMARY KEY NOT NULL,
    [Name] VARCHAR(150),
    CityName VARCHAR(50),
    [2DLocation] VARCHAR(50),
    Altitude VARCHAR(15),
    TaxingDuration TIME(0)
);
GO

ALTER TABLE Airports 
ADD PRIMARY KEY (ICAOID);

-- Add Foreign Key Constraints
ALTER TABLE dbo.TowerLogs ADD CONSTRAINT FKAirports 
    FOREIGN KEY (ICAO_ID) REFERENCES dbo.Airports(ICAOID) 
    ON DELETE CASCADE ON UPDATE CASCADE;
GO

--Inserting data from csv
BULK INSERT dbo.TowerLogs
FROM 'C:\Users\Mbuyiselox\Documents\Personal\CSV Files\TowerLogs.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Skips the header row
);
GO

SELECT *
FROM dbo.TowerLogs

--Inserting into airports
BULK INSERT dbo.Airports
FROM 'C:\Users\Mbuyiselox\Documents\Personal\CSV Files\Airports.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Skips the header row
);
GO

SELECT *
FROM dbo.Airports


--Checking database blueprint
SELECT 
    t.name AS TableName, 
    c.name AS ColumnName, 
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM 
    sys.tables t
INNER JOIN 
    sys.columns c ON t.object_id = c.object_id
INNER JOIN 
    sys.types ty ON c.user_type_id = ty.user_type_id
ORDER BY 
    t.name, c.column_id;

--Check for existing primary keys and constraints
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName
FROM 
    sys.tables t
INNER JOIN 
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN 
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE 
    i.is_primary_key = 1
ORDER BY 
    t.name;

CREATE INDEX PK_Airports ON Airports(ICAOID);
GO
CREATE INDEX PK_TowerLog ON TowerLogs(TowerLogID);
GO

ALTER TABLE Airports 
ADD CONSTRAINT PK_Airports PRIMARY KEY NONCLUSTERED (ICAOID)

SELECT 
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc AS index_type,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS indexed_columns,
    i.is_primary_key,
    i.is_unique
FROM 
    sys.tables t
INNER JOIN 
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN 
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE 
    i.is_hypothetical = 0  -- Exclude hypothetical indexes used by DTA
    AND i.name IS NOT NULL -- Exclude heaps (tables without a clustered index)
GROUP BY 
    t.name, i.name, i.type_desc, i.is_primary_key, i.is_unique
ORDER BY 
    t.name, i.name;

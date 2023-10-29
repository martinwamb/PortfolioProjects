-- FORMULA 1 Data Analysis Project
  
  -- Determine which circuit had the fastest Quali time
  SELECT races.year, circuits.country, MIN(races.quali_time) FastestQuali
  FROM FormulaOneData..races
  JOIN circuits
	ON races.circuitId = circuits.circuitId
GROUP BY races.year, circuits.country
ORDER BY FastestQuali DESC
--WHERE FastestQuali <> '\N'


SELECT *
FROM FormulaOneData..constructor_results

  SELECT *
  FROM FormulaOneData..races

SELECT *
FROM FormulaOneData..constructor_standings

-- Identify which circuit favors which driver
SELECT wins,driverRef, name
FROM FormulaOneData..driver_standings
JOIN drivers
	ON driver_standings.driverId = drivers.driverId
JOIN races
	ON races.raceId = driver_standings.raceId
ORDER BY 1 desc

-- Determine how many home race wins each driver has had

SELECT distinct(CAST(PARSENAME(REPLACE(name,' ','.'),3) AS nvarchar)) CircuitFName
FROM FormulaOneData..races
--WHERE CAST(PARSENAME(REPLACE(name,' ','.'),3) AS nvarchar) IS  NULL
ORDER BY 1

SELECT 
CASE
	WHEN 
		PATINDEX('% % % %',name) > 0
	THEN 
		SUBSTRING(name,1, CHARINDEX(' ', name + ' ', CHARINDEX(' ', name + ' ') +1) -1)
	ELSE
		SUBSTRING(name,1,CHARINDEX(' ', name + ' ') -1) 
	END AS GPFName
FROM FormulaOneData..races

SELECT DISTINCT(PATINDEX('% % % %', name)) HasFourWords, COUNT(PATINDEX('% % % %', name)) CountOfPattern
FROM FormulaOneData..races
GROUP BY name

SELECT CircuitFName
FROM FormulaOneData..races
--ORDER BY 2 DESC


ALTER TABLE FormulaOneData..races
ADD CircuitFName nvarchar (50) 

update FormulaOneData..races
SET CircuitFName = CASE
	WHEN 
		PATINDEX('% % % %',name) > 0
	THEN 
		SUBSTRING(name,1, CHARINDEX(' ', name + ' ', CHARINDEX(' ', name + ' ') +1) -1)
	ELSE
		SUBSTRING(name,1,CHARINDEX(' ', name + ' ') -1) 
	END 


WITH DriverTable AS 
(
SELECT res.raceId, Drv.driverId, CONCAT(Drv.forename, ' ', Drv.surname) DriverName, Drv.nationality, races.CircuitFName , res.position, SUBSTRING(CONVERT(VARCHAR(50),races.date,120),1,CHARINDEX(':',CONVERT(VARCHAR(50),races.date,120))-3) RaceDate
FROM FormulaOneData..drivers Drv
JOIN FormulaOneData..results Res
	ON Drv.driverId = Res.driverId
JOIN FormulaOneData..races
	ON races.raceId = Res.raceId
JOIN FormulaOneData..circuits Cir
	ON Cir.circuitId = races.circuitId
)
SELECT raceID, DriverID, DriverName, nationality, CircuitFName, Position, RaceDate,
CASE
WHEN nationality = circuitFName THEN 'HomeRace'
ELSE 'NotHomeRace'
END AS RaceStatus
--INTO DriverStatistics
FROM DriverTable
--GROUP BY raceID, DriverID, DriverName, nationality, CircuitFName, RaceDate
ORDER BY 7

SELECT *, COUNT(DriverName) OVER(PARTITION BY DriverName) NumberOfHomeWins
FROM DriverStatistics
WHERE Position = 1 AND RaceStatus = 'HomeRace'
Group by raceId,driverId,DriverName, nationality, CircuitFName, position,RaceDate, RaceStatus
ORDER BY 9 DESC


--When did we start experiencing the most number of drivers completing a race? 

SELECT DrvSt.raceID, DrvSt.DriverID, DrvSt.DriverName, DrvSt.nationality, DrvSt.CircuitFName, DrvSt.Position, DrvSt.RaceDate,  DrvSt.RaceStatus, Res.statusId
FROM DriverStatistics DrvSt
RIGHT JOIN FormulaOneData..results Res
	ON res.driverId = DrvSt.DriverID
WHERE Res.statusId > 1
--GROUP BY DrvSt.raceID, DrvSt.DriverID, DrvSt.DriverName, DrvSt.nationality, DrvSt.CircuitFName, DrvSt.Position, DrvSt.RaceDate,  DrvsT.RaceStatus, Res.statusId, status.status
ORDER BY 7,1



-- What were the results of the Qatar race

SELECT Cir.circuitId, Cir.location, Cir.country, Cir.location, races.year, drivers.driverId, drivers.forename, drivers.surname, results.points, results.position, RACES.date
FROM FormulaOneData..circuits Cir, FormulaOneData..races, FormulaOneData..results, FormulaOneData..drivers
where country = 'Qatar' AND Cir.circuitId = races.circuitId AND races.year <2023 AND results.raceId = races.raceId AND results.driverId = drivers.driverId
ORDER BY 9 DESC


IF OBJECT_ID('qatar_race_results', 'V') IS NOT NULL
DROP VIEW qatar_race_results;
GO

CREATE VIEW qatar_race_results AS
SELECT Cir.circuitId, Cir.location, Cir.country, races.year, drivers.driverId, drivers.forename, drivers.surname, results.points, results.position, DATENAME(YEAR,RACES.date) Year_
FROM FormulaOneData..circuits Cir, FormulaOneData..races, FormulaOneData..results, FormulaOneData..drivers
where country = 'Qatar' AND Cir.circuitId = races.circuitId AND races.year <2023 AND results.raceId = races.raceId AND results.driverId = drivers.driverId;


SELECT *
FROM qatar_race_results


--- What were the results of the Circuit of the Americas
SELECT *
FROM FormulaOneData..circuits order by 5
--where country = 'United'
-- Circuit ID is 69

SELECT *
FROM FormulaOneData..drivers
WHERE circuitId = 69
ORDER BY 2 -- Number of races so far have been 10 and raceIDs have been 878,898,916,942,965,985,1006,1028,1069,1093

-- Which driver has had the most race wins in the Circuit of the Americas?
IF OBJECT_ID('CircuitOfTheAmericas', 'V') IS NOT NULL
DROP VIEW CircuitOfTheAmericas;
GO

CREATE VIEW CircuitOfTheAmericas AS
SELECT year, name, drivers.driverId, drivers.driverRef, points, position, status.status, CONVERT(TIME,fastestLapTime) AS FastestLapTime
FROM FormulaOneData..races 
JOIN FormulaOneData..results
ON races.raceId = results.raceId 
JOIN FormulaOneData..drivers
ON drivers.driverId = results.driverId 
JOIN FormulaOneData..status
ON status.statusId = results.statusId
WHERE circuitId = 69
ORDER BY 8 

--- What were the results of the Mexico
SELECT *
FROM FormulaOneData..circuits 
where country = 'Mexico'
order by 5

-- Circuit ID is 32

SELECT year, name, drivers.driverId, drivers.driverRef, points, position, status.status, CONVERT(TIME,fastestLapTime) AS FastestLapTime
FROM FormulaOneData..races 
JOIN FormulaOneData..results
ON races.raceId = results.raceId 
JOIN FormulaOneData..drivers
ON drivers.driverId = results.driverId 
JOIN FormulaOneData..status
ON status.statusId = results.statusId
WHERE circuitId = 32


-- Which driver has had the most race wins in the Circuit of the Americas?
IF OBJECT_ID('MexicanGrandPrix', 'V') IS NOT NULL
DROP VIEW CircuitOfTheAmericas;
GO

CREATE VIEW MexicanGrandPrix AS
SELECT year, name, drivers.driverId, drivers.driverRef, points, position, status.status, CONVERT(TIME,fastestLapTime) AS FastestLapTime
FROM FormulaOneData..races 
JOIN FormulaOneData..results
ON races.raceId = results.raceId 
JOIN FormulaOneData..drivers
ON drivers.driverId = results.driverId 
JOIN FormulaOneData..status
ON status.statusId = results.statusId
WHERE circuitId = 32



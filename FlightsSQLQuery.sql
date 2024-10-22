SELECT * FROM flights

-- CLEAN 

---Drop unnecessary columns 

ALTER TABLE flights DROP COLUMN aircraft_model,airport_code
ALTER TABLE flights DROP COLUMN [departure/arrival_airport1] 

--show duplicates
SELECT 
    flight_number, 
    COUNT(*) AS duplicates 
FROM 
    flights 
GROUP BY 
    flight_number 
HAVING 
    COUNT(*) > 1 
ORDER BY 
    duplicates DESC
--remove it 
WITH CTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY flight_number ORDER BY (SELECT NULL)) AS row_num
    FROM 
        flights
)
DELETE FROM CTE
WHERE row_num > 1;

SELECT * FROM flights

--null values 
--check whcih columns have null vals
SELECT 
    COUNT(*) AS total_rows,
    COUNT([departure/arrival_airport]) AS filled_departure_arival_airport,--remove null n
    COUNT(terminal) AS filled_terminal,--remove null 
    COUNT(scheduled_datetime_flight) AS filled_scheduled,--remove null n
	COUNT(type) AS filled_types,
	COUNT(flight_status) AS filled_status,
	COUNT(city_name) AS filled_cities,
	COUNT([departure/arrival_time_local]) AS filled_local
FROM 
    flights
ALTER TABLE flights DROP COLUMN actual_datetime_flight

DELETE FROM flights 
WHERE [departure/arrival_airport] IS NULL OR
scheduled_datetime_flight IS NULL ;

UPDATE flights 
SET terminal = 2
WHERE terminal IS NULL;


SELECT * FROM flights


SELECT DISTINCT [departure/arrival_airport] FROM flights

UPDATE flights 
SET [departure/arrival_airport] = 'Istanbul'
WHERE [departure/arrival_airport] LIKE '%Istanbul Sabiha Gökçen%'



SELECT DISTINCT city_name FROM flights

SELECT DISTINCT airline_name FROM flights

UPDATE flights
SET airline_name = 'Saudi Arabian'
WHERE airline_name LIKE '%Saudi Arabian Airlines%'

UPDATE flights
SET airline_name = 'Air Arabia'
WHERE airline_name LIKE '%Air Arabia Egypt%'

SELECT * FROM flights
--Analysis start 

--Number of  flights in each airport

SELECT airline_name, COUNT(flight_number) AS Number_of_flights
FROM flights
GROUP BY airline_name ORDER BY Number_of_flights DESC

--Most city has flights
SELECT city_name,COUNT(flight_number) AS Number_of_flights
FROM flights
GROUP BY city_name ORDER BY Number_of_flights DESC 




-- The month with the most flights
SELECT 
MONTH(scheduled_datetime_flight) AS Month, 
 COUNT(flight_number) AS Number_of_flights 
FROM 
flights
GROUP BY 
MONTH(scheduled_datetime_flight) 
ORDER BY 
Number_of_flights DESC


--Number of arrival and departure flights
SELECT 
type,COUNT(flight_number) AS Number_of_flights 
FROM flights
GROUP BY type ORDER BY Number_of_flights DESC


--How often do flights deviate from their scheduled departure and arrival times and avg delay in minutes 

SELECT 
    COUNT(*) AS Total_Flights,
    SUM(CASE WHEN [departure/arrival_time_local] > scheduled_datetime_flight THEN 1 ELSE 0 END) AS Delayed_Arrivals,
    SUM(CASE WHEN [departure/arrival_time_local] < scheduled_datetime_flight THEN 1 ELSE 0 END) AS Early_Arrivals,
	 SUM(CASE WHEN [departure/arrival_time_local] = scheduled_datetime_flight THEN 1 ELSE 0 END) AS Excatly_On_Time_Arrivals,
    AVG(DATEDIFF(MINUTE, scheduled_datetime_flight, [departure/arrival_time_local])) AS Avg_Arrival_Deviation
FROM 
    flights;



-- Are there certain times of day (morning, afternoon, evening) that see more delays?
SELECT 
    CASE 
        WHEN DATEPART(HOUR, scheduled_datetime_flight) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, scheduled_datetime_flight) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS Time_of_Day,
    COUNT(*) AS Total_Flights,
    SUM(CASE WHEN [departure/arrival_time_local] > scheduled_datetime_flight THEN 1 ELSE 0 END) AS Delayed_Arrivals
FROM 
    flights
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, scheduled_datetime_flight) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, scheduled_datetime_flight) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END
ORDER BY 
    Time_of_Day ;

--the airline the most delayed what’s the reasons check the times 

SELECT 
    airline_name,
    COUNT(*) AS Total_Flights,
    SUM(CASE WHEN [departure/arrival_time_local] > scheduled_datetime_flight THEN 1 ELSE 0 END) AS Delayed_Flights,
	SUM(CASE WHEN  [departure/arrival_time_local] = scheduled_datetime_flight THEN 1 ELSE 0 END) AS On_Time_Flights,
    AVG(DATEDIFF(MINUTE, scheduled_datetime_flight, [departure/arrival_time_local])) AS Avg_Delay_Minutes
FROM 
    flights
GROUP BY 
    airline_name
ORDER BY 
    Delayed_Flights DESC;



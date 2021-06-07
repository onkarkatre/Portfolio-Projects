SELECT * 
FROM BellabeatProject..dailyActivity_merged

-- Standardizing date --
SELECT CAST(ActivityDate AS date) AS Date
FROM BellabeatProject..dailyActivity_merged

-- Finding where the total distance is not equal to tracked distance --
SELECT * 
FROM BellabeatProject..dailyActivity_merged
WHERE TotalDistance != TrackerDistance

-- DELETING Null rows --
SELECT * 
FROM BellabeatProject..dailyActivity_merged
WHERE Calories ='0'

DELETE
FROM BellabeatProject..dailyActivity_merged
WHERE Calories ='0'


DELETE
FROM BellabeatProject..dailyActivity_merged
WHERE TotalDistance ='0'

-- Sorting columns --
SELECT *
FROM BellabeatProject..dailyActivity_merged
ORDER BY ActivityDate DESC

-- Final table --
SELECT DISTINCT ActivityDate, CAST(ActivityDate AS date) AS Date, *
FROM BellabeatProject..dailyActivity_merged

------------------------------------------------------------------------------------------------------------------------------------------

SELECT CAST(ActivityDay AS date) AS Date, *
FROM BellabeatProject..dailyCalories_merged
ORDER BY CAST(ActivityDay AS date) DESC

-- Deleting null values
SELECT *
FROM BellabeatProject..dailyCalories_merged
WHERE Calories = '0'

DELETE
FROM BellabeatProject..dailyCalories_merged
WHERE Calories ='0'


-------------------------------------------------------------------------------------------------------------------------------------------
-- Analysing Data --
-------------------------------------------------------------------------------------------------------------------------------------------

-- Joining tables --
SELECT A.Id,
 A.Calories,  A.TotalSteps,
 A.TotalDistance, 
 A.TrackerDistance, 
 A.LoggedActivitiesDistance,
 SD.TotalSleepRecords, 
 SD.TotalMinutesAsleep, 
 SD.TotalTimeInBed,
 I.SedentaryMinutes,
 I.LightlyActiveMinutes,
 I.FairlyActiveMinutes,
 I.VeryActiveMinutes,
 I.SedentaryActiveDistance,
 I.LightActiveDistance,
 I.ModeratelyActiveDistance,
 I.VeryActiveDistance,
 ISNULL(sd.TotalSleepRecords, 0) AS New_TotalSleepRecords,
 ISNULL(sd.TotalMinutesAsleep, 0) AS New_TotalMinutesAsleep,
 ISNULL(sd.TotalTimeInBed, 0) AS New_TotalTimeInBed
FROM BellabeatProject..dailyActivity_merged A
LEFT JOIN 
     BellabeatProject..dailyCalories_merged C
ON   
     A.Id = C.Id
AND A.ActivityDate = C.ActivityDay
 AND A.Calories = C.Calories
LEFT JOIN
     BellabeatProject..dailyIntensities_merged I
ON
 A.Id = I.Id
 AND A.ActivityDate=I.ActivityDay
 AND A.FairlyActiveMinutes = I.FairlyActiveMinutes
 AND A.LightActiveDistance = I.LightActiveDistance
 AND A.LightlyActiveMinutes = I.LightlyActiveMinutes
 AND A.ModeratelyActiveDistance = I.ModeratelyActiveDistance
 AND A.SedentaryActiveDistance = I.SedentaryActiveDistance
 AND A.SedentaryMinutes = I.SedentaryMinutes
 AND A.VeryActiveDistance = I.VeryActiveDistance
 AND A.VeryActiveMinutes = I.VeryActiveMinutes
LEFT JOIN
    BellabeatProject..dailySteps_merged S
ON
 A.Id = S.Id
 AND A.ActivityDate=S.ActivityDay
LEFT JOIN
      BellabeatProject..sleepDay_merged SD
ON
 A.Id = SD.Id
 AND A.ActivityDate=SD.SleepDay	  

 --------------------------------------------------------------------------------------------------------------------------

 -- we are considering sleep related products as a possibility, let's take a moment to see if/ how people nap during the day --
 -- To do this we are assuming that a nap is any time someone sleeps but goes to sleep and wakes up on the same day --

SELECT CONVERT(time, date) AS sleep_time
FROM BellabeatProject..minuteSleep_merged

ALTER TABLE BellabeatProject..minuteSleep_merged
ADD sleep_time time;

UPDATE BellabeatProject..minuteSleep_merged
SET sleep_time = CONVERT(time, date)         -- Converting Date time --

-- Final query --
SELECT a.Id,
a.Min_sleep AS sleep_date,
COUNT(a.logId) AS number_naps,
SUM(a.hour_sleep) AS total_sleep_hours,
SUM(a.minute_sleep) AS total_sleep_minutes
FROM (
SELECT Id, logId,
MIN(sleep_time) AS Min_sleep,
MAX(sleep_time) AS Max_sleep,
DATEPART(HOUR, date) AS hour_sleep,
DATEPART(MINUTE, date) AS minute_sleep,
DATEPART(SECOND, date) AS sec_sleep
FROM BellabeatProject..minuteSleep_merged
GROUP BY Id, logId, date) a
WHERE a.Min_sleep=a.Max_sleep
GROUP BY a.Id, a.Min_sleep
ORDER BY COUNT(a.logId) DESC, 4 DESC


--------------------------------------------------------------------------------------------------------------------------

 -- Suppose we would like to do an analysis based upon the time of day and day of the week --
 -- Creating Temp table to find out hourly intensity by time of day and day of week  --

 SELECT CONVERT(time, ActivityHour) AS time_of_intensity
FROM BellabeatProject..hourlyIntensities_merged

ALTER TABLE BellabeatProject..hourlyIntensities_merged
ADD time_of_intensity time;

UPDATE BellabeatProject..hourlyIntensities_merged
SET time_of_intensity = CONVERT(time, ActivityHour)    -- Converting Date time --

 WITH Intensity_time AS (
 SELECT Id, ActivityHour, time_of_intensity,
 DATENAME(WEEKDAY, ActivityHour) day_of_week,
 CASE 
   WHEN DATENAME(WEEKDAY, ActivityHour) != 'Saturday' AND    -- != this sign is for not equal to
        DATENAME(WEEKDAY, ActivityHour) != 'Sunday' THEN 'Weekday'
   ELSE 'Weekend'
   END AS part_of_week,
   CASE
   WHEN time_of_intensity BETWEEN '06:00:00' AND '11:00:00' THEN 'Morning'
   WHEN time_of_intensity BETWEEN '12:00:00' AND '16:00:00' THEN 'Afternoon'
   WHEN time_of_intensity BETWEEN '17:00:00' AND '21:00:00' THEN 'Evening'
   ELSE 'Night'
   END AS day_time
    ,SUM(TotalIntensity) AS total_intensity,
   SUM(AverageIntensity) AS total_average_intensity,
   AVG(AverageIntensity) AS average_intensity,
   MAX(AverageIntensity) AS max_intensity,
   MIN(AverageIntensity) AS min_intensity
FROM BellabeatProject..hourlyIntensities_merged
 GROUP BY Id, ActivityHour, DATENAME(WEEKDAY, ActivityHour), time_of_intensity)
 SELECT *
 FROM Intensity_time
 ORDER BY ActivityHour DESC

 -----------------------------------------------------------------------------------------------------------------------------
 -- Joining tables --
 
 SELECT a.Id, a.ActivityDate, a.TotalSteps, a.TotalDistance, a.TrackerDistance, a.LoggedActivitiesDistance,
 a.VeryActiveDistance, a.ModeratelyActiveDistance, a.LightActiveDistance, a.SedentaryActiveDistance, a.VeryActiveMinutes,
 a.FairlyActiveMinutes, a.LightlyActiveMinutes, a.SedentaryMinutes, a.Calories, w.WeightKg, w.Fat, w.BMI, w.IsManualReport,
ISNULL(w.WeightKg, 0) AS Weight_in_kg,
ISNULL(w.Fat, 0) AS New_Fat,
ISNULL(w.BMI, 0) AS New_BMI,
ISNULL(w.IsManualReport, 0) AS Mutual_report
FROM BellabeatProject..dailyActivity_merged a
LEFT JOIN
 BellabeatProject..weightLogInfo_merged w
 ON a.Id = w.Id
 ORDER BY w.WeightKg DESC

----------------------------------------------------------------------------------------------------------------------------
-- Finding at which part of the day people take more steps --

 SELECT CONVERT(time, ActivityHour) AS time_of_intensity
FROM BellabeatProject..hourlySteps_merged

ALTER TABLE BellabeatProject..hourlySteps_merged
ADD time_of_intensity time;

UPDATE BellabeatProject..hourlySteps_merged                          -- Converting Date time --
SET time_of_intensity = CONVERT(time, ActivityHour)

WITH Total_steps AS
( SELECT Id ,ActivityHour, time_of_intensity, StepTotal,
    CASE
   WHEN time_of_intensity BETWEEN '06:00:00' AND '11:00:00' THEN 'Morning'
   WHEN time_of_intensity BETWEEN '12:00:00' AND '16:00:00' THEN 'Afternoon'
   WHEN time_of_intensity BETWEEN '17:00:00' AND '21:00:00' THEN 'Evening'
   ELSE 'Night'
   END AS day_time
 FROM BellabeatProject..hourlySteps_merged        
  GROUP BY Id, ActivityHour, StepTotal, time_of_intensity)            
SELECT *
FROM Total_steps
ORDER BY ActivityHour DESC

--------------------------------------------------------------------------------------------------------------------


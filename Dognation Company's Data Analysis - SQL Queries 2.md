# Dognation Data : Queries that Test Relationships Between Test Completion and Dog Characteristics

#### Question 1: Using the function you found in the websites above, write a query that will output one column with the original created_at time stamp from each row in the completed_tests table, and another column with a number that represents the day of the week associated with each of those time stamps.


```sql
%%sql
SELECT created_at AS Date, DAYOFWEEK(created_at) AS Week_day
FROM complete_tests
LIMIT 49, 200
```

#### Question 2: Include a CASE statement in the query you wrote in Question 1 to output a third column that provides the weekday name (or an appropriate abbreviation) associated with each created_at time stamp.


```sql
%%sql
SELECT created_at, DAYOFWEEK(created_at),
(CASE
WHEN DAYOFWEEK(created_at)=1 THEN "Su"
WHEN DAYOFWEEK(created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(created_at)=4 THEN "We"
WHEN DAYOFWEEK(created_at)=5 THEN "Th"
WHEN DAYOFWEEK(created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(created_at)=7 THEN "Sa"
END) AS daylabel
FROM complete_tests
LIMIT 49,200;
```

#### Question 3: Adapt the query you wrote in Question 2 to report the total number of tests completed on each weekday. Sort the results by the total number of tests completed in descending order.


```sql
%%sql
SELECT DAYOFWEEK(created_at),COUNT(created_at) AS numtests,
(CASE
WHEN DAYOFWEEK(created_at)=1 THEN "Su"
WHEN DAYOFWEEK(created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(created_at)=4 THEN "We"
WHEN DAYOFWEEK(created_at)=5 THEN "Th"
WHEN DAYOFWEEK(created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(created_at)=7 THEN "Sa"
END) AS daylabel
FROM complete_tests
GROUP BY daylabel
ORDER BY numtests DESC;
```

#### Question 4: Rewrite the query in Question 3 to exclude the dog_guids that have a value of "1" in the exclude column


```sql
%%sql
SELECT DAYOFWEEK(c.created_at),COUNT(c.created_at) AS numtests, d.dog_guid AS DogID, d.exclude AS Exclude,
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL OR d.exclude='0'
GROUP BY daylabel
ORDER BY numtests DESC;
```

#### Question 5: Write a query to retrieve all the dog_guids for users common to the dogs and users table using the traditional inner join syntax


```sql
%%sql
SELECT d.dog_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
```

#### Question 7: Start by writing a query that retrieves distinct dog_guids common to the dogs and users table, excuding dog_guids and user_guids with a "1" in their respective exclude columns


```sql
%%sql
SELECT DISTINCT d.dog_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE (d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0');
```

#### Question 8: Now adapt your query from Question 4 so that it inner joins on the result of the subquery you wrote in Question 7 instead of the dogs table. This will give you a count of the number of tests completed on each day of the week, excluding all of the dog_guids and user_guids that the Dognition team flagged in the exclude columns.


```sql
%%sql
SELECT DAYOFWEEK(c.created_at),COUNT(c.created_at) AS numtests, Distinct_dogID.dog_guid AS DogID, YEAR(c.created_at) AS year,
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel
FROM (SELECT DISTINCT d.dog_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE (d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0')) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY daylabel
ORDER BY numtests DESC;
```

#### Question 9: Adapt your query from Question 8 to provide a count of the number of tests completed on each weekday of each year in the Dognition data set. Exclude all dog_guids and user_guids with a value of "1" in their exclude columns. Sort the output by year in ascending order, and then by the total number of tests completed in descending order.


```sql
%%sql
SELECT DAYOFWEEK(c.created_at),COUNT(c.created_at) AS numtests, Distinct_dogID.dog_guid AS DogID, YEAR(c.created_at) AS year,
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel
FROM (SELECT DISTINCT d.dog_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE (d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0')) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY year,daylabel
ORDER BY year ASC,numtests DESC;
```

#### Question 10: First, adapt your query from Question 9 so that you only examine customers located in the United States, with Hawaii and Alaska residents excluded. HINTS: In this data set, the abbreviation for the United States is "US", the abbreviation for Hawaii is "HI" and the abbreviation for Alaska is "AK".


```sql
%%sql
SELECT DAYOFWEEK(c.created_at),COUNT(c.created_at) AS numtests, Distinct_dogID.dog_guid AS DogID, YEAR(c.created_at) AS year,
Distinct_dogID.state,
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel
FROM (SELECT DISTINCT d.dog_guid, u.state
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE ((d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0') AND u.country="US"
AND (u.state!="HI" AND u.state!="AK"))) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY year,daylabel
ORDER BY year ASC,numtests DESC;
```

#### Question 11: Write a query that extracts the original created_at time stamps for rows in the complete_tests table in one column, and the created_at time stamps with 6 hours subtracted in another column.


```sql
%%sql
SELECT created_at, DATE_SUB(created_at,interval 6 hour) AS time_sub_6hr
FROM complete_tests
LIMIT 100
```

#### Question 12: Use your query from Question 11 to adapt your query from Question 10 in order to provide a count of the number of tests completed on each day of the week, with approximate time zones taken into account, in each year in the Dognition data set. Exclude all dog_guids and user_guids with a value of "1" in their exclude columns. Sort the output by year in ascending order, and then by the total number of tests completed in descending order.


```sql
%%sql
SELECT DAYOFWEEK(DATE_SUB(created_at,interval 6 hour)) AS time_sub_6hr,COUNT(c.created_at) AS numtests,
Distinct_dogID.dog_guid AS DogID, YEAR(c.created_at) AS year,
Distinct_dogID.state,
(CASE
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=1 THEN "Su"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=2 THEN "Mo"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=3 THEN "Tu"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=4 THEN "We"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=5 THEN "Th"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=6 THEN "Fr"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=7 THEN "Sa"
END) AS daylabel
FROM (SELECT DISTINCT d.dog_guid, u.state
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE ((d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0') AND u.country="US"
AND (u.state!="HI" AND u.state!="AK"))) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY year,daylabel
ORDER BY year ASC,numtests DESC;
```

#### Question 13: Adapt your query from Question 12 so that the results are sorted by year in ascending order, and then by the day of the week in the following order: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.


```sql
%%sql
SELECT DAYOFWEEK(DATE_SUB(created_at,interval 6 hour)) AS time_sub_6hr,COUNT(c.created_at) AS numtests,
Distinct_dogID.dog_guid AS DogID, YEAR(c.created_at) AS year,
Distinct_dogID.state,
(CASE
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=1 THEN "Su"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=2 THEN "Mo"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=3 THEN "Tu"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=4 THEN "We"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=5 THEN "Th"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=6 THEN "Fr"
WHEN DAYOFWEEK(DATE_SUB(created_at,interval 6 hour))=7 THEN "Sa"
END) AS daylabel
FROM (SELECT DISTINCT d.dog_guid, u.state
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE ((d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0') AND u.country="US"
AND (u.state!="HI" AND u.state!="AK"))) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY year,daylabel
ORDER BY year ASC,FIELD(daylabel,'Monday','Tuseday','Wednesday','Thursday','Friday','Saturday','Sunday');
```

## 2. Which states and countries have the most Dognition users?

#### Question 14: Which 5 states within the United States have the most Dognition customers, once all dog_guids and user_guids with a value of "1" in their exclude columns are removed? Try using the following general strategy: count how many unique user_guids are associated with dogs in the complete_tests table, break up the counts according to state, sort the results by counts of unique user_guids in descending order


```sql
%%sql
SELECT COUNT(DISTINCT Distinct_dogID.user_guid) AS total_users,
Distinct_dogID.state
FROM (SELECT DISTINCT d.dog_guid, u.state, u.user_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE ((d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0') AND u.country="US"
AND (u.state!="HI" AND u.state!="AK"))) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY Distinct_dogID.state
ORDER BY total_users DESC
LIMIT 5;
```

#### Question 15: Which 10 countries have the most Dognition customers, once all dog_guids and user_guids with a value of "1" in their exclude columns are removed?


```sql
%%sql
SELECT COUNT(DISTINCT Distinct_dogID.user_guid) AS total_users,
Distinct_dogID.country
FROM (SELECT DISTINCT d.dog_guid, u.country, u.user_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE (d.exclude IS NULL OR d.exclude='0') AND (u.exclude IS NULL OR u.exclude='0')) AS Distinct_dogID
INNER JOIN complete_tests c
ON Distinct_dogID.dog_guid=c.dog_guid
GROUP BY Distinct_dogID.country
ORDER BY total_users DESC
LIMIT 10;
```

# Dognation Data : Queries that Test Relationships Between Test Completion and Dog Characteristics

To begin, load the sql library and database, and make the Dognition database your default database:


```python
%load_ext sql
%sql mysql://studentuser:studentpw@localhost/dognitiondb
%sql USE dognitiondb
```

## 1. Assess whether Dognition personality dimensions are related to the number of tests completed :

#### Question 1: To get a feeling for what kind of values exist in the Dognition personality dimension column, write a query that will output all of the distinct values in the dimension column. 


```sql
%%sql
SELECT DISTINCT dimension
FROM dogs;
```

#### Question 2: Use the equijoin syntax (described in MySQL Exercise 8) to write a query that will output the Dognition personality dimension and total number of tests completed by each unique DogID.


```sql
%%sql
SELECT d.dog_guid AS DogId, d.dimension AS Dimensions, COUNT(c.created_at) AS No_test_complete
FROM dogs d, complete_tests c
WHERE d.dog_guid=c.dog_guid
GROUP BY DogID
ORDER BY No_test_complete DESC
LIMIT 100;
```

#### Question 3: Re-write the query in Question 2 using traditional join syntax.


```sql
%%sql
SELECT d.dog_guid AS DogId, d.dimension AS Dimensions, COUNT(c.created_at) AS No_test_complete
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
GROUP BY DogID
ORDER BY No_test_complete DESC
LIMIT 100;
```

#### Question 4: To start, write a query that will output the average number of tests completed by unique dogs in each Dognition personality dimension.


```sql
%%sql
SELECT numtests_per_dog.Dimension, AVG(numtests_per_dog.numtests) AS avg_tests_completed
FROM( SELECT d.dog_guid AS dogID, d.dimension AS Dimension, count(c.created_at)
AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.Dimension;
```

#### Question 5: How many unique DogIDs are summarized in the Dognition dimensions labeled "None" or ""? 


```sql
%%sql
SELECT dogs_in_complete_tests.dimension, COUNT(DISTINCT dogs_in_complete_tests.dogID) AS num_dogs
FROM( SELECT d.dog_guid AS dogID, d.dimension AS dimension
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.dimension IS NULL OR d.dimension=''
GROUP BY dogID) AS dogs_in_complete_tests
GROUP BY dimension;
```

#### Question 6: To determine whether there are any features that are common to all dogs that have non-NULL empty strings in the dimension column, write a query that outputs the breed, weight, value in the "exclude" column, first or minimum time stamp in the complete_tests table, last or maximum time stamp in the complete_tests table, and total number of tests completed by each unique DogID that has a non-NULL empty string in the dimension column.


```sql
%%sql
SELECT d.breed, d.weight, d.exclude, MIN(c.created_at) AS MIN_timestamp, MAX(c.created_at) AS MAX_timestamp, d.dimension
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.dimension=''
GROUP BY d.dog_guid
ORDER BY d.weight
```

#### Question 7: Rewrite the query in Question 4 to exclude DogIDs with (1) non-NULL empty strings in the dimension column, (2) NULL values in the dimension column, and (3) values of "1" in the exclude column.


```sql
%%sql
SELECT dimension, AVG(numtests_per_dog.numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID) AS unique_dogID, numtests_per_dog.Exclude
FROM( SELECT d.dog_guid AS dogID, d.dimension AS dimension, count(c.created_at)
AS numtests, d.exclude AS Exclude
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE (dimension IS NOT NULL AND dimension!='') AND (d.exclude IS NULL
OR d.exclude=0)
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.dimension;
```

## 2. Assess whether dog breeds are related to the number of tests completed 

#### Questions 8: Write a query that will output all of the distinct values in the breed_group field.


```sql
%%sql
SELECT DISTINCT breed_group
FROM dogs
```

#### Question 9: Write a query that outputs the breed, weight, value in the "exclude" column, first or minimum time stamp in the complete_tests table, last or maximum time stamp in the complete_tests table, and total number of tests completed by each unique DogID that has a NULL value in the breed_group column.


```sql
%%sql
SELECT d.breed, d.breed_group, d.weight, d.exclude, MIN(c.created_at) AS Min_timestamp, MAX(c.created_at) AS Max_timestamp, 
d.dog_guid AS DogId, COUNT(c.created_at) AS No_test_complete
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.breed_group IS NULL
GROUP BY DogID
ORDER BY d.weight,No_test_complete DESC
```

#### Question 10: Adapt the query in Question 7 to examine the relationship between breed_group and number of tests completed. Exclude DogIDs with values of "1" in the exclude column. Your results should return 1774 DogIDs in the Herding breed group.


```sql
%%sql
SELECT AVG(numtests_per_dog.numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID) AS unique_dogID, numtests_per_dog.Exclude, numtests_per_dog.Breed_group
FROM( SELECT d.dog_guid AS dogID, count(c.created_at)
AS numtests, d.exclude AS Exclude, d.breed_group AS Breed_group
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL
OR d.exclude=0
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.Breed_group;
```

#### Question 11: Adapt the query in Question 10 to only report results for Sporting, Hound, Herding, and Working breed_groups using an IN clause.


```sql
%%sql
SELECT AVG(numtests_per_dog.numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID) AS unique_dogID, numtests_per_dog.Exclude, numtests_per_dog.Breed_group
FROM( SELECT d.dog_guid AS dogID, count(c.created_at)
AS numtests, d.exclude AS Exclude, d.breed_group AS Breed_group
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL
OR d.exclude=0
GROUP BY dogID) AS numtests_per_dog
WHERE numtests_per_dog.Breed_group IN ('Sporting','Hound','Herding','Working')
GROUP BY numtests_per_dog.Breed_group;
```

#### Questions 12: Begin by writing a query that will output all of the distinct values in the breed_type field.


```sql
%%sql
SELECT DISTINCT breed_type
FROM dogs
```

#### Question 13: Adapt the query in Question 7 to examine the relationship between breed_type and number of tests completed. Exclude DogIDs with values of "1" in the exclude column. Your results should return 8865 DogIDs in the Pure Breed group.


```sql
%%sql
SELECT AVG(numtests_per_dog.numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID) AS unique_dogID, numtests_per_dog.Exclude, numtests_per_dog.Breed_type
FROM( SELECT d.dog_guid AS dogID, count(c.created_at)
AS numtests, d.exclude AS Exclude, d.breed_type AS Breed_type
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL
OR d.exclude=0
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.Breed_type;
```

## 3. Assess whether dog breeds and neutering are related to the number of tests completed

#### Question 14: For each unique DogID, output its dog_guid, breed_type, number of completed tests, and use a CASE statement to include an extra column with a string that reads "Pure_Breed" whenever breed_type equals 'Pure Breed" and "Not_Pure_Breed" whenever breed_type equals anything else.


```sql
%%sql
SELECT d.dog_guid AS dogID, d.breed_type AS breed_type,
CASE WHEN d.breed_type='Pure Breed' THEN 'pure_breed'
ELSE 'not_pure_breed'
END AS pure_breed,
count(c.created_at) AS numtests
FROM dogs d, complete_tests c
WHERE d.dog_guid=c.dog_guid
GROUP BY dogID
LIMIT 50
```

#### Question 15: Adapt your queries from Questions 7 and 14 to examine the relationship between breed_type and number of tests completed by Pure_Breed dogs and non_Pure_Breed dogs


```sql
%%sql
SELECT AVG(numtests_per_dog.numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID) AS unique_dogID, numtests_per_dog.Exclude, numtests_per_dog.Breed_type
FROM( SELECT d.dog_guid AS dogID, count(c.created_at)
AS numtests, d.exclude AS Exclude, d.breed_type AS Breed_type,
     CASE WHEN d.breed_type='Pure Breed' THEN 'pure_breed'
ELSE 'not_pure_breed'
END AS pure_breed
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL
OR d.exclude=0
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.Breed_type;
```

#### Question 16: Adapt your query from Question 15 to examine the relationship between breed_type, whether or not a dog was neutered (indicated in the dog_fixed field), and number of tests completed by Pure_Breed dogs and non_Pure_Breed dogs. 


```sql
%%sql
SELECT numtests_per_dog.pure_breed AS pure_breed, neutered,
AVG(numtests_per_dog.numtests) AS avg_tests_completed, COUNT(DISTINCT dogID)
FROM( SELECT d.dog_guid AS dogID, d.breed_group AS breed_type, d.dog_fixed AS
neutered,
CASE WHEN d.breed_type='Pure Breed' THEN 'pure_breed'
ELSE 'not_pure_breed'
END AS pure_breed,
count(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL OR d.exclude=0
GROUP BY dogID) AS numtests_per_dog
GROUP BY pure_breed, neutered;
```

## 4. Other dog features that might be related to the number of tests completed:

#### Question 17: Adapt your query from Question 7 to include a column with the standard deviation for the number of tests completed by each Dognition personality dimension.


```sql
%%sql
SELECT dimension, AVG(numtests_per_dog.numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID) AS unique_dogID, STDDEV(numtests_per_dog.numtests)
FROM( SELECT d.dog_guid AS dogID, d.dimension AS dimension, count(c.created_at)
AS numtests, d.exclude AS Exclude
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE (dimension IS NOT NULL AND dimension!='') AND (d.exclude IS NULL
OR d.exclude=0)
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.dimension;
```

#### Question 18: Write a query that calculates the average amount of time it took each dog breed_type to complete all of the tests in the exam_answers table. Exclude negative durations from the calculation, and include a column that calculates the standard deviation of durations for each breed_type group:


```sql
%%sql
SELECT d.breed_type AS breed_type,
AVG(TIMESTAMPDIFF(minute,e.start_time,e.end_time)) AS AvgDuration,
STDDEV(TIMESTAMPDIFF(minute,e.start_time,e.end_time)) AS StdDevDuration
FROM dogs d JOIN exam_answers e
ON d.dog_guid=e.dog_guid
WHERE TIMESTAMPDIFF(minute,e.start_time,e.end_time)>0
GROUP BY breed_type;
```

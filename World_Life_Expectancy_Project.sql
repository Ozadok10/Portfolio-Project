SELECT *
FROM world_life_expectancy.world_life_expectancy_project
;


# We begin witht the cleaning process, firat we will search for any duplicates within our data set
# As I can see there should only be one year assigned to a country, for example United Kingdom should only have one row for 2013 

SELECT Row_ID, Year , CONCAT(Country, Year) AS COUNTRY_YEAR, Count(CONCAT(Country, Year)) 
FROM world_life_expectancy.world_life_expectancy_project
Group by Country, Year , CONCAT(Country, Year)
HAVING Count(CONCAT(Country, Year)) >= 2
;

# We have found that there exsists three duplicates within our data 
# Using the Row ID of these duplicates, we will remove them
# Before we make changes, it is best practice to have a backup of the original tables which is what we we will create first

DELETE FROM world_life_expectancy.world_life_expectancy_project
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID,Country, Year, ROW_NUMBER() OVER (PARTITION BY Country, Year ORDER BY Row_ID) AS row_num
        FROM world_life_expectancy.world_life_expectancy_project
    ) AS subquery
    WHERE row_num > 1
);

# With the above code we have now been able to remove all duplicates 
# Reviewing the data further, data within the Status and Life expectancy column's appears to be missing

SELECT *
FROM world_life_expectancy.world_life_expectancy_project
WHERE Status = ''
;
SELECT DISTINCT(Status)
FROM world_life_expectancy.world_life_expectancy_project
WHERE Status <> ''
;

#Now that all possible entries in Status are known we can search for the countries that have a missing Status and fill them in with a prior or future Year's Status


SELECT DISTINCT(Country)
FROM world_life_expectancy.world_life_expectancy_project
WHERE Status = 'Developing';

UPDATE world_life_expectancy.world_life_expectancy_project AS t1
JOIN world_life_expectancy.world_life_expectancy_project AS t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

# We have now filled all blanks in our status column and will move to the Life expectency column

SELECT *
FROM world_life_expectancy.world_life_expectancy_project
WHERE `Life expectancy` = ''
;

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
       t2.Country, t2.Year, t2.`Life expectancy`, 
       t3.Country, t3.Year, t3.`Life expectancy`,
       round((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) as Life_expectancy_Avg
FROM world_life_expectancy.world_life_expectancy_project AS t1
JOIN world_life_expectancy.world_life_expectancy_project AS t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1 
JOIN world_life_expectancy.world_life_expectancy_project AS t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year +1
WHERE t1.`Life expectancy` = '';

UPDATE world_life_expectancy.world_life_expectancy_project AS t1`world_life_expectancy`
JOIN world_life_expectancy.world_life_expectancy_project AS t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1 
JOIN world_life_expectancy.world_life_expectancy_project AS t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year +1
SET t1.`Life expectancy` = round((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

# Now that the more obvious issues with our dataset have been cleaned we will begin exploring our data 
# As we explore deeper into the data set if more inconsistecies are found we will clean further

# We will mainly focusing on life expectancy and if there is a correlation to other parameters, start by looking at the largets increase in life expectency by country
SELECT Country, 
MAX(`Life expectancy`), 
MIN(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),0) AS Largest_Increase_in_LE 
FROM world_life_expectancy.world_life_expectancy_project
Group by Country
HAVING MAX(`Life expectancy`) AND MIN(`Life expectancy`) > 0
Order By ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),0) DESC
;
# As we dive into this data we notice and issue where the the MAX and MIN life expectency for certain countries have 0 values, This appears t be a data quality issue we will correct at a later time
# To continue our analysis we find a work around in the moment which is shown in the code above

# As I continue my analysis I will now search for the average life expectency by YEAR in comparison to the above statement which is by country
# We will also be looking at the avrage life expectency in correlation to GDP
SELECT Year, ROUND(AVG(`Life expectancy`),0) AS AVG_LE
FROM world_life_expectancy.world_life_expectancy_project
Group by Year
;

SELECT Country, ROUND(AVG(GDP),0) AS AVG_GDP , ROUND(AVG(`Life expectancy`), 0) AS AVG_LE
FROM world_life_expectancy.world_life_expectancy_project
group by Country
HAVING AVG_GDP AND AVG_LE > 0
ORDER BY AVG_GDP 
;

#I will show this correlation more in depth through the use of CASE statments to shows the correlation in one broad picture. 

SELECT
SUM(CASE WHEN GDP > 1500 THEN 1 ELSE NULL END) AS HIGH_GDP,
ROUND(AVG(CASE WHEN GDP > 1500 THEN `Life expectancy` ELSE NULL END),2) AS HIGH_GDP_LE,
SUM(CASE WHEN GDP < 1500 THEN 1 ELSE NULL END) AS LOW_GDP,
ROUND(AVG(CASE WHEN GDP < 1500 THEN `Life expectancy` ELSE NULL END),2) AS LOW_GDP_LE
FROM world_life_expectancy.world_life_expectancy_project
;

#I will now take a look at our status column to see if there is a similar corrrlation between developing countries and their respective life expactency vs developed countries and their life expectency

SELECT Status, ROUND(AVG(`Life expectancy`),2) AS AVG_LE, COUNT(DISTINCT country) AS AMOUNT_of_STATUS
FROM world_life_expectancy.world_life_expectancy_project
GROUP BY Status 
;

#Continuing on this tred of comparing diffrent parameters to find a corrilation to life expectency we will now use BMI as our factor compared to life expectency

SELECT Country, ROUND(AVG(`Life expectancy`),0) AS AVG_LE , ROUND(AVG(BMI),0) AS BMI
FROM world_life_expectancy.world_life_expectancy_project
group by Country
HAVING BMI AND AVG_LE > 0
ORDER BY BMI
;














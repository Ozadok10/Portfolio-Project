SELECT * 
FROM us_project.us_household_income;

SELECT * 
FROM us_project.ushouseholdincome_statistics;

# When starting to analyze these two data set we being by cleaning the data 

# First I spotted a cloumn header that has imported incorrectly ehich is corrected
ALTER TABLE us_project.ushouseholdincome_statistics RENAME COLUMN `ï»¿id` to `ID`;

# We then will check for duplicates in our ID columns, and if found remove them
SELECT row_ID,ID, COUNT(ID)
FROM us_project.us_household_income
GROUP BY ID
HAVING COUNT(ID) >= 2
ORDER BY ID
;

DELETE FROM us_project.us_household_income
WHERE ROW_ID IN (
SELECT row_id
FROM(
SELECT row_ID,
ID,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
FROM us_project.us_household_income
) Duplicate
where row_num > 1)
;

# When scrolling through the data I spotted some spelling error for the states names columns, missing data for the place column etc. I will seach for these issues and correct appropriatley 

SELECT distinct State_Name
FROM us_project.us_household_income
GROUP BY State_Name
;

UPDATE us_project.us_household_income
SET State_name = 'Georgia'
WHERE State_Name ='georia';

UPDATE us_project.us_household_income
SET State_name = 'Alabama'
WHERE State_Name ='alabama';

SELECT * 
FROM us_project.us_household_income
WHERE County = 'Autauga County' 
ORDER BY 1
;

UPDATE us_project.us_household_income
SET Place = 'Autaugaville'
Where County = 'Autauga County' and City = 'Vinemont';

# We will now dive deeper into the type cloumn where we notice redundencies in the Types column 

SELECT Type, COUNT(Type)
FROM us_project.us_household_income
GROUP BY Type;

UPDATE us_project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

#Now that we have completed cleaning the more obvious issues we will move on to exploring this data set 
#We will start by seeing which states have the most water and which have the most land

SELECT State_Name,SUM(Aland), SUM(Awater)
FROM us_project.us_household_income
GROUP BY State_Name
Order by 3 DESC;

#Now we will look into the income status of each houselhold and group this data by the type of location 

SELECT HI.State_Name, ROUND(AVG(Mean),2), ROUND(AVG(Median),2) 
FROM us_project.us_household_income AS HI
Right Join us_project.ushouseholdincome_statistics AS HS
	ON HI.id = HS.id
WHERE mean <> 0
GROUP BY State_Name
ORDER BY 2;

SELECT Type,COUNT(TYPE), ROUND(AVG(Mean),2), ROUND(AVG(Median),2) 
FROM us_project.us_household_income AS HI
Right Join us_project.ushouseholdincome_statistics AS HS
	ON HI.id = HS.id
WHERE mean <> 0
GROUP BY Type
ORDER BY 2 desc;

#Lastly we will be comparing average income based on cities

SELECT HI.State_NAme, City, Count(City), ROUND(AVG(Mean),2)
FROM us_project.us_household_income AS HI
Join us_project.ushouseholdincome_statistics AS HS
	ON HI.id = HS.id
WHERE mean <> 0
GROUP BY City
HAVING COUNT(City) > 50
ORDER BY 4 DESC;





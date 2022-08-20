SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
order by 1,2

-- Looking at the total Cases vs Total Deaths
-- Shows likleyhood of a person dying from Covid per country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows percentage of country that has been infected
SELECT Location, date, total_cases, population , (total_cases/population)*100 AS ContractionPercentage
FROM [Portfolio Project]..CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking for countries with the highest infection rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM [Portfolio Project]..CovidDeaths
Group by location,population
order by PercentagePopulationInfected desc

-- Looking at the highest death counts per population

Select location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- This will now show the highest death count per continent 
Select location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
Where continent is null AND location not like '%income%'
Group by location
order by TotalDeathCount desc

-- Global Statistic
SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentageGLOBAL
FROM [Portfolio Project]..CovidDeaths
order by 1,2

-- Looking at total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date ) AS RollingVaccinations
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--and dea.location like '%canada%'
order by 2,3

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date ) AS RollingVaccinations
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--and dea.location like '%canada%'
--order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated










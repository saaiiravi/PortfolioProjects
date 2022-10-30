use sideproject;
select * from covid_death ORDER BY 3,4;
select * from covid_vaccinations ORDER BY 3,4;

-- select data that we are going to use

SELECT location, date,  total_cases, new_cases, total_deaths, population
FROM covid_death WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total cases vs Total deaths (shows likelihood of dying if you contract covid based on country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_percentage
FROM covid_death
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at the totalcases vs Population (Shows what percentage of population got covid)

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Percent_population_infected
FROM covid_death
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to Population 

SELECT location,  population, max(total_cases), MAX((total_cases/population)* 100) AS Percent_population_infected
FROM covid_death WHERE continent IS NOT NULL
#WHERE location like '%states%'
GROUP BY location, population
ORDER BY Percent_population_infected desc;

-- Showing continents with highest death count per population 

SELECT Continent, MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM covid_death WHERE continent IS NOT NULL
#WHERE location like '%states%'
GROUP BY Continent
ORDER BY TotalDeathCount desc;

-- Showing countries with highest death count per population 

SELECT location, MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM covid_death WHERE continent IS NOT NULL
#WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc; 

-- Global Numbers (Death percentage for continents per date)

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
(SUM(new_deaths)/SUM(new_cases)) * 100 AS Death_Percentage
FROM covid_death 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Overall Death Percentage

SELECT  SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
(SUM(new_deaths)/SUM(new_cases)) * 100 AS Death_Percentage
FROM covid_death 
WHERE continent IS NOT NULL
ORDER BY 1,2;

select * from covid_vaccinations LIMIT 10;

-- Joining two tables

SELECT * from Covid_death cd
JOIN Covid_vaccination cv
ON cd.location = cv.location AND cd.date = cv.date;

-- Looking at total population vs vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from Covid_death cd
JOIN Covid_vaccination cv
ON cd.location = cv.location AND cd.date = cv.date
ORDER BY 2,3; 

-- Rolling vaccination count 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from Covid_death cd
JOIN Covid_vaccination cv
ON cd.location = cv.location AND cd.date = cv.date
ORDER BY 2,3; 

-- USE CTE 
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)  
AS(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from Covid_death cd
JOIN Covid_vaccination cv
ON cd.location = cv.location AND cd.date = cv.date
ORDER BY 2,3 )
Select *, (RollingPeopleVaccinated/population) * 100 AS PercentagePeopleVaccinated  From PopvsVac;

-- TempTable 
CREATE TABLE PercentPopulationVaccinated AS(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from Covid_death cd
JOIN Covid_vaccination cv
ON cd.location = cv.location AND cd.date = cv.date
ORDER BY 2,3);
Select *, (RollingPeopleVaccinated/population) * 100 AS PercentagePeopleVaccinated  From PercentPopulationVaccinated;



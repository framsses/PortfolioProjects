/*

COVID 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 
			Creating Views, Converting Data Types
			
*/

SELECT *
FROM PortfolioProject.CovidDeaths cd 
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select Data that we are going to start using

SELECT location, continent, `date`, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.CovidDeaths cd
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total Cases VS Total Deaths
-- Show likelihood of dying if you contract covid in your country

SELECT location, date,total_cases ,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths cd 
WHERE location LIKE '%Mexico%'
ORDER BY 1, 2;

-- Total Cases  VS Population
-- Shows what percentage of population infected with COVID 

SELECT location, date,population, total_cases, (total_cases /population)*100 AS PercentagePopulationInfected
FROM PortfolioProject.CovidDeaths cd 
-- WHERE location LIKE '%Mexico%'
ORDER BY 1, 2;

-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases /population)*100) AS PercentagePopulationInfected
FROM PortfolioProject.CovidDeaths cd 
-- WHERE location LIKE '%Mexico%'
WHERE continent IS NOT NULL
GROUP BY population, location 
ORDER BY PercentagePopulationInfected DESC;

-- Countries with Highest Death Count Population

SELECT location,MAX(total_deaths) AS TotalDeathCounts
FROM PortfolioProject.CovidDeaths cd 
WHERE continent IS NOT NULL
-- WHERE location LIKE '%Mexico%'
GROUP BY location 
ORDER BY TotalDeathCounts DESC;

-- BREAK THINGS DOWN BY CONTINENT

SELECT location ,MAX(total_deaths) AS TotalDeathCounts
FROM PortfolioProject.CovidDeaths cd 
WHERE continent IS NULL
-- WHERE location LIKE '%Mexico%'
GROUP BY location 
ORDER BY TotalDeathCounts DESC;

-- Showing the continent with the highest death count per population

SELECT continent ,MAX(total_deaths) AS TotalDeathCounts
FROM PortfolioProject.CovidDeaths cd 
WHERE continent IS NOT NULL
-- WHERE location LIKE '%Mexico%'
GROUP BY continent 
ORDER BY TotalDeathCounts DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths cd 
-- WHERE location LIKE '%Mexico%'
WHERE continent IS NOT NULL 
-- GROUP BY `date` 
ORDER BY 1, 2;

-- Total Population VS Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd
INNER JOIN PortfolioProject.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.`date`  = cv.`date`
WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL
ORDER BY 2, 3;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Dati, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd
INNER JOIN PortfolioProject.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.`date`  = cv.`date`
WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL
ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PortfolioProject.TempCovi
CREATE TEMPORARY TABLE PortfolioProject.TempCovi(
Continent VARCHAR(50),
Location VARCHAR(50),
Dati DATE,
Population INT,
New_vaccinations INT,
RollingPeopleVaccinated INT
)

INSERT INTO PortfolioProject.TempCovi
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd
INNER JOIN PortfolioProject.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.`date`  = cv.`date`
WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL
ORDER BY 2, 3;

SELECT *
FROM PortfolioProject.TempCovi

-- Creating View to Store Data for Later Visualizations

CREATE VIEW PortfolioProject.PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd
INNER JOIN PortfolioProject.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.`date`  = cv.`date`
WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL

-- Select data from the view created

SELECT *
FROM PortfolioProject.PercentPopulationVaccinated



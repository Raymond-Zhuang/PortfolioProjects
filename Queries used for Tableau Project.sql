/*

Queries used for Taleau Project

*/

SELECT  *
FROM CovidDeaths

--1 GLOBAL DEATH PERCENTAGE

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%canada%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DeathPercentage
--FROM CovidDeaths
----WHERE location LIKE '%canada%' AND 
--WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
----GROUP BY date
--ORDER BY 1,2

--2 TOTAL DEATH OF EACH CONTINENT

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


--3 PERCENTAGE POPULATION INFECTED OF EACH COUNTRY

--SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
--FROM CovidDeaths
--GROUP BY location, population
--ORDER BY PercentagePopulationInfected DESC

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--4 PERCENTAGE POPULATION INFECTED OF EACH COUNTRY PER DAY

SELECT location, population,date, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected DESC

--5 ROLLING PEOPLE VACCINATED OF EACH CONTINENT AND COUNTRY

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.date=vac.date
AND dea.location=vac.location
WHERE dea.continent IS NOT NULL


--6 PERCENTAGE PEOPLE VACCINATED


WITH POPVSVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.date=vac.date
AND dea.location=vac.location
WHERE dea.continent IS NOT NULL-- AND DEA.location LIKE '%CANADA%'
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM POPVSVAC
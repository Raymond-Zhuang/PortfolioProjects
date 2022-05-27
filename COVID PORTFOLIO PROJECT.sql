SELECT * 
FROM CovidDeaths
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2

--Looking at total case vs population
--Shows what percentage of population got covid

SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2



--Looking at countries with highest infection rate compared of population 

SELECT location,population ,MAX(total_cases) AS HIghestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%canada%'
GROUP BY population, location
ORDER BY PercentagePopulationInfected DESC

--Showing the country with the Highest Death count per population 

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%canada%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%canada%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--showing continents with the hight death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%canada%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(NEW_DEATHS AS int)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY  TOTAL_CASES

--looking at total population vs vaccinations

--use CTE

WITH PopvsVac (Continent,location, date, population, new_vaccinations, RollingpeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
join
    PortfolioProject..CovidVaccinations as vac
on
    dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100 
FROM PopvsVac
--WHERE location LIKE '%canada%' AND new_vaccinations IS NOT NULL


--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
join
    PortfolioProject..CovidVaccinations as vac
on
    dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * , (RollingPeopleVaccinated/population)*100 
FROM #PercentagePopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PopvsVac
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
join
    PortfolioProject..CovidVaccinations as vac
on
    dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



SELECT * 
FROM PopvsVac


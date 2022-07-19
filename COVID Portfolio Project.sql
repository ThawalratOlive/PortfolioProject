SELECT *
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4


--SELECT *
--FROM Portfolio..CovidVaccinates
--ORDER BY 3,4

--SELECT Data that we are goinh to be using

SELECT Location, date, total_cases, total_deaths, population
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- looking at Total casesvs Total Death
-- Show likelihood of dying if you contact in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location like '%Thai%'
ORDER BY 1,2

--looking at Total Cases vs population
-- show what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulation
FROM Portfolio..CovidDeaths
--WHERE location like '%Thai%'
WHERE continent is not NULL
ORDER BY 1,2


--looking ffor Countries with Highest Infection Rate compared to Population

SELECT Location, Population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM Portfolio..CovidDeaths
--WEHRE location like '%Thai%'
WHERE continent is not NULL
GROUP by Location, Population
ORDER BY PercentagePopulationInfected desc


--showing countries with highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
--WEHRE location like '%Thai%'
WHERE continent is not NULL
GROUP by Location
ORDER BY TotaldeathCount desc

-- LET'S BREAK DOWN BY CONTINENT
-- showing the continent with highest death count per population

SELECT continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
--WEHRE location like '%Thai%'
WHERE continent is NULL
GROUP by continent
ORDER BY TotaldeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
--WEHRE location like '%Thai%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2


-- looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
-- (RollingPeopleVaccinated/Poupulation)*100
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


--USE CTE

with PopvsVac (continent,Location,date,Population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
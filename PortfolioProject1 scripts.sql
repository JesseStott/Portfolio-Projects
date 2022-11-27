
--Basic queries to show each table
SELECT * 
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


SELECT * 
FROM [Portfolio Project 1]..CovidVaccinations
ORDER BY 3,4;

--Columns that pertain to this project from CovidDeaths

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Project 1]..CovidDeaths
ORDER BY 1,2;


--Looking at total cases versus total deaths
--Shows likelyhood of death if you catch Covid "in the US"

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;


--Looking at total cases versus population
--Shows likelyhood of catching Covid relative to the population "in the US"

SELECT Location, date, total_cases, total_deaths, population,(total_cases/population)*100 AS InfectionPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;


--Looking at which countries have the highest infection percentage

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project 1]..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;

--Looking at countries with highest death count per population
--Shows how likely you are to die from Covid relative to population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breaking data down by continents

--Showing continents with the highest death count

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breaking down data globally

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at total population versus vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinated
--(RollingTotalVaccinated/population)*100
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinated
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingTotalVaccinated/population)*100 AS PercentagePopulationVaccinated
FROM PopvsVac
ORDER BY 1,2;

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinated
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingTotalVaccinated/population)*100 AS PercentagePopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 1,2;

--Creating View to store data for future visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinated
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;
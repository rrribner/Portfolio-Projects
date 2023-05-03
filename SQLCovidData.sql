SELECT *
FROM [SQL Portfolio - COVID]..CovidDeaths
WHERE location = 'World';

ALTER TABLE [SQL Portfolio - COVID]..CovidVaccinations
ALTER COLUMN new_vaccinations float;

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [SQL Portfolio - COVID]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 as PercentageDeath
FROM [SQL Portfolio - COVID]..CovidDeaths
WHERE continent <> ''
GROUP BY location, population
ORDER BY HighestDeathCount DESC;

--LETS BREAK THIS DOWN BY CONTINENT

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM [SQL Portfolio - COVID]..CovidDeaths
WHERE continent = '' OR continent = null
GROUP BY location
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM [SQL Portfolio - COVID]..CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1 


--COVID_Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
FROM [SQL Portfolio - COVID]..CovidDeaths dea
JOIN [SQL Portfolio - COVID]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3

--USE CTE
WITH PopvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [SQL Portfolio - COVID]..CovidDeaths dea
JOIN [SQL Portfolio - COVID]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
FROM PopvsVAC

--TEMPTABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM [SQL Portfolio - COVID]..CovidDeaths dea
JOIN [SQL Portfolio - COVID]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''

SELECT *, (rollingPeopleVaccinated/population)*100 as PercentageVaccinated
FROM #PercentagePopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM [SQL Portfolio - COVID]..CovidDeaths dea
JOIN [SQL Portfolio - COVID]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
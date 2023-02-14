--Database (CovidProject) consists of 
--two tables (CovidDeaths and CovidVaccinations)
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions
-- ,Creating Views, Converting Data Types

SELECT *
FROM CovidProject..CovidDeaths
ORDER BY location, date

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY location, date

-- Total Cases per Country sorted by Country
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.dbo.CovidDeaths
ORDER BY 1,2


-- Canada case
SELECT date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY date 

-- Deathrate in Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathrate
FROM CovidProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Percentage of population with Covid Case  in World
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Countries with Highest infection rate by population
SELECT location, population, MAX(total_cases) as TotalCountryCase , MAX(total_cases/population)*100 as InfectionPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- Countries with Highest Death
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- View of Continents with Highest Death
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global cases, deaths and deathrate
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
		SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
			SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY
			cd.location,cd.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths cd JOIN CovidProject..CovidVaccinations cv
		ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3



-- WITH CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
			SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY
			cd.location,cd.date) AS RollingPeopleVaccinated
	FROM CovidProject..CovidDeaths cd JOIN CovidProject..CovidVaccinations cv
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY
	cd.location, cd.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths cd JOIN CovidProject..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date


-- Creating View for later visualizations
CREATE VIEW PerPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
		SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY
		cd.location, cd.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths cd JOIN CovidProject..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PerPopulationVaccinated





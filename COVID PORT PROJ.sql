SELECT *
  FROM [Portfolio Project]..CovidDeaths
 WHERE continent is not null
 ORDER BY 3,4

 --SELECT *
 -- FROM [Portfolio Project]..CovidVaccinations
 --ORDER BY 3,4

 -- Select Data

 SELECT location, date, total_cases, new_cases, total_deaths, population
   FROM [Portfolio Project]..CovidDeaths
  ORDER BY 1,2

  -- Looking at Total Cases vs Total Deaths
  -- Displays likelihood of dying by contracting covid in United States

  SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
   FROM [Portfolio Project]..CovidDeaths
  WHERE location like '%states%'
  ORDER BY 1,2

  -- Looking at Total Cases vs Population
  -- Shows what percentage of population contracted covid

 SELECT location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
   FROM [Portfolio Project]..CovidDeaths
 -- WHERE location like '%states%'
  ORDER BY 1,2

-- Countries with Highest Infection Rate per Population
 
 SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
   FROM [Portfolio Project]..CovidDeaths
 -- WHERE location like '%states%'
  GROUP BY location, population
  ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

 SELECT location, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
   FROM [Portfolio Project]..CovidDeaths
 -- WHERE location like '%states%'
  WHERE continent is not null
  GROUP BY location
  ORDER BY TotalDeathCount desc

 -- Continent with Highest Death Count per Population

 SELECT location, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
  FROM [Portfolio Project]..CovidDeaths
 -- WHERE location like '%states%'
 WHERE continent is null AND location not like '%income%' and location not like '%union%' and location not like '%international%'
 GROUP BY location
 ORDER BY TotalDeathCount desc


 -- Continents with Highest Infection Rate per Population

 SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
   FROM [Portfolio Project]..CovidDeaths
 -- WHERE location like '%states%'
  WHERE continent is null AND location not like '%income%' and location not like '%union%' and location not like '%international%'
  GROUP BY location, population
  ORDER BY PercentPopulationInfected desc


-- Global Breakdown

 SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS bigint)) AS total_deaths, SUM(new_cases) / SUM(cast(new_deaths AS bigint)) * 100 AS DeathPercentage
   FROM [Portfolio Project]..CovidDeaths
  WHERE location like '%world%'
  GROUP BY date
  ORDER BY 1,2

  -- Total Population vs Vaccinations

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
 -- , (RollingVaccinationNumber/population)*100
    FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
	  ON dea.location = vac.location
	 AND dea.date = vac.date
	WHERE dea.continent is not null AND dea.location not like '%income%' and dea.location not like '%union%' and dea.location not like '%international%'
   ORDER BY 1,2,3

   -- USE CTE

   WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationNumber)
     AS 
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
 -- , (RollingVaccinationNumber/population)*100
    FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
	  ON dea.location = vac.location
	 AND dea.date = vac.date
	WHERE dea.continent is not null AND dea.location not like '%income%' and dea.location not like '%union%' and dea.location not like '%international%'
--    ORDER BY 1,2,3
   )
SELECT * , (RollingVaccinationNumber/Population) *100 AS PercentVaccinated
  FROM PopVsVac


  -- USE TEMP TABLE (SAME AS ABOVE)

  DROP TABLE IF exists #PercentPopulationVaccinated
  CREATE TABLE #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingVaccinationNumber numeric
  )

  INSERT INTO #PercentPopulationVaccinated
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
 -- , (RollingVaccinationNumber/population)*100
    FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
	  ON dea.location = vac.location
	 AND dea.date = vac.date
	WHERE dea.continent is not null AND dea.location not like '%income%' and dea.location not like '%union%' and dea.location not like '%international%'
 -- ORDER BY 1,2,3

 SELECT * , (RollingVaccinationNumber/Population) *100 AS PercentVaccinated
  FROM #PercentPopulationVaccinated


  -- View to store data for viz

  CREATE VIEW PercentPopulationVaccinated AS
      SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
 -- , (RollingVaccinationNumber/population)*100
    FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
	  ON dea.location = vac.location
	 AND dea.date = vac.date
	WHERE dea.continent is not null AND dea.location not like '%income%' and dea.location not like '%union%' and dea.location not like '%international%'
   -- ORDER BY 2,3
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

USE PortfolioProject
--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER by 3, 4

--SELECTING DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, ROUND(total_deaths / total_cases * 100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY location, date


--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population, total_cases, ROUND(total_cases / population * 100, 2) AS PercentPopulationInfected
FROM CovidDeaths
ORDER BY location, date


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMEBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, (SUM(cast (new_deaths as int))/SUM(new_cases)*100) as Death_Percentage
FROM CovidDeaths
--where location = 'india'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--USE CTE
WITH CTE_PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (SELECT
  dea.continent,
  dea.location,
  dea.date,
  population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --and dea.location = 'india'
--order by 2,3
)
SELECT
  RollingPeopleVaccinated / population * 100 AS Expr1,
  *
FROM CTE_PopvsVac


--TEMP TABLE
DROP TABLE IF exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)


INSERT INTO PercentPopulationVaccinated
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT
  *,
  (RollingPeopleVaccinated / population) * 100
FROM PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated
AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT
  *
FROM PercentPopulationVaccinated
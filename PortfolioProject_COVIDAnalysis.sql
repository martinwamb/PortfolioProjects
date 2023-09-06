

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--select data that we are going to be using

SELECT location,date, total_cases,new_cases, total_deaths, population
FROM CovidDeathsTable
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location,date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM CovidDeathsTable
WHERE location = 'Kenya'
ORDER BY 1,2 

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location,date,  population, total_cases, ((CONVERT(float, total_cases)) / (CONVERT(float, population)) * 100) AS CasesVsPopulation
FROM PortfolioProject..CovidDeathsTable
WHERE location = 'Kenya'
ORDER BY 1,2 

--Looking at Countries with highest infection rate compared to population

SELECT location,  population, MAX(total_cases) as HighestInfectionCount, ((CONVERT(float, MAX(total_cases))) / (CONVERT(float, population)) * 100) AS PercentPopulationInfection
FROM PortfolioProject..CovidDeathsTable
--WHERE location = 'Kenya'
Group by location, population
ORDER BY PercentPopulationIfection DESC

-- CREATE A TEMP_TABLE WITH THE RATIO OF INFECTION AGAINST POPULATION

DROP TABLE IF EXISTS #temp_InfectionVsPopulation
CREATE TABLE #temp_InfectionVsPopulation (
location varchar(100)
, population bigint
, HighestInfectionCount bigint
, PercentPopulationInfection int
)

INSERT INTO #temp_InfectionVsPopulation
SELECT location,  population, MAX(total_cases) as HighestInfectionCount, ((CONVERT(float, MAX(total_cases))) / (NULLIF(CONVERT(float, population),0) * 100)) AS PercentPopulationIfection
FROM PortfolioProject..CovidDeathsTable
--WHERE location = 'Kenya'
Group by location, population
ORDER BY PercentPopulationIfection DESC

--COMPARE THE CONTINENT THAT EXPERIENCED THE HIGHEST INFECTION RATE AGAINST THEIR POPULATION

SELECT continent, PercentPopulationInfection
FROM PortfolioProject..CovidDeathsTable Covd
JOIN #temp_InfectionVsPopulation IP
	ON Covd.location = IP.location
GROUP BY continent, PercentPopulationInfection 

-- Comparing Population infection, population death and population vaccination

SELECT vac.location, vac.population, PercentPopulationInfection, (MAX(vac.total_vaccinations)/vac.population) as PercentPopulationVaccination, MAX(CAST(vac.total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidVaccinations Vac
JOIN #temp_InfectionVsPopulation
	ON Vac.location = #temp_InfectionVsPopulation.location
GROUP BY vac.location, vac.population, PercentPopulationInfection
ORDER BY 3,4,5  


-- Showing Countries with highest Death Count per Population
SELECT location,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeathsTable
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount DESC


--BREAK THINGS DOWN BY CONTINENT 
SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeathsTable
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC

-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeathsTable
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as TotalCases,  SUM(CAST (new_deaths as int)) as TotalDeaths, (SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeathsTable
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--Looking at total Population versus vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeathsTable dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeathsTable dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Creating View to Store Data for Later Visualizations 

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeathsTable dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

SELECT *
FROM PercentPopulationVaccinated

SELECT *
FROM Portfolio_Project..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

--SELECT Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_Project..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE location like'%Jordan%'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
WHERE location like'%Jordan%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

--Showing countries with highest death count per population

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--Global Numbers

SELECT  date, SUM(new_cases) as Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT  SUM(new_cases) as Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View To Store Data For Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
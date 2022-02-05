SELECT *
FROM PortofolioProject..CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location,date, total_cases, new_cases,total_deaths, population
From PortofolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in Indonesia 
SELECT Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
From PortofolioProject..CovidDeaths
WHERE location like 'Indonesia'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

SELECT Location,date,population, total_cases,(total_cases/population)*100 AS InfectionPercentage
From PortofolioProject..CovidDeaths
WHERE location like 'Indonesia'
ORDER BY 1,2

-- Looking at Contries with highest Infection Rate compared to Populations

SELECT Location,population,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
From PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
From PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continent
-- Showing the continent with the highest death count

SELECT continent,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
From PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) as TotalCases ,SUM(CAST(new_deaths AS int)) AS TotalDeaths ,SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 as DeathPercentage
From PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking as Total Population VS Vaccination
WITH PopvsVac(Continent,Location,Date,Population, New_Vaccinations,RollingPeopleVaccinated)
AS
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Create View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

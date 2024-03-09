select * 
from Project..CovidDeaths
order by 3,4
select * 
from Project..CovidVaccinations
order by 3,4
----------Select data that are going be using-
select location,
date,total_cases,
	new_cases,
	total_deaths,
	population
from 
	Project..CovidDeaths
order by 1,2
---looking at total_cases and total_deaths % dead--
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths /total_cases)*100 as DeathPercentage
from 
	Project..CovidDeaths
where 
	location like '%VietNam%'
order by 
	1,2
---Looking  at Total Case vs population
select location,
	date,
	total_cases,
	population, 
	(total_cases /population)*100 as DeathPercentage
from 
	Project..CovidDeaths
where 
	location like '%VietNam%'
order by 
	1,2
----Looking at countries with highest infection rate compared  to population
SELECT
    location,
    date,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases/population))*100 as PercentPopulationInfected
FROM
    Project..CovidDeaths
--WHERE location LIKE '%VietNam%'
GROUP BY
    location, population, date
ORDER BY
    PercentPopulationInfected DESC;
--SHOWING COUNTRY with highest death
SELECT 
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount,
    population
FROM 
    Project..CovidDeaths
WHERE
	continent is not null
GROUP BY 
    location, population
ORDER BY 
    TotalDeathCount DESC;
---- CLASSIFICATION BY CONTINENT
SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM 
    Project..CovidDeaths
-- Where the location is like '%states%'
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeaths DESC;
---- GLOBAL NUMBERS
SELECT
	date,
	SUM(new_cases) as totals_case,SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)
	*100  as DeathPecentage--,
FROM 
	Project..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	date
ORDER BY 
	1,2
---------------
DROP TABLE IF	 exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC,
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location ,dea.date)
	as RollingPeopleVaccinated
FROM 
	Project..CovidVaccinations vac
JOIN 
	Project..CovidDeaths dea
ON
	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

--ORDER BY 2,3
SELECT *
FROM #PercentPopulationVaccinated
------CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS-----
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location ,dea.date)
	as RollingPeopleVaccinated
FROM 
	Project..CovidVaccinations vac
JOIN 
	Project..CovidDeaths dea
ON
	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

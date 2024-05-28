select* from CovidDeaths;
select * from CovidVaccinations;
select * from Nashville;

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2
-- looking at total cases vs total deaths
--likelihood of dying from the covid 
select location,date,total_cases,total_deaths, 
(total_deaths/total_cases)*100 as deathRate
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population

select location,population, MAX(total_cases) AS highInfection,
MAX((total_cases)/population)*100 as percentpopulationInfected
from CovidDeaths
--where location like '%states%'
group by location,population
order by percentpopulationInfected desc

--countries withe the highest death  coiunt per population
select location, MAX(cast(total_deaths as int)) AS totalDeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totalDeathcount desc
-- lets breat it by cintinent
select location, MAX(cast(total_deaths as int)) AS totalDeathcount
from CovidDeaths
where continent is null
group by location
order by totalDeathcount desc
--this is showing the continent with highest count per population
select continent , MAX(cast(total_deaths as int)) AS totalDeathcount
from CovidDeaths
where continent is not null
group by continent
order by totalDeathcount desc
--breakijng numbers
 select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as deathParcentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as
rollingpeoplevaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location =vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3
 --use cte
 with popVSVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated )
 AS
 (
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as
rollingpeoplevaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location =vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(rollingpeoplevaccinated/population)*100 
FROM popVSVac
--tep tabel 
drop table if exists #percentPopulatioVaccinated
CREATE Table #percentPopulatioVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentPopulatioVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as
rollingpeoplevaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location =vac.location
AND dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *,(rollingpeoplevaccinated/population)*100
FROM #percentPopulatioVaccinated

--create views
CREATE VIEW percentPopulatioVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as
rollingpeoplevaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location =vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT * FROM PercentPopulationVaccinated
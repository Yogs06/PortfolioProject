select * from [SampleSQLPortfolio]..CovidDeaths$

--select * from [dbo].[CovidVaccinations$]

--Looking at total cases vs total death

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from [SampleSQLPortfolio]..CovidDeaths$
where location like '%philippines%' order by 1, 2

--Looking at total cases vs population
select location, max(population),max(total_cases), max((total_cases/population))*100 as PercentPopulationInfected
from [SampleSQLPortfolio]..CovidDeaths$
where continent is not null group by location order by 1, 2


--Countries with highes infection rate vs population


select location, population,max (total_cases)as HighestInfectionCount, max ((total_cases/population))*100 as PercentPopulationInfected
from [SampleSQLPortfolio]..CovidDeaths$ group by location, population order by 4 desc

--Countries with highest deathpercentage  vs population

select location, population,max (total_deaths)as HighestDeathCount, max ((total_deaths/population))*100 as DeathPopulationPercentage
from [SampleSQLPortfolio]..CovidDeaths$ where continent is not null
group by location, population order by 4 desc

--Countries with highest death count vs population

select location, max(cast (total_deaths as int))as TotalDeathCount
from [SampleSQLPortfolio]..CovidDeaths$ where continent is not null
group by location order by 2 desc

--Continents with highest death count

select continent, max(cast (total_deaths as int))as TotalDeathCount
from [SampleSQLPortfolio]..CovidDeaths$ where continent is not null
group by continent order by 2 desc

--Global Numbers


select  SUM(new_cases) as TotalNewCase,SUM(cast(new_deaths as int))as TotalNewDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalNewDeathPercentage--total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from [SampleSQLPortfolio]..CovidDeaths$
where continent is not null

-- looking at total vaccination vs population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- (RollingPeopleVaccinated/dea.population)*100
from [SampleSQLPortfolio].[dbo].CovidDeaths$ dea
join [SampleSQLPortfolio].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by  2 ,3 

-- use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- (RollingPeopleVaccinated/dea.population)*100
from [SampleSQLPortfolio].[dbo].CovidDeaths$ dea
join [SampleSQLPortfolio].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2 ,3 
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Data Datetime,
Population  numeric,
New_Vaccination  numeric,
RollingVaccinated  numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- (RollingPeopleVaccinated/dea.population)*100
from [SampleSQLPortfolio].[dbo].CovidDeaths$ dea
join [SampleSQLPortfolio].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2 ,3 

Select *, (RollingVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view for later visualization

create view #PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- (RollingPeopleVaccinated/dea.population)*100
from [SampleSQLPortfolio].[dbo].CovidDeaths$ dea
join [SampleSQLPortfolio].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2 ,3 

Select * from #PercentPopulationVaccinated
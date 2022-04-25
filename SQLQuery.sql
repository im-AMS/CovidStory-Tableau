-- test import
select top 100 *
from PortfolioProjects..CovidDeaths
order by 3,4

select top 100 *
from PortfolioProjects..CovidVaccinations
order by 3,4

-- =============================================================================================================================================================================

-- select data which we are using
select top 100
    location, date, total_cases, new_cases, total_deaths, population
    from PortfolioProjects..CovidDeaths
order by 1,2

-- =============================================================================================================================================================================


-- Total cases vs Total Deaths
-- Its likelyhood of dieing if you get infected.
select
    location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as decimal)/total_cases )*100 '%_death_to_total_cases'
from PortfolioProjects..CovidDeaths
where location like 'india'
order by 1,2

-- =============================================================================================================================================================================

-- DEATH Percentage
drop view if exists DeathPercentage
create view DeathPercentage as
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProjects..CovidDeaths as a
where continent is not null
-- group by location

-- =============================================================================================================================================================================

-- Total Cases vs Population
-- % of population with covid
select
    location, date, population, total_cases, total_deaths, (total_cases/population )*100 '%_cases_to_population'
from PortfolioProjects..CovidDeaths
where location like 'india'
order by 1,2

-- =============================================================================================================================================================================


-- Infected Percentage
Drop view if exists PercentInfectedByLocation
create view PercentInfectedByLocation as
select location,sum(a.new_cases) as TotalCasesCount, sum( a.new_cases)/max(a.population)*100 as wrtPopulation
from PortfolioProjects..CovidDeaths as a
where continent is not null
group by location

-- Using Max as a dummy aggregator since applying condition rank=1
select
    replace(a.location,'(country)','') as location, max(total_cases) as total_cases, max(population) as population, max(date) as date, max(PercentInfected) as PercentInfected
from(
        select
            CovidDeaths.location,
            CovidDeaths.continent,
            CovidDeaths.total_cases,
            CovidDeaths.population,
            CovidDeaths.date,
            ((CovidDeaths.total_cases/CovidDeaths.population)*100) as PercentInfected,
            rank()  over(partition by location order by ((CovidDeaths.total_cases/CovidDeaths.population)*100) desc ) as rank
        from PortfolioProjects..CovidDeaths
    ) as a
where a.rank = 1 and a.PercentInfected is not null and a.continent is not null
group by a.location, a.PercentInfected
-- order by a.PercentInfected desc

-- =============================================================================================================================================================================


-- TOTAL DEAD ===== Countries
Drop view if exists Dead_wrt_Population
create view Dead_wrt_Population as
select location,sum(a.new_deaths) as TotalDeathCount, sum( a.new_deaths)/max(a.population)*100 as wrtPopulation
from PortfolioProjects..CovidDeaths as a
where continent is not null
group by location

-- TOTAL DEAD ===== CONTINENT
select location,sum(a.new_deaths) as TotalDeathCount, sum( a.new_deaths)/max(a.population)*100 as wrtPopulation
from PortfolioProjects..CovidDeaths as a
where continent is null
group by location

-- =============================================================================================================================================================================

-- Give Dates, Location for top 5 new_case spikes
-- if multiple days of same new_spikes, show ONLY RECENT day

select location, max(a.total_cases) as total_cases, max(a.new_cases) as new_cases, max(a.date) as date, a.rank
from(
        select
            a.location,
            a.total_cases,
            a.new_cases,
            a.date,
            rank()  over(partition by location order by a.new_cases desc ) as rank
        from PortfolioProjects..CovidDeaths as a
    ) as a
where a.rank <=5 and a.new_cases is not null
group by a.location, a.rank
-- order by new_cases desc


-- =============================================================================================================================================================================

-- HIGHEST SPIKE ===== COUNTRIES
drop view if exists HighestDaySpike_Cases
create view HighestDaySpike_Cases as
select location, continent, total_cases, new_cases, NewCasesPercentOfPopulation, date
from(
        select
            a.location,
            a.continent,
            a.total_cases,
            a.new_cases,
            (a.new_cases/a.population) * 100 as NewCasesPercentOfPopulation,
            a.date,
            rank()  over(partition by location order by a.new_cases desc ) as rank
        from PortfolioProjects..CovidDeaths as a
    ) as b
where b.rank =1
  and b.new_cases is not null
  and b.continent is not null
-- order by new_cases desc

-- HIGHEST SPIKE ===== CONTINENT
select location, continent, total_cases, new_cases, NewCasesPercentOfPopulation, date, rank
from(
        select
            a.location,
            a.continent,
            a.total_cases,
            a.new_cases,
            (a.new_cases/a.population) * 100 as NewCasesPercentOfPopulation,
            a.date,
            rank()  over(partition by location order by a.new_cases desc ) as rank
        from PortfolioProjects..CovidDeaths as a
    ) as b
where b.rank =1
  and b.new_cases is not null
  and b.continent is null
order by new_cases desc


-- =============================================================================================================================================================================

-- Give Dates, Location for top 5 new deaths spikes
-- if multiple days of same new_deaths, show ONLY RECENT day

select location, max(a.total_cases) as total_cases, max(a.new_deaths) as new_deaths, max(a.date) as date, a.rank
from(
        select
            a.location,
            a.total_cases,
            a.new_deaths,
            a.date,
            rank()  over(partition by location order by a.new_deaths desc ) as rank
        from PortfolioProjects..CovidDeaths as a
    ) as a
where a.rank <=5 and a.new_deaths is not null
group by a.location, a.rank

-- HIGHEST DEATH SPIKE ===== COUNTRIES
drop view if exists HighestDaySpike_Death
create view HighestDaySpike_Death as
select location, continent, total_cases, new_deaths, NewDeathsPercentOfPopulation, date
from(
        select
            a.location,
            a.continent,
            a.total_cases,
            a.new_deaths,
            (a.new_deaths/a.population) * 100 as NewDeathsPercentOfPopulation,
            a.date,
            rank()  over(partition by location order by a.new_deaths desc ) as rank
        from PortfolioProjects..CovidDeaths as a
    ) as b
where b.rank =1
  and b.new_deaths is not null
  and b.continent is not null
-- order by new_deaths desc

-- HIGHEST DEATH SPIKE ===== CONTINENT
select location, continent, total_cases, new_deaths, NewDeathsPercentOfPopulation, date, rank
from(
        select
            a.location,
            a.continent,
            a.total_cases,
            a.new_deaths,
            (a.new_deaths/a.population) * 100 as NewDeathsPercentOfPopulation,
            a.date,
            rank()  over(partition by location order by a.new_deaths desc ) as rank
        from PortfolioProjects..CovidDeaths as a
    ) as b
where b.rank =1
  and b.new_deaths is not null
  and b.continent is null
order by new_deaths desc

-- =============================================================================================================================================================================

-- Global new_cases by date

select a.date, sum(a.new_cases) as new_cases, sum(a.new_deaths) as new_deaths
from PortfolioProjects..CovidDeaths as a
where a.location = 'World'
group by a.date
order by new_cases DESC

-- Global new_deaths by date

select a.date, sum(a.new_cases) as new_cases, sum(a.new_deaths) as new_deaths
from PortfolioProjects..CovidDeaths as a
where a.location = 'World'
group by a.date
order by new_deaths DESC

-- Global new_cases by date AS Percent

-- using max as dummy aggregator for population
select a.date, (sum(a.new_cases)/max(a.population)) * 100 as CasesPercent, (sum(a.new_deaths)/max(a.population)) * 100 as DeathPercent
from PortfolioProjects..CovidDeaths as a
where a.location = 'World'
group by a.date
order by CasesPercent DESC

-- Global new_cases by date AS Percent

-- using max as dummy aggregator for population
select a.date, (sum(a.new_cases)/max(a.population)) * 100 as CasesPercent, (sum(a.new_deaths)/max(a.population)) * 100 as DeathPercent
from PortfolioProjects..CovidDeaths as a
where a.location = 'World'
group by a.date
order by DeathPercent DESC

-- =============================================================================================================================================================================
-- =============================================================================================================================================================================

-- total FULLY vaccinated

select d.location, sum(v.new_vaccinations) as people_fully_vaccinated
--      , (sum(v.people_fully_vaccinated)/ max(d.population))*100 as PercentOfPopulation
from PortfolioProjects..CovidDeaths as d
join PortfolioProjects..CovidVaccinations as v
on d.location = v.location
and d.date = d.date
where d.continent is not null
group by d.location


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null















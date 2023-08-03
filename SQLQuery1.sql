
--select data we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeathinfo
order by 1,2;

--convert the column total_cases to float
select * from PortfolioProject..coviddeathinfo
EXEC sp_help 'dbo.coviddeathinfo';
ALTER TABLE dbo.coviddeathinfo
ALTER COLUMN total_cases float


--calculate the death percentage of total cases in Nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..coviddeathinfo
where location like '%Nigeria%'
order by 1,2;

--calculate the percentage by total population that has covid in nigeria

create view percentageofinfected as 
select location, date,population, total_cases,  (total_cases/population)*100 as infectedpopulationpercentage
from PortfolioProject..coviddeathinfo


--looking for countries with the highest infection rate compared to population
create view infectionrate as
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as infectedpopulationpercentage
from PortfolioProject..coviddeathinfo
--where location like '%Nigeria%'
where continent is not null
group by location,population
--order by infectedpopulationpercentage desc

--countries with the highest death

select location, MAX(cast(total_deaths as int)) as totaldeathcount from PortfolioProject..coviddeathinfo
where continent is not null
group by location
order by totaldeathcount desc;

--Continent with the highest death
Create view highestdeath as
select continent, max(cast(total_deaths as int)) as totaldeathcount from PortfolioProject..coviddeathinfo
where continent is not null
group by continent
--order by totaldeathcount desc;

--Global Numbers
create view GlobalNumbers as
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, SUM(new_deaths)/SUM(new_cases)*100 as percentage
from PortfolioProject..coviddeathinfo
where continent is not null


--Joining the two tables

select * from PortfolioProject..coviddeathinfo dea
join PortfolioProject..covidvaccination vac
on
dea.location = vac.location
and
dea.date = vac.date

--comparing total population with total vaccination witht CTE

with PopvsVac(continent,date,location,population, New_vaccination,rollingpeoplevaccinated )
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeathinfo dea
join PortfolioProject..covidvaccination vac
on
dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 
from PopvsVac

--Create temporary table
DROP Table if exists #percentpopulatedvaccination
create table #percentpopulatedvaccination
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations bigint,
rollingpeoplevaccinated numeric
)

insert into #percentpopulatedvaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeathinfo dea
join PortfolioProject..covidvaccination vac
on
dea.location = vac.location
and
dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 
from #percentpopulatedvaccination

--creating View to store data for visualization
create view percentpopulatedvaccination as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeathinfo dea
join PortfolioProject..covidvaccination vac
on
dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null
--order by 2,3





select * 
from PortfolioProjects..coviddeaths
where continent is not NULL
order by 3,4


--select * 
--from PortfolioProjects..covidvaccinations
--order by 3,4

--lets select the data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..coviddeaths
where continent is not NULL
order by 1,2


--looking at Total cases vs Total deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..coviddeaths
where continent is not NULL
order by 1,2

--shows the liklihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..coviddeaths
where location like 'nigeria' and continent is not NULL
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..coviddeaths
where location like '%states%' and continent is not NULL
order by 1,2

--looking at the Total cases vs Population

--shows what percntage of the population got covid

select location, date, population,  total_cases, (total_cases/population)*100 as PopulationPercentage
from PortfolioProjects..coviddeaths
where location like '%states%' and continent is not NULL
order by 1,2


select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
from PortfolioProjects..coviddeaths
where location like 'nigeria' and continent is not NULL
order by 1,2

--Looking at Countries with highest infection rate Compared to Population 

select location, population,  max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
PercentagePopulationInfected
from PortfolioProjects..coviddeaths
where continent is not NULL
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc

--Countries with Highest Deeath Count Per Population

select location, Max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProjects..coviddeaths
--where location like '%states%'
where continent is not NULL
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENTS


select location, Max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProjects..coviddeaths
--where location like '%states%'
where continent is NULL
group by location
order by TotalDeathCount desc

--Showing the Cntinent with the Highest Death Count per Population

select continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProjects..coviddeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS


select  date, Sum(new_cases) as  Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100
as DeathPercentage
from PortfolioProjects..coviddeaths
--where location like 'nigeria' 
Where continent is not NULL
Group by date
order by 1,2

select  Sum(new_cases) as  Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100
as DeathPercentage
from PortfolioProjects..coviddeaths
--where location like 'nigeria' 
Where continent is not NULL
--Group by date
order by 1,2

--JOINING BOTH TABLES
--Looking at Total Ppulation VS Vaccinations


select *
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Modification/Alterations
Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not NULL
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3

select *
From PercentPopulationVaccinated

select * from
Projectportfolio..CovidDeaths
Where continent is not null

select * from
Projectportfolio..CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
From Projectportfolio..CovidDeaths
Where continent is not null
order by 1, 2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Projectportfolio..CovidDeaths
Where location like '%states%' AND
continent is not null
order by 1, 2

--Looking at Total cases vs population
--Shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationinfected
From Projectportfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1, 2

--Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) AS HighestinfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationinfected
From Projectportfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentagePopulationinfected desc

--Showing Countries with Highest Death counts per Population

select location, MAX(cast(total_deaths as int)) AS TotalDeathCounts
From Projectportfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCounts desc



--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCounts
From Projectportfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCounts desc

--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Projectportfolio..CovidDeaths
where continent is not null
--Group By date 
order by 1,2


--Looking at Total population vs Vaccinations
select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated,
--(Rollingpeoplevaccinated/population)*100
from Projectportfolio..CovidDeaths as dea
Join Projectportfolio..CovidVaccinations as vac
 ON dea.location = vac.location AND
 dea.date = vac.date
 where dea.continent is not null
Order by 2,3

--CTE

With PopvsVac (continent, location, population, date, new_vaccinations, Rollingpeoplevaccinated)
as
(
select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from Projectportfolio..CovidDeaths as dea
Join Projectportfolio..CovidVaccinations as vac
 ON dea.location = vac.location AND
 dea.date = vac.date
 where dea.continent is not null
--Order by 2,3
)
select *,  (Rollingpeoplevaccinated/cast(population as int))*100
from PopvsVac 




--Temp Table

create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #Percentpopulationvaccinated
select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from Projectportfolio..CovidDeaths as dea
Join Projectportfolio..CovidVaccinations as vac
 ON dea.location = vac.location AND
 dea.date = vac.date
 where dea.continent is not null
--Order by 2,3

select *,  (Rollingpeoplevaccinated/cast(population as int))*100
from #Percentpopulationvaccinated

--drop table if exists #Percentpopulationvaccinated

--creating view to store data for later visualization
Create view Percentpopulationvaccinated as
select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from Projectportfolio..CovidDeaths as dea
Join Projectportfolio..CovidVaccinations as vac
 ON dea.location = vac.location AND
 dea.date = vac.date
 where dea.continent is not null
--Order by 2,3

select * from Percentpopulationvaccinated

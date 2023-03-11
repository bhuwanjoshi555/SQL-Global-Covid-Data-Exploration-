select * from
PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null 
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract Covid 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2 


-- Looking at total cases vs population
-- Shows what percentage of poplation got Covid

select location,date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
Order by 1,2

-- Looking at countries with highest infection compared to population 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By location,population
Order by PercentPopulationInfected desc

-- Showing the countries with highest death count per population 

select location,MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By location
Order by TotalDeathCount desc

--  Breaking things down by continent
-- Showing continents with the highest death count per population

select continent,MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By date
Order by 1,2


-- Total Population VS Vaccinations
-- Shows Percentage of population that has received at least one Covid Vaccine

select d.continent, d.location, d.date, d.population,v.new_vaccinations,
 SUM(convert(int, v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
         on d.location = v.location
         and d.date = v.date
where d.continent is not null
order by 2,3


-- Using CTE to perform calculation on Partition By in previous query

With PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population,v.new_vaccinations,
 SUM(convert(int, v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
         on d.location = v.location
         and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 as Percentagevaccination
from PopvsVac


-- Using Temp Table to perform calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population,v.new_vaccinations,
 SUM(convert(int, v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
         on d.location = v.location
         and d.date = v.date
where d.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 as Percentagevaccination
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population,v.new_vaccinations,
 SUM(convert(int, v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
         on d.location = v.location
         and d.date = v.date
where d.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated
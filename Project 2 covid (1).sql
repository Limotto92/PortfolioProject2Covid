select *
from dbo.coviddeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

--Total Cases VS Total Deaths 
-- Death percentage = (total death/total cases)*100

Select location, date, total_cases, total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From dbo.CovidDeaths
Where location Like '%states%'
Order By 1,2

-- Total cases VS polulation
-- % populations contracted covid

Select location, date, population, total_cases,  (Cast(total_cases as float)/Cast(population as float))*100 as PercentagePopulationInfected
From dbo.CovidDeaths
Where population is not null 
Order By 1,2

-- Country with highest infected rates over population

Select location, population, total_cases, Max(total_cases) as HighestInfectionCount,Max((Cast(total_cases as float))/Cast(population as float))*100 as PercentagePopulationInfected
From dbo.CovidDeaths
Where population is not null 
Group by location,population, total_cases
Order By PercentagePopulationInfected DESC

-- Highest death count on country

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where population is not null and continent is not null
Group by location
Order By TotalDeathCount DESC

-- Highest death count by continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where population is not null and continent is not null
Group by continent
Order By TotalDeathCount DESC

-- Global
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
  (Sum(new_deaths)/Sum(new_cases))*100 as DeathPercentage  
From dbo.CovidDeaths
Where continent is not null
Order By 1,2


-- Total population over vaccination
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, Sum(Cast(v.new_vaccinations as bigint)) Over (Partition by d.location Order by d.location, d.date) as RollingPplVac
From dbo.CovidDeaths d
Join  dbo.CovidVaccination v on d.location=v.location 
And d.date=v.date
Where d.continent is not null and population is not null
Order by 2,3

--Use CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPplVac)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, Sum(Cast(v.new_vaccinations as bigint)) Over (Partition by d.location Order by d.location, d.date) as RollingPplVac
From dbo.CovidDeaths d
Join  dbo.CovidVaccination v on d.location=v.location 
And d.date=v.date
Where d.continent is not null and population is not null
)
Select *, (RollingPplVac/population)*100
From PopVsVac


-- Temp table 

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVac numeric
)

Insert into #PercentagePopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, Sum(Cast(v.new_vaccinations as bigint)) Over (Partition by d.location Order by d.location, d.date) as RollingPplVac
From dbo.CovidDeaths d
Join  dbo.CovidVaccination v on d.location=v.location 
And d.date=v.date
Where d.continent is not null and population is not null

Select *, (RollingPplVac/population)*100
From #PercentagePopulationVaccinated


-- creating view for visualisation 

Create View PercentagePopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, Sum(Cast(v.new_vaccinations as bigint)) Over (Partition by d.location Order by d.location, d.date) as RollingPplVac
From dbo.CovidDeaths d
Join  dbo.CovidVaccination v on d.location=v.location 
And d.date=v.date
Where d.continent is not null and population is not null

  
Select*
From PercentagePopulationVaccinated

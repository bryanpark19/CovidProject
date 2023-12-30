Select *
From ProjectCovid..CovidDeaths

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectCovid..CovidDeaths
order by 1,2

-- Total cases vs total deaths (death in countries per case)
-- likelihood of dying from getting COVID in a given country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From ProjectCovid..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Total cases vs population (percentage of population that got COVID)
Select Location, date, total_cases, Population, (CONVERT(float, total_cases) / NULLIF (CONVERT(float, population), 0))*100 as InfectionPercentage
From ProjectCovid..CovidDeaths
Where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From ProjectCovid..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected desc

--visualize above
Create View HighestInfectionRateVSPopulation_Countries as
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From ProjectCovid..CovidDeaths
Group by Location, Population
--order by PercentagePopulationInfected desc

--countries with highest death count vs population
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From ProjectCovid..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--visualize above
Create View HighestDeathCountVSPopulation_Countries as 
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From ProjectCovid..CovidDeaths
Where continent is not null
Group by Location
--order by TotalDeathCount desc

--BY CONTINENT

--real breakdown of continents
--continents with highest death count vs population
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From ProjectCovid..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--visualize above
Create View HighestDeathVSPopulation_Continents as
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From ProjectCovid..CovidDeaths
Where continent is null
Group by location
--order by TotalDeathCount desc

-- Continents with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/ population)*100 as PercentagePopulationInfected
From ProjectCovid..CovidDeaths
Where continent is null
Group by Location, Population
order by PercentagePopulationInfected desc

-- visualize above
Create View ContinentHighestInfectionRateVSPopulation as 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/ population)*100 as PercentagePopulationInfected
From ProjectCovid..CovidDeaths
Where continent is null
Group by Location, Population
--order by PercentagePopulationInfected desc



--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as float))/ NULLIF (SUM(cast(new_cases as float)), 0 )*100 as DeathPercentage
From ProjectCovid..CovidDeaths
where continent is not null
order by 1,2


--total population vs vaccinations
Select dea.continent, dea.location, dea.date, population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE

with PopulationvsVaccination (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate
From PopulationvsVaccination





--USE TEMP TABLE

drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate
From #PercentPopulationVaccinated



--visualize above
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


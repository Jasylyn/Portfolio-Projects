Select *
From CovidData..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2


-- Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
order by 1,2


-- Total Cases vs. Population
-- Shows what percentage of population infected with covid
Select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT


-- Continents with the Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order By TotalDeathCount desc


-- GLOBAL NUMBERS


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group By date
order by 1,2


-- Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as
	RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as
	RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as
	RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as
	RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
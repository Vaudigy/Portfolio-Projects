Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at the Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
group by Location, Population
order by PercentofPopulationInfected desc


--Showing Countries with Highest Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
group by Location, Population
order by TotalDeathCount desc

--Broken Down By Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is null
group by location
order by TotalDeathCount desc

-- Global Numbers

Select SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Lookin at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join[Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE

With PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join[Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join[Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join[Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3






Select *
From PorfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PorfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths$
Where continent is not null
and location like '%Nigeria%'
order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Group by continent, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count Per Population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From PorfolioProject..CovidDeaths$
--Where location like '%Nigeria%' 
where continent is not null
--Group By date
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent, Lacation, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated



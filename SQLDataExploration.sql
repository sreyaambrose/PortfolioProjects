select * 
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

-- select Data that we're going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contact covid in U.S
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2

--Looking at the Total Cases vs Population
select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by Population,Location
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by HighestDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT 
--Showing continents with the highest death count per population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by HighestDeathCount desc

--GLOBAL NUMBERS
select date,SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,2

--Join the 2 tables 
select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE : FIRST METHOD TO DISPLAY RollingPeopleVaccinatedPercentage
--Looking at Total Population vs Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
from PopvsVac

--TEM TABLE : SECOND METHOD TO DISPLAY RollingPeopleVaccinatedPercentage
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

insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage from #PercentPopulationVaccinated

--creating view to store data fpr later visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated  
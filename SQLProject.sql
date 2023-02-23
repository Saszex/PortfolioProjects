SELECT *
from PortoflioProject..CovidDeaths
order by 3,4

--SELECT *
--from PortoflioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortoflioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortoflioProject..CovidDeaths
Where location like '%Poland%'
order by 1,2

-- Looking at Total Cases vs Population

Select Location, date, total_cases,total_deaths,population, (total_cases/population)*100 as TotalPolandCases
from PortoflioProject..CovidDeaths
--Where location like '%Poland%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location,population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortoflioProject..CovidDeaths
--Where location like '%Poland%'
Group by Location,population
order by PercentPopulationInfected desc


-- Showing the Countries with highest Death Ratio per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortoflioProject..CovidDeaths
--Where location like '%Poland%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortoflioProject..CovidDeaths
--Where location like '%Poland%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from PortoflioProject..CovidDeaths
--Where location like '%Poland%'
where continent is not null
--Group by date
order by 1,2




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortoflioProject..CovidDeaths dea
Join PortoflioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortoflioProject..CovidDeaths dea
Join PortoflioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortoflioProject..CovidDeaths dea
Join PortoflioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *
FROM PercentPopulationVaccinated2
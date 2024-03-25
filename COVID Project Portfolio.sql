Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths DECIMAL(10, 2);

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases INT;

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population BIGINT;

Select Location, date, population, total_cases, (total_cases*100.0/population) as PerecentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Order by 1,2

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases*100.0/population))as PerecentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location, population
Order by PerecentPopulationInfected Desc

Select Continent, max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent	is not null
Group by Continent
Order by TotalDeathCount Desc


Select SUM(cast (new_cases as int)) AS total_cases, SUM(cast (new_deaths AS int)) as total_deaths, SUM(cast (new_deaths AS int))*100.0/SUM(cast (new_cases as int)) AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent	is not null
--Group by Date
Order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where Location like '%states%'
Where dea.Continent	is not null
Order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where Location like '%states%'
Where dea.Continent	is not null
Order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where Location like '%states%'
Where dea.Continent	is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated*100.0/Population)
From PopvsVac

DROP TABLE if exists #PercentPopulationVaccinated 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where Location like '%states%'
Where dea.Continent	is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated*100.0/Population)
From #PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where Location like '%states%'
Where dea.Continent	is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated


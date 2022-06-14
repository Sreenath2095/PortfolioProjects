

--Shows what percentage of population got covid
Select location,date,total_cases,Population,(total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1,2

-- Showing Continents with the highest death count
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location, population
order by TotalDeathCount desc
-- Global Numbers
Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(CAST (new_deaths AS int)) / SUM (new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null 
order by 1,2

-- Total Population vs vaccinations
-- USE of CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccination)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date =vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (rolling_vaccination/population)*100 Rollvacpercentage
from PopvsVac

-- TEMP TABLE
Drop Table if exists #percentpopulationvaccinated 
Create Table #percentpopulationvaccinated 
(
Continent nVarchar (255), 
Location nVarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vaccination numeric 
)

Insert Into #percentpopulationvaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date =vac.date
where dea.continent is not null
--order by 2,3

Select *, (rolling_vaccination/population) * 100
from #percentpopulationvaccinated

-- Creating Data to store visualisations for later

Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date =vac.date
where dea.continent is not null
--order by 2,3

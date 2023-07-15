Select *
From PortfolioProject..CovidDeaths
Order By 3,4


--Cases & Deaths 
Select Location, Date, total_cases , New_Cases,Total_deaths ,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- %age of people infected in a country = total_infected vs population 
Select Location,date,Population , total_cases total_infected, (total_cases/population)*100 as Infected_Percentage
from PortfolioProject..CovidDeaths
where location='united states' and continent is not null
Order by 1,2


-- %age of people dying = total_death vs the total_infected 
Select Location,date,total_cases total_infected,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location='india' and continent is not null
Order by 1,2


--Highest Infection Rates of a country comapred to population
Select Location,Population ,Max(date) as Date, Max(total_cases) total_infected, Max((total_cases/population))*100 as Infected_Percentage
from PortfolioProject..CovidDeaths
Where continent is not null
group by location,population
Order by location desc


--Highest Death %age of a country comapred to population 
Select Location,Population ,Max(date) as Date, Max(cast(total_deaths as int)) total_deaths, Max((total_deaths/population))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
Where continent is not null
group by location,population
Order by Death_Percentage desc


-- Death Counts Of a Country
Select Location, Max(cast(total_deaths as int)) total_deaths
from PortfolioProject..CovidDeaths
Where continent is not null
group by location
Order by total_deaths desc

--Deaths Counts By Continent
Select Location As Continents ,population, Max(cast(total_deaths as int)) total_deaths
from PortfolioProject..CovidDeaths
Where continent is null
group by location,population
Order by total_deaths 


--Global Numbers of Death %age per date
Select date, sum(new_cases) as Total_cases_perDate , sum( cast(new_deaths as int)) as Total_deaths_perDate , 
(sum( cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage_perDate
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2,3

--Total %age of Deaths compared to number of infection
Select sum(new_cases) as Total_cases_perDate , sum( cast(new_deaths as int)) as Total_deaths_perDate , 
(sum( cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage_perDate
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--%age of population vaccinated in a country 

--by CTE
with VaccinatedPop ( Continent,Location,Date,Population,New_Vaccinations,Total_vaccinated)
as
(
select Death.continent,Death.Location, death.date,Death.population, Vaccine.new_vaccinations, 
Sum(convert(int,Vaccine.new_vaccinations)) Over (Partition by Death.Location order by death.date) As Total_vaccinated
from PortfolioProject..CovidDeaths as Death
Join PortfolioProject..CovidVaccinations As Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.Date 
where Death.continent is not null
)
Select Location,Max(Total_vaccinated) As Total_People_Vaccinated, Max((Total_vaccinated/Population)*100) As PercentageVaccinated
from VaccinatedPop
Group by Location
Order By 3 Desc

--By Temp table
drop table if exists #temp_VaccinatedPopulation
Create table #temp_VaccinatedPopulation 
( Continent varchar(200),
Location Varchar(200),
date datetime,
Population numeric,
New_Vaccinations numeric,
Total_vaccinated numeric)

insert into #temp_VaccinatedPopulation
select Death.continent,Death.Location, death.date,Death.population, Vaccine.new_vaccinations, 
Sum(convert(int,Vaccine.new_vaccinations)) Over (Partition by Death.Location order by death.date) As Total_vaccinated
from PortfolioProject..CovidDeaths as Death
Join PortfolioProject..CovidVaccinations As Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.Date 
where Death.continent is not null

Select Location,Date,Population,New_Vaccinations,Total_vaccinated
from #temp_VaccinatedPopulation

Select Location,Max(Total_vaccinated) As Total_People_Vaccinated, Max((Total_vaccinated/Population)*100) As PercentageVaccinated
from #temp_VaccinatedPopulation
Group by Location
Order By 3 Desc

Create View temp_VaccinatedPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

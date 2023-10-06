--select data that we are going to use--
select * from COVID..CovidVaccination
order by 3,4

--select data that we are going to use--
select location, date, total_cases, new_cases, total_deaths, population
from COVID..CovidDeath
order by 1,2

--Looking at Total Cases vs Total Deaths
select location, date,population, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from COVID..CovidDeath
where location like 'I%a'
order by 1,2


--Looking at Total cases vs population--
--Shows what percentage of population got covid--
select location, date,population, total_cases, (NULLIF(CONVERT(float, total_cases) /(CONVERT(float,population)), 0)) * 100 AS Casepercentage
from COVID..CovidDeath
order by 1,2


--location from where high  number of cases came was 'WORLD'---
select top 1 location, Sum(NULLIF(CONVERT(float, total_cases), 0)) as sum_cases
from COVID..CovidDeath
GROUP BY location
order by sum_cases desc

--Showing countries with highest death count per population--
select top 1 location, MAX(cast(Total_deaths as int)) as Totaldeathcount
from COVID..CovidDeath
GROUP BY location
order by Totaldeathcount desc

--Looking at countries with highest infection  rate compared to population---(Cyprus)
select  location,population, MAX(Total_cases) as HighestInfectionRate,MAX((Total_cases/population))*100 as PercentPopulationInfected
from COVID..CovidDeath
--where location like 'I%a'--
GROUP BY location,population
order by PercentPopulationInfected desc

--Lets break things down by continent--
select continent , max(cast(total_deaths as int)) as totaldeathcount
from COVID..CovidDeath
where continent is not null
GROUP BY continent
order by Totaldeathcount desc

--Showing continents with the highest death count per population
select continent , max(cast(total_deaths as int)) as totaldeathcount, max((cast(total_deaths as int))/population)*100 as deathpercentage
from COVID..CovidDeath
where continent is not null
GROUP BY continent
order by deathpercentage desc

--GLOBAL NUMBERS  
SET ANSI_WARNINGS OFF;
GO
select date, SUM(new_cases) as total_cases,
Sum(NULLIF(CONVERT(int, new_deaths), 0))  as total_deaths,
Sum(NULLIF(CONVERT(int, new_deaths), 0))/SUM(new_cases)*100 as death_percentage
from COVID..CovidDeath
where continent is not null
group by date
order by 1,2


--Looking at total population vs vaccinations--
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from COVID..CovidDeath as dea
join COVID..CovidVaccination as vac
on dea.location = vac.location
where dea.continent is not null
and dea.date=vac.date
order by 1,2,3

--Looking at total population vs vaccinations without null values--
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from COVID..CovidDeath as dea
join COVID..CovidVaccination as vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3 

--Using of CTE for population vs vaccination
WITH PopvsVac (continent,location,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.population,vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from COVID..CovidDeath as dea
join COVID..CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
)
select  * ,(RollingPeopleVaccinated/Population)*100 as prct_roll_ppl
from PopvsVac

--Temp table--
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric
)
insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.population,vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from COVID..CovidDeath as dea
join COVID..CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 

select  * ,(RollingPeopleVaccinated/Population)*100 as prct_roll_ppl
from PercentPopulationVaccinated

--Creating View to store data for later visualizations--
--drop table if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.population,vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from COVID..CovidDeath as dea
join COVID..CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 






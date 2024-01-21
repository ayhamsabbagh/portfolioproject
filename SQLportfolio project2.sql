select *
from [portfolio project ]..CovidDeaths



--select *
--from [portfolio project ]..CovidVaccinations
--order by 3,4
--select data that we will be using
select continent,location,date,total_cases,new_cases,total_deaths,population
from [portfolio project ]..CovidDeaths
where continent is not null
order by 2,3




--The percentage of deaths of people with Corona disease
select continent,location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as dethspercentage
from [portfolio project ]..CovidDeaths
where continent is not null
order by 2,3

--what percentage of population got covid
select continent,location,date,population,total_cases,new_cases,total_deaths,(total_cases/population)*100 percentofpopulationinfected
from [portfolio project ]..CovidDeaths
where continent is not null
order by 2,3

--countries with the Highst Infection Rate compared to population
select continent,location,population,max(total_cases) Highstinfectioncount,max((total_cases/population))*100 as maxinfectionrate
from [portfolio project ]..CovidDeaths
where continent is not null
group by  continent,location,population
order by 2,maxinfectionrate desc


--lokking at countries with the Highst deaths rate
select continent,location,max(cast(total_deaths as int)) TotalDeathsCount
from [portfolio project ]..CovidDeaths
where continent is not null 
group by continent, location
order by TotalDeathsCount desc


--Breaking Things Down By Continent
select location as continent,max(cast(total_deaths as int)) TotalDeathsCount
from [portfolio project ]..CovidDeaths
where continent is null
group by  location
order by TotalDeathsCount desc



--The Highst deaths count Per population For World and Continent
select location as continent,population,max(total_deaths) DeathsCount,max((total_deaths/population))*100 as DeathsCountbyContinent
from [portfolio project ]..CovidDeaths
where continent is null and population is not null
group by  location,population
order by 2 desc, DeathsCountbyContinent desc


--total cases by the world and total deaths and deaths percantage
select location,date ,population,sum(total_cases) TotalCasesInTheWorld, sum(cast(total_deaths as int)) TotalDeathinTheWorld,sum(cast(total_deaths as int))/sum(total_cases) as PercantageOfDeathsInTheWorld 
from [portfolio project ]..CovidDeaths
where continent is null and location ='World'
group by  date,location,population
order by 2 asc

--joining tables
--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) as
rollingcountofpeoplevaccination
from [portfolio project ]..CovidDeaths dea
join [portfolio project ]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2 ,3 
--using cte
with popvsvac(continent,location,population,new_vaccination,rollingcountofpeoplevaccination )
as
(
select dea.continent,dea.location,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) 
as rollingcountofpeoplevaccination
from [portfolio project ]..CovidDeaths dea
join [portfolio project ]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,max(new_vaccination)over (partition by continent) ,(rollingcountofpeoplevaccination/population)*100
from popvsvac
group by continent,location,population,new_vaccination,rollingcountofpeoplevaccination
order by 2,6 desc




--temp table
DROP TABLE IF exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingcountofpeoplevaccination numeric)

insert into #percentpopulationvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) as
rollingcountofpeoplevaccination
from [portfolio project ]..CovidDeaths dea
join [portfolio project ]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2 ,3

select *,max(new_vaccinations)over (partition by continent) ,(rollingcountofpeoplevaccination/population)*100
from #percentpopulationvaccinated
group by continent,location,population,new_vaccinations,rollingcountofpeoplevaccination,date

--creating view
create view percentpeoplevaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) as
rollingcountofpeoplevaccination
from [portfolio project ]..CovidDeaths dea
join [portfolio project ]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2 ,3 
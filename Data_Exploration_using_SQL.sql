select * from Portfolio_Project..Covid_Deaths
where continent is not null
order by 3,4

--select * from Portfolio_Project..Covid_Vaccinations
--order by 3,4

--select data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..Covid_Deaths
where continent is not null
order by 1,2

--Looking at total_cases vs total_deaths
--Indicates likelihood of death if covid is contracted 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio_Project..Covid_Deaths
where location like 'India'
and continent is not null
order by 1,2

--Looking at total_cases vs population
--Shows what percentage has got covid
select location, date, population, total_cases, (total_cases/population)*100 as percentage_population_infected
from Portfolio_Project..Covid_Deaths
where location like 'India' and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_population_infected
from Portfolio_Project..Covid_Deaths
--where location like 'India'
where continent is not null
group by location, population
order by percentage_population_infected desc

--Countries with highest death count per population
select location, max(cast(total_deaths as int)) as total_death_count
from Portfolio_Project..Covid_Deaths
--where location like 'India'
where continent is not null
group by location
order by total_death_count desc

--Breaking things down by continent
select continent, max(cast(total_deaths as int)) as total_death_count
from Portfolio_Project..Covid_Deaths
--where location like 'India'
where continent is not null
group by continent
order by total_death_count desc

--Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Portfolio_Project..Covid_Deaths
--where location like 'India'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Portfolio_Project..Covid_Deaths
--where location like 'India'
where continent is not null

--Total population vs vaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(int, vaccinations.new_vaccinations)) 
over(partition by deaths.location order by deaths.location, deaths.date) as cumulative_vaccinations
from Portfolio_Project..Covid_Deaths as deaths
inner join Portfolio_Project..Covid_Vaccinations as vaccinations
on deaths.location=vaccinations.location and deaths.date=vaccinations.date
where deaths.continent is not null
order by 2,3

--Using CTE(Common Table Expression)
with Pops_vs_Vacc(continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(int, vaccinations.new_vaccinations)) 
over(partition by deaths.location order by deaths.location, deaths.date) as cumulative_vaccinations
from Portfolio_Project..Covid_Deaths as deaths
inner join Portfolio_Project..Covid_Vaccinations as vaccinations
on deaths.location=vaccinations.location and deaths.date=vaccinations.date
where deaths.continent is not null
--order by 2,3
)
select *, (cumulative_vaccinations/population)*100
from Pops_vs_Vacc


--Temp table
drop table if exists #Percentage_population_vaccinated
create table #Percentage_population_vaccinated
(continent nvarchar(100), location nvarchar(100), date datetime, population numeric, new_vaccinations numeric, 
cumulative_vaccinations numeric)

insert into #Percentage_population_vaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(int, vaccinations.new_vaccinations)) 
over(partition by deaths.location order by deaths.location, deaths.date) as cumulative_vaccinations
from Portfolio_Project..Covid_Deaths as deaths
inner join Portfolio_Project..Covid_Vaccinations as vaccinations
on deaths.location=vaccinations.location and deaths.date=vaccinations.date
where deaths.continent is not null
order by 2,3

select *, (cumulative_vaccinations/population)*100
from #Percentage_population_vaccinated


--Creating view to store data for visualisations later
create view Percentage_population_vaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(int, vaccinations.new_vaccinations)) 
over(partition by deaths.location order by deaths.location, deaths.date) as cumulative_vaccinations
from Portfolio_Project..Covid_Deaths as deaths
inner join Portfolio_Project..Covid_Vaccinations as vaccinations
on deaths.location=vaccinations.location and deaths.date=vaccinations.date
where deaths.continent is not null
--order by 2,3

select * from Percentage_population_vaccinated










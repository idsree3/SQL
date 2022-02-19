


select * 
from PortfolioProject..covidDeaths

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..covidDeaths
order by 1,2

--looking at the total cases vs total deaths

select location,date,total_cases,total_deaths,round(((total_deaths/total_cases)*100),2) as percentagedeath
from PortfolioProject..covidDeaths
where location like 'India'
order by percentagedeath

--Looking at total cases vs population

select location,date,total_cases,population,round(((total_cases/population)*100),2) as percentage
from PortfolioProject..covidDeaths
where location like '%states%'
order by percentage desc

--Looking for countries with highest infection rate compared to population

select location,population,max(total_cases) as highest,max(total_cases/population)*100 as percentage
from PortfolioProject..covidDeaths
--where location like 'India'
group by location,population
order by percentage desc;

--Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as highest_deathcount
from PortfolioProject..covidDeaths
where continent is not null
group by location
order by highest_deathcount desc

--grouping by continent

select continent, max(cast(total_deaths as int)) as highest_deathcount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by highest_deathcount desc

--grouping by location

select location,max(cast(total_deaths as int)) as highest_deathcount
from PortfolioProject..covidDeaths
where continent is null
group by location
order by highest_deathcount desc

-- Showing the continents with highest death count per population
select continent, max(cast(total_deaths as int)) as highest_deathcount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by highest_deathcount desc

--global numbers

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
	round(((sum(cast(new_deaths as int))/sum(new_cases))*100),2) as Deathpercentage
from PortfolioProject..covidDeaths
--where location like 'India'
where continent is not null
group by date
order by 1,2

--to see the total population vs vaccinations

Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cumulativeCount
from PortfolioProject..covidDeaths cd
join PortfolioProject..covid_vaccine cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--USing CTE
with popvsvac 
(continent,location,date,population,new_vaccinations,cumulativecount)
as 
(
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as numeric)) over (partition by cd.location order by cd.location,cd.date) as cumulativeCount
from PortfolioProject..covidDeaths cd
join PortfolioProject..covid_vaccine cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *,(cumulativecount/population)*100
from popvsvac 

--temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
cumulativeCount numeric
)

insert into #percentpopulationvaccinated
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(numeric,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cumulativeCount
from PortfolioProject..covidDeaths cd
join PortfolioProject..covid_vaccine cv
	on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null
--order by 2,3
select *,(cumulativecount/population)*100
from #percentpopulationvaccinated

--to check the data in New vaccinations column to fix the issue converting to numeric instead of int
select new_vaccinations
from  PortfolioProject..covid_vaccine

--creating views for visualizations

create view percentpopulationvaccinated as
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(numeric,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cumulativeCount
from PortfolioProject..covidDeaths cd
join PortfolioProject..covid_vaccine cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

--selecting from created views
select * from percentpopulationvaccinated






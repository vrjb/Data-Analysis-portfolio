SELECT * FROM covid.coviddeaths;
SELECT * FROM covid.covidvaccine;
SET SQL_SAFE_UPDATES = 0;

UPDATE covid.coviddeaths SET coviddeaths.continent = NULL WHERE coviddeaths.continent = '';
-- Looking at total cases vs total deaths
SELECT location, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
from covid.coviddeaths 
WHERE location = 'india';

-- Looking at total cases vs poppulation
SELECT location, date_, total_cases, total_deaths, population, (total_cases/population)*100 AS infection_percentage
from covid.coviddeaths 
-- WHERE location = 'india'
order by 1,2;

-- Looking at countries with highest infection_rate compared to poppulation
SELECT location, population, MAX(total_cases) as total_infection_count, MAX((total_cases/population))*100 AS infection_rate
from covid.coviddeaths 
-- WHERE location = 'india' 
group by location, population
ORDER BY infection_rate desc;

-- Looking at continents with highest death count per poppulation
SELECT continent, MAX(total_deaths) as total_death_count
from covid.coviddeaths 
-- WHERE location = 'india'
WHERE continent IS NOT NULL
group by continent
ORDER BY total_death_count desc;


-- Looking at countries with highest death count per poppulation
SELECT location, MAX(total_deaths) as total_death_count
from covid.coviddeaths 
-- WHERE location = 'india' 
WHERE continent IS NOT NULL
group by location
ORDER BY total_death_count desc;

-- GLobal numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 AS death_percentage
from covid.coviddeaths 
-- WHERE location = 'india'
WHERE continent is not NULL
-- GROUP BY date_
order by 1,2;


SELECT death.continent,death.location, death.date_,death.population, vaccination.new_vaccinations,
SUM(vaccination.new_vaccinations) over (partition by death.location order by death.location, death.date_) as total_people_vaccinated
-- (total_people_vaccinated/death.population)*100 as percent_population_vaccinated
FROM covid.coviddeaths death
JOIN covidvaccine vaccination
	on death.location = vaccination.location
	and death.date_ = vaccination.date_
where death.continent is not null
-- GROUP BY date_,death.location,death.population
ORDER BY 2,3;



-- USE CTE

with popvsVac(continent, location,date_, population, new_vaccinations, total_people_vaccinated)
as
(
SELECT death.continent,death.location, death.date_,death.population, vaccination.new_vaccinations,
SUM(vaccination.new_vaccinations) over (partition by death.location order by death.location, death.date_) as total_people_vaccinated
-- (total_people_vaccinated/death.population)*100 as percent_population_vaccinated
FROM covid.coviddeaths death
JOIN covidvaccine vaccination
	on death.location = vaccination.location
	and death.date_ = vaccination.date_
where death.continent is not null
-- GROUP BY date_,death.location,death.population
ORDER BY 2,3
)
SELECT *, (total_people_vaccinated/population)*100 as percent_population_vaccinated
FROM popvsVac;
-- WHERE location = 'albania';

-- TEMP table

CREATE TABLE percentpoppulationvaccinated
(
continent NVARCHAR(255), 
location NVARCHAR(255),
date_ DATETIME, 
population NUMERIC, 
new_vaccinations NUMERIC, 
total_people_vaccinated NUMERIC
);
INSERT INTO percentpoppulationvaccinated
SELECT death.continent,death.location, death.date_,death.population, vaccination.new_vaccinations,
SUM(vaccination.new_vaccinations) over (partition by death.location order by death.location, death.date_) as total_people_vaccinated
-- (total_people_vaccinated/death.population)*100 as percent_population_vaccinated
FROM covid.coviddeaths death
JOIN covidvaccine vaccination
	on death.location = vaccination.location
	and death.date_ = vaccination.date_
where death.continent is not null
-- GROUP BY date_,death.location,death.population
ORDER BY 2,3;



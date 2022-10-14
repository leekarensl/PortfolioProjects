/*
Queries used for Tableau Project
*/

-- Global Numbers

Select
  SUM(new_cases) as total_cases, 
  SUM(new_deaths) as total_deaths, 
  SUM(new_deaths)/SUM(New_Cases) * 100 as death_percentage
From `portfolioproject-365216.Covid19.CovidDeaths`
where continent is not null;


-- Total Death Counts by Continent 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- Included in the data under location are "World" 'International' "High income" etc which needs to be taken out. European Union is part of Europe.

SELECT
 location, 
 SUM(new_deaths) as total_death_count
FROM `portfolioproject-365216.Covid19.CovidDeaths`
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Low income', 'Low middle income', 'Upper middle income')
GROUP BY location
ORDER BY total_death_count DESC;

-- Percentage Population Infected per Country

SELECT 
  location,
  population, 
  MAX(total_cases) as highest_infection_count,
  MAX((total_cases/population)) * 100 as population_infected_percent
FROM `portfolioproject-365216.Covid19.CovidDeaths`
GROUP BY
  location, population
ORDER BY 
  population_infected_percent DESC;

-- As above but with date column. 

SELECT
  location, 
  population,
  date,
  MAX(total_cases) as highest_infection_count,
  Max((total_cases/population)) * 100 as population_infected_percent
From `portfolioproject-365216.Covid19.CovidDeaths`
GROUP BY
 location, population, date
ORDER BY
  population_infected_percent DESC;

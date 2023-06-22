/* COVID-19 Data Exploratoin

Skills used: Create tables, import data into table, Joins, CTE's, Temple Tables, Aggregate Functions, Creating Views

*/

-- Create the Tables

/* 

I'm going to be using two seperate datasets. Here I am creating the tables for each dataset.

*/

CREATE TABLE CovidDeaths(
    iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population BIGINT NULL,
    total_cases INT NULL,
    new_cases INT NULL,
    new_cases_smoothed VARCHAR(255),
    total_deaths INT NULL,
    new_deaths INT NULL,
    new_deaths_smoothed VARCHAR(255),
    total_cases_per_million VARCHAR(255),
    new_cases_per_million VARCHAR(255),
    new_cases_smoothed_per_million VARCHAR(255),
    total_deaths_per_million VARCHAR(255),
    new_deaths_per_million VARCHAR(255),
    new_deaths_smoothed_per_million VARCHAR(255),
    reproduction_rate VARCHAR(255),
    icu_patients INT NULL,
    icu_patients_per_million VARCHAR(255),
    hosp_patients INT NULL,
    hosp_patients_per_million VARCHAR(255),
    weekly_icu_admissions INT NULL,
    weekly_icu_admissions_per_million VARCHAR(255),
    weekly_hosp_admissions INT NULL,
    weekly_hosp_admissions_per_million VARCHAR(255)
);
CREATE  TABLE CovidVaccinations(
    iso_code VARCHAR(250),
    continent VARCHAR(250),
    location VARCHAR(250),
    date DATE,
    total_tests BIGINT NULL,
    new_tests INT NULL,
    total_tests_per_thousand VARCHAR(250),
    new_tests_per_thousand VARCHAR(250),
    new_tests_smoothed VARCHAR(250),
    new_tests_smoothed_per_thousand VARCHAR(250),
    positive_rate VARCHAR(250),
    tests_per_case VARCHAR(250),
    tests_units VARCHAR(250),
    total_vaccinations VARCHAR(250),
    people_vaccinated VARCHAR(250),
    people_fully_vaccinated VARCHAR(250),
    total_boosters VARCHAR(250),
    new_vaccinations VARCHAR(250),
    new_vaccinations_smoothed VARCHAR(250),
    total_vaccinations_per_hundred VARCHAR(250),
    people_vaccinated_per_hundred VARCHAR(250),
    people_fully_vaccinated_per_hundred VARCHAR(250),
    total_boosters_per_hundred VARCHAR(250),
    new_vaccinations_smoothed_per_million VARCHAR(250),
    new_people_vaccinated_smoothed VARCHAR(250),
    new_people_vaccinated_smoothed_per_hundred VARCHAR(250),
    stringency_index VARCHAR(250),
    population_density VARCHAR(250),
    median_age VARCHAR(250),
    aged_65_older VARCHAR(250),
    aged_70_older VARCHAR(250),
    gdp_per_capita VARCHAR(250),
    extreme_poverty VARCHAR(250),
    cardiovasc_death_rate VARCHAR(250),
    diabetes_prevalence VARCHAR(250),
    female_smokers VARCHAR(250),
    male_smokers VARCHAR(250),
    handwashing_facilities VARCHAR(250),
    hospital_beds_per_thousand VARCHAR(250),
    life_expectancy VARCHAR(250),
    human_development_index VARCHAR(250),
    excess_mortality_cumulative_absolute VARCHAR(250),
    excess_mortality_cumulative VARCHAR(250),
    excess_mortality VARCHAR(250),
    excess_mortality_cumulative_per_million VARCHAR(250)
    );



-- Load Data Infile

/* 

Now the tables have been created I will import the data from the CSV files into the tables using the LOAD DATA INFILE function.

*/


/* 

One challenge I had during the import process was that the null values where set to "''" rather than "NULL". This caused an error why attempting to import.
To solve this I convert the "''" entries to "NULL" in Excel before importing the data. 
I kept back ups of the original CSV files incase there were any errors.

*/

LOAD DATA INFILE 'CovidDeaths.csv'
INTO TABLE CovidDeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'CovidDeaths.csv'
INTO TABLE CovidDeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/* 

Below are the actual files I imported after correcting the NULL values 

*/

LOAD DATA INFILE 'CovidDeathsNullValues.csv'
INTO TABLE CovidDeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

LOAD DATA INFILE 'CovidVaccinationsNullValues.csv'
INTO TABLE CovidVaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS


-- Selecting the imported data to check it it's imported correctly.

SELECT *
FROM `PortfolioProject`.`CovidDeaths`
ORDER BY 3,4
LIMIT 100

SELECT *
FROM `PortfolioProject`.`CovidVaccinations`
ORDER BY 3,4
LIMIT 100


-- Select Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM `PortfolioProject`.`CovidDeaths`
ORDER BY 1,2


-- Total Cases vs Total Deaths for the UK
-- Shows the likelihood of dying if you contract COVID-19 in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `PortfolioProject`.`CovidDeaths`
WHERE Location LIKE '%kingdom%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population of the UK got COVID-19

SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS PercentOfPopInfected
FROM `PortfolioProject`.`CovidDeaths`
WHERE Location LIKE '%kingdom%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopInfected
FROM `PortfolioProject`.`CovidDeaths`
GROUP BY Location, population
ORDER BY PercentOfPopInfected DESC


-- Countries with the Highest Death Count per Population

/* 

Here we added the function where continent is not null to remove grouped continent and demogrpahic entries. 

*/

SELECT Location, MAX(total_deaths) AS TotalDeathsCount 
FROM `PortfolioProject`.`CovidDeaths`
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathsCount DESC
LIMIT 1000





-- Breaking things down by continent

-- Continents with the highest Death Count per Population

SELECT continent, MAX(total_deaths) AS TotalDeathsCount 
FROM `PortfolioProject`.`CovidDeaths`
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC








-- Moving onto the CovidVaccinations table


-- Checking the CovidVaccinations table
SELECT *
FROM `CovidVaccinations`
LIMIT 1000


-- Joining the two tables

SELECT *
FROM `CovidDeaths` AS DEA
JOIN `CovidVaccinations` AS VAC
    ON DEA.location = VAC.location
    AND DEA.`date` = VAC.`date`



-- Looking at Total Population vs Vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM `CovidDeaths` AS DEA
JOIN `CovidVaccinations` AS VAC
    ON DEA.location = VAC.location
    AND DEA.`date` = VAC.`date`
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


-- New vaccinations per Day

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM `CovidDeaths` AS DEA
JOIN `CovidVaccinations` AS VAC
    ON DEA.location = VAC.location
    AND DEA.`date` = VAC.`date`
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3



-- Using a CTE to perform a calculation on PARTITION BY in pervious query

WITH PopVsVac (continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM `CovidDeaths` AS DEA
JOIN `CovidVaccinations` AS VAC
    ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent VARCHAR(255),
Location VARCHAR(255),
Date DATE,
Population INT,
New_Vaccinations INT,
RollingPeopleVaccinated BIGINT
)

INSERT INTO PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM `CovidDeaths` AS DEA
JOIN `CovidVaccinations` AS VAC
    ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PercentPopulationVaccinated
LIMIT 100000


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM `CovidDeaths` AS DEA
JOIN `CovidVaccinations` AS VAC
    ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *
FROM percentpopulationvaccinated


--Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS  Death_percentage
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS  Case_percentage
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to population

SELECT DISTINCT location, MAX(total_cases) AS Highest_infection_count, population, MAX((total_cases/population))*100 AS  Infected_population_percentage
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_population_percentage DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS Highest_death_count, population, MAX((total_deaths/population))*100 AS  died_population_percentage
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Highest_death_count DESC

--LET's break things down by Continent

--Showing the continents with highest death counts per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Highest_death_count
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_death_count DESC


--Global numbers

SELECT SUM(new_cases) AS New_cases, SUM(CAST(new_deaths AS int)) AS New_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_percentages
FROM PortfolioProject..[Covid-Deaths]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY Death_percentages DESC


--COVID Vacciation table

SELECT * 
FROM PortfolioProject..[Covid-Deaths] d
JOIN PortfolioProject..[Covid-Vaccination] v
ON d.location = v.location
AND d.date = v.date

--Looking at Total Population vs Total Vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Adding_vaccinated_people
FROM PortfolioProject..[Covid-Deaths] d
JOIN PortfolioProject..[Covid-Vaccination] v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY 2, 3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Adding_vaccinated_people)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Adding_vaccinated_people
FROM PortfolioProject..[Covid-Deaths] d
JOIN PortfolioProject..[Covid-Vaccination] v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT DISTINCT location, MAX((Adding_vaccinated_people/population))*100
FROM PopvsVac
GROUP BY location
ORDER BY 1


--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Adding_vaccinated_people numeric
)
INSERT into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Adding_vaccinated_people
FROM PortfolioProject..[Covid-Deaths] d
JOIN PortfolioProject..[Covid-Vaccination] v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT DISTINCT location, MAX((Adding_vaccinated_people/population))*100
FROM #PercentPopulationVaccinated
GROUP BY location
ORDER BY 1


--Creating a View to save data for visualization

Create view AllPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Adding_vaccinated_people
FROM PortfolioProject..[Covid-Deaths] d
JOIN PortfolioProject..[Covid-Vaccination] v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM AllPopulationVaccinated
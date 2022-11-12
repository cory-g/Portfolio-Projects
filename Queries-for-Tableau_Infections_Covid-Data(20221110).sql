/*	Queries for Tableau Visualization: COVID Infections/Deaths
	https://public.tableau.com/app/profile/cory.gargan/viz/COVIDDataInfectionsDeathsNov2022/Dashboard1 */
	


-- 1. World Totals: Total Cases, Total Deaths, Death Percentage

SELECT
	MAX(total_cases) AS total_cases, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths,
	(MAX(CAST(total_deaths AS BIGINT))/MAX(total_cases))*100 AS death_percentage
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	location = 'World';


-- 2. Total Deaths Grouped by Continent

SELECT
	location, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NULL
	AND location NOT IN ('European Union', 'World', 'International')
	AND location NOT LIKE '%income%'
GROUP BY
	location
ORDER BY 
	2 DESC;


-- 3. Total COVID infections, Percent of Population infected Grouped by Country

SELECT
	location, population, MAX(total_cases) AS total_covid_infections,
	(MAX(total_cases)/population)*100 AS percent_population_infected
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY
	4 DESC;


-- 4. S/A/A, Grouped Data by Country & Date

SELECT
	location, population, date, MAX(total_cases) AS total_covid_infections,
	(MAX(total_cases)/population)*100 AS percent_population_infected
FROM
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population, date
ORDER BY
	5 DESC;




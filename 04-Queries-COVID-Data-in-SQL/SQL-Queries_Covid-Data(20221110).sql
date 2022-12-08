-- ***COVID DATA GROUPED BY COUNTRY***

-- Looking at Total Cases vs Total Deaths & Death Rate, Country & Date
SELECT
	location, date, total_cases, CAST(total_deaths AS BIGINT), 
	(CAST(total_deaths AS BIGINT)/total_cases)*100 AS death_rate
FROM
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NOT NULL
	--location = 'United States'	-- Use to search for a specific Country
ORDER BY
	1, 2;


-- Looking at Total Cases vs Population & Infection Rate, Country & Date
SELECT
	location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NOT NULL
	--location = 'United States'	-- Use to search for a specific Country
ORDER BY
	1, 2;


-- Looking at Countries with Highest infection Rate compared to Population
SELECT
	location, population, MAX(total_cases) AS total_pop_infected, 
	(MAX(total_cases)/population)*100 AS percent_pop_infected
FROM
	Portfolio_Covid..covid_deaths
GROUP BY
	location, population
ORDER BY 
	4 DESC;


-- Looking at Countries with the Highest Death totals
SELECT
	location, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	2 DESC;


-- Looking at Countries with the Highest Death count vs Population
SELECT
	location, population, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths,
	(MAX(CAST(total_deaths AS BIGINT))/population)*100 AS death_percent_total_pop
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY
	4 DESC;


-- ***COVID DATA GROUPED BY CONTINENT***

-- Looking at Total Deaths by Continent
SELECT
	location,  MAX(CAST(total_deaths AS BIGINT)) AS total_deaths
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NULL
	AND location != 'European Union' -- Comment out to include 'European Union'
	AND location NOT LIKE '%income%' -- Comment out to include data grouped by Income Levels
GROUP BY
	location
ORDER BY 
	1;


-- Looking at Total Deaths vs Population by Continent
SELECT
	location, population, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths,
	(MAX(CAST(total_deaths AS BIGINT))/population)*100 AS death_percent_total_pop
FROM	
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NULL
	AND location != 'European Union' -- Comment out to include 'European Union'
	AND location not like '%income%' -- Comment out to include data grouped by Income Levels
GROUP BY
	location, population
ORDER BY 
	1;



-- ***GLOBAL COVID DATA***

-- Looking at Global Total Cases Vs. Total Deaths by Date
SELECT
	date, MAX(total_cases) AS total_cases_global, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths_global,
	(MAX(CAST(total_deaths AS BIGINT))/MAX(total_cases))*100 AS covid_death_rate_global
FROM
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NULL
GROUP BY
	date
ORDER BY
	1;


/* Earlier iterations of the data did not include a 'World' location. I kept the original query 
to show my initial work. The following 'WHERE' clause could be accomplished using only 
'continent IS NULL' and changing all SUM functions to MAX as in example above */
SELECT
	date, SUM(total_cases) AS total_cases_global, 
	SUM(CAST(total_deaths AS BIGINT)) AS total_deaths_global,
	(SUM(CAST(total_deaths AS BIGINT))/SUM(total_cases))*100 AS covid_death_rate
FROM
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NULL
	AND location != 'European Union'
	AND location not like '%income%'
	AND location != 'World' 
GROUP BY
	date
ORDER BY
	1;


-- Looking at Global Totals with addition of Global Population, Death pct of total population by Date
SELECT
	date, MAX(population) AS population_global, MAX(total_cases) AS total_cases_global,
	MAX(CAST(total_deaths AS BIGINT)) AS total_deaths_global, 
	(MAX(CAST(total_deaths AS BIGINT))/MAX(total_cases))*100 AS covid_death_rate_global,
	(MAX(CAST(total_deaths AS BIGINT))/MAX(population))*100 AS global_pop_death_percent
FROM
	Portfolio_Covid..covid_deaths
WHERE
	continent IS NULL
GROUP BY
	date
ORDER BY
	1;


-- ***COVID VACCINATION DATA***

-- Looking at Populations vs Vaccination totals by Country & Date
SELECT
	deaths.continent, deaths.location, deaths.date, deaths.population, 
	vaxxx.new_vaccinations, vaxxx.total_vaccinations, vaxxx.people_fully_vaccinated,
	(vaxxx.people_fully_vaccinated/deaths.population)*100 AS pct_pop_fully_vaxxx
FROM	
	Portfolio_Covid..covid_deaths AS deaths
JOIN
	Portfolio_Covid..covid_vaxxx AS vaxxx
ON
	deaths.location = vaxxx.location
	AND deaths.date = vaxxx.date
WHERE
	deaths.continent IS NOT NULL
	--AND deaths.location = 'United States'  -- Use to look for a specific country
ORDER BY
	1, 2, 3;


-- Looking at Population Fully Vaccinated Percents (as of 2202/11/01) by Country
-- Using a CTE to filter Countries by Percent Population Fully Vaccinated
WITH	pop_vaxxx(location, population, people_fully_vaccinated, percent_pop_fully_vax)
AS
(
SELECT
	deaths.location, deaths.population, 
	MAX(CAST(vaxxx.people_fully_vaccinated AS BIGINT)) AS ppl_full_vaxxx,
	(MAX(CAST(vaxxx.people_fully_vaccinated AS BIGINT))/deaths.population)*100 AS pct_full_vaxxx  
FROM	
	Portfolio_Covid..covid_deaths AS deaths
JOIN
	Portfolio_Covid..covid_vaxxx AS vaxxx
ON
	deaths.location = vaxxx.location
	AND deaths.date = vaxxx.date
WHERE
	deaths.continent IS NOT NULL
GROUP BY
	deaths.location, deaths.population
)

SELECT		
	*
FROM		
	pop_vaxxx
WHERE									-- Comment out WHERE section for Full Data including NULLS
	percent_pop_fully_vax >= 25			-- Use to look for a specific fully vaccinated country percentage
	--AND location = 'United States'	-- Use to look for a specific country
ORDER BY
	4;





/* Former iterations of the data did contain column 'people_fully_vaccinated'.  Since 'new_vaccinations'
   column includes 3rd, 4th, 5th etc. shots, the created running total is no longer effective to 
   calculate the percent of the population vaccinated.  Code remains below to show my work */

-- Using a TEMP TABLE to get the running total of vaccinations, vaccinated population percentage.
DROP Table if exists #percent_population_vaxxx
Create Table #percent_population_vaxxx
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
total_vaxxx numeric
)

INSERT INTO #percent_population_vaxxx
SELECT
	deaths.continent, deaths.location, deaths.date, deaths.population, vaxxx.new_vaccinations,
	SUM(CAST(vaxxx.new_vaccinations AS BIGINT)) OVER					-- 1/2 These two lines of code create 
	(PARTITION BY deaths.location ORDER BY deaths.date) AS total_vaxxx  -- 2/2 the running total of vaccinations
FROM
	Portfolio_Covid..covid_deaths AS deaths
JOIN
	Portfolio_Covid..covid_vaxxx AS vaxxx
ON
	deaths.location = vaxxx.location
	AND deaths.date = vaxxx.date
WHERE
	deaths.continent is not NULL
	AND vaxxx.new_vaccinations is not NULL -- Only returns dates where country had new vaccinations
	--AND deaths.location = 'United States'	-- Use to look for a specific Country

SELECT
	*, (total_vaxxx/population)*100 AS pct_population_vaxxx
FROM
	#percent_population_vaxxx



--Using a CTE to get the running total of vaccinations, vaccinated population percentage. S/A/A
WITH pop_vax (continent, location, date, population, new_vaccinations, total_vaccinated)
AS (
SELECT
	deaths.continent, deaths.location, deaths.date, deaths.population, vaxxx.new_vaccinations,
	SUM(CAST(vaxxx.new_vaccinations AS BIGINT)) OVER					-- 1/2 These two lines of code create 
	(PARTITION BY deaths.location ORDER BY deaths.date) AS total_vaxxx  -- 2/2 the running total of vaccinations
FROM
	Portfolio_Covid..covid_deaths AS deaths
JOIN
	Portfolio_Covid..covid_vaxxx AS vaxxx
ON
	deaths.location = vaxxx.location
	AND deaths.date = vaxxx.date
WHERE
	deaths.continent is not NULL
	AND vaxxx.new_vaccinations is not NULL -- Only returns dates where country had new vaccinations
)
SELECT
	*, (total_vaccinated/population)*100 AS percent_pop_vaccinated
FROM
	pop_vax
WHERE 
	(total_vaccinated/population)*100 >= 0 -- Use to look for a specific vaccinated country percentage
ORDER BY
	1, 2, 3;



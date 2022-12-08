/*	Queries for Tableau Visualization: COVID Vaccinations
	https://public.tableau.com/app/profile/cory.gargan/viz/COVIDDataVaccinationsNov2022/Dashboard1 */

-- 1. World Totals: World Population, People Fully Vaccinated, Percent Fully Vaccinated

SELECT
	deaths.population AS world_population,
	MAX(CAST(vax.people_fully_vaccinated AS BIGINT)) AS world_fully_vaccinated,
	(MAX(CAST(vax.people_fully_vaccinated AS BIGINT))/deaths.population)*100 AS world_percent_full_vax

FROM	
	Portfolio_Covid..covid_vaxxx AS vax
JOIN
	Portfolio_Covid..covid_deaths AS deaths
	ON
		vax.location = deaths.location
		AND vax.date = deaths.date
WHERE
	vax.location = 'World'
GROUP BY
	deaths.population;


-- 2. Total Vaccinations Grouped by Continent

SELECT
	deaths.location,
	MAX(CAST(vax.people_fully_vaccinated AS BIGINT)) AS people_fully_vaccinated
FROM
	Portfolio_Covid..covid_vaxxx AS vax
JOIN
	Portfolio_Covid..covid_deaths AS deaths
	ON
		vax.location = deaths.location
		AND vax.date = deaths.date
WHERE
	deaths.continent IS NULL
	AND deaths.location NOT IN ('World', 'European Union', 'International')
	AND deaths.location NOT LIKE '%income%'
GROUP BY
	deaths.location
ORDER BY
	2 DESC;


-- 3. Total Vaccinations, Percent of Population by Country

SELECT
	deaths.location, deaths.population,
	MAX(CAST(vax.people_fully_vaccinated AS BIGINT)) AS people_fully_vaccinated,
	(MAX(CAST(vax.people_fully_vaccinated AS BIGINT))/deaths.population)*100 AS percent_pop_fully_vax
FROM
	Portfolio_Covid..covid_vaxxx AS vax
JOIN
	Portfolio_Covid..covid_deaths AS deaths
	ON
		vax.location = deaths.location
		AND vax.date = deaths.date
WHERE
	deaths.continent IS NOT NULL
GROUP BY
	deaths.location, deaths.population
ORDER BY
	1;
	

-- 4. S/A/A, Historical Vaccination Data (thru 2022/11/10) by Country & Date

SELECT
	deaths.location, deaths.date, deaths.population, 
	vax.people_fully_vaccinated,
	(CAST(vax.people_fully_vaccinated AS BIGINT)/deaths.population)*100 AS percent_pop_full_vax
FROM
	Portfolio_Covid..covid_vaxxx AS vax
JOIN
	Portfolio_Covid..covid_deaths AS deaths
	ON
		vax.location = deaths.location
		AND vax.date = deaths.date
WHERE
	deaths.continent IS NOT NULL
	AND vax.people_fully_vaccinated IS NOT NULL
GROUP BY
	deaths.location, deaths.date, deaths.population, vax.people_fully_vaccinated
ORDER BY
	1, 2;
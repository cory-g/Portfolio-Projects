/*	
	Did Joe Musgrove use a foreign substance to increase his Spin Rate during Playoffs?
	And if so, did it have a meaningful impact?
*/

-- 0. Finds the total number of games each pitch was thrown
SELECT
	pitcher_name,
	season_type,
	pitch_name, 
	ROUND(AVG(release_spin_rate), 2) AS spin_rate, 
	--COUNT(pitch_result) AS strikes,
	COUNT(DISTINCT game_date) AS games_used_in
FROM	
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;


-- 0a. Games Played Entire Season, Home & Away, Regular vs Post Season
SELECT
	season_type,
	pitcher_home_away,
	COUNT(DISTINCT game_date) AS games_played
FROM
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_home_away, season_type
ORDER BY
	1 DESC, 2 DESC;


-- 1. Average Spin Rate per Pitch Type, Regular Season
SELECT
	pitcher_name,
	pitch_name, 
	ROUND(AVG(release_spin_rate), 2) AS spin_rate
FROM	
	Portfolio_SR..musgrove_data
WHERE
	season_type = 'Regular Season'
GROUP BY
	pitcher_name, pitch_name
ORDER BY
	2;


-- 2. Average Spin Rate by Pitch Type, Post Season
SELECT
	pitcher_name,
	pitch_name, 
	ROUND(AVG(release_spin_rate), 2) AS spin_rate
FROM	
	Portfolio_SR..musgrove_data
WHERE
	season_type = 'Post Season'
GROUP BY
	pitcher_name, pitch_name
ORDER BY
	2;


-- 3. Average Spin Rate by Pitch Type, Regular vs Post Season
SELECT
	pitcher_name,
	season_type,
	pitch_name, 
	ROUND(AVG(release_spin_rate), 2) AS spin_rate
FROM	
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;


-- 4. Strikes Thrown by Pitch Type, Regular vs Post Season
SELECT
	pitcher_name,
	season_type,
	pitch_name,  
	COUNT(pitch_result) AS strikes
FROM	
	Portfolio_SR..musgrove_data
WHERE
	pitch_result = 'strike'
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;


-- 5. Strike Outs, Total - Regular vs Post Season
SELECT
	pitcher_name, season_type, at_bat_outcome AS outcome,
	COUNT(at_bat_outcome) AS strikeouts
FROM
	Portfolio_SR..musgrove_data
WHERE
	at_bat_outcome IS NOT NULL
	AND at_bat_outcome = 'strikeout'
GROUP BY
	pitcher_name, season_type, at_bat_outcome
ORDER BY
	2 DESC;


-- 6. Hits by Pitch Type, Regular vs Post Season
SELECT
	pitcher_name,
	season_type,
	pitch_name,
	COUNT(pitch_result) AS hits_allowed
FROM	
	Portfolio_SR..musgrove_data
WHERE
	pitch_result = 'in play'
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;
	

-- 7. Spin Rate by Pitch, Home vs Away
SELECT
	pitcher_name,
	pitcher_home_away AS home_away,
	pitch_name, 
	ROUND(AVG(release_spin_rate), 2) AS spin_rate
FROM	
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_name, pitch_name, pitcher_home_away
ORDER BY
	3, 2 DESC;


-- 8. Average Exit Velocity by Pitch, Regular vs Post Season
SELECT
	pitcher_name,
	season_type,
	pitch_name,
	ROUND(AVG(exit_velocity), 2) AS average_exit_velocity
FROM	
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;


-- 9. Average Pitch Speed by Pitch, Regular vs Post Season
SELECT
	pitcher_name,
	season_type,
	pitch_name,
	ROUND(AVG(effective_speed), 2) AS average_pitch_speed
FROM	
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;


-- 10. Percent Each Pitch Was Thrown, Regular vs Post Season
WITH throw_pct (pitcher, pitch, season, times_thrown, total_pitches_thrown, spin_rate)
AS (
SELECT
	pitcher_name,
	pitch_name,
	season_type,
	COUNT(pitch_name) AS times_thrown,
	SUM(COUNT(pitch_name)) OVER (PARTITION BY season_type) AS total_pitches,
	ROUND(AVG(release_spin_rate), 2) AS spin_rate
FROM
	Portfolio_SR..musgrove_data
GROUP BY
	pitcher_name, pitch_name, season_type
)
SELECT
	pitcher, season, pitch, times_thrown, total_pitches_thrown, 
	ROUND((CAST(times_thrown AS FLOAT)/CAST(total_pitches_thrown AS FLOAT))*100, 2) AS percent_thrown,
	spin_rate
FROM
	throw_pct
GROUP BY
	pitcher, pitch, season, times_thrown, total_pitches_thrown, spin_rate
ORDER BY
	2 DESC, 3;


-- 11. How many strikeouts per Type Of Pitch, Regular vs Post Season	
SELECT
	pitcher_name, season_type, pitch_name, at_bat_outcome AS outcome, 
	COUNT(at_bat_outcome) AS strikeouts
FROM
	Portfolio_SR..musgrove_data
WHERE
	at_bat_outcome = 'strikeout'
GROUP BY
	pitcher_name, pitch_name, season_type, at_bat_outcome
ORDER BY
	2 DESC, 3;


-- 11a. How many strikeouts per Type of Pitch Vs. Total Strikeouts, using CTE
WITH strikeoutCTE AS
(
SELECT
	pitcher_name, season_type, pitch_name, 
	at_bat_outcome AS outcome, 
	COUNT(at_bat_outcome) AS strikeouts,
	SUM(COUNT(at_bat_outcome)) OVER (PARTITION BY season_type) AS total_strikeouts
FROM
	Portfolio_SR..musgrove_data
WHERE
	at_bat_outcome IS NOT NULL
	AND at_bat_outcome = 'strikeout'
GROUP BY
	pitcher_name, season_type, pitch_name, at_bat_outcome
)
SELECT		pitcher_name, season_type, pitch_name, outcome, strikeouts, total_strikeouts,
			ROUND((CAST(strikeouts AS FLOAT)/total_strikeouts) * 100, 2) AS strikeout_percent
FROM		strikeoutCTE
GROUP BY	pitcher_name, season_type, pitch_name, outcome, strikeouts, total_strikeouts
ORDER BY	2 DESC, 3


-- 11b. How many strikeouts per Pitch Type Vs. Times Thrown with 2 Outs, using CTE
WITH strikeoutCTE AS
(
SELECT
			pitcher_name, season_type, pitch_name, at_bat_outcome, strikes, 
			COUNT(at_bat_outcome) AS strikeouts,
			SUM(COUNT(pitch_name)) OVER (PARTITION BY season_type, pitch_name) AS times_thrown_2outs
FROM
			Portfolio_SR..musgrove_data_2
WHERE
			strikes = 2
GROUP BY
			pitcher_name, season_type, pitch_name, at_bat_outcome, strikes
)
SELECT		pitcher_name, season_type, pitch_name, strikeouts, times_thrown_2outs,
			ROUND((CAST(strikeouts AS FLOAT)/times_thrown_2outs) * 100, 2) AS strikeout_percent
FROM		strikeoutCTE
WHERE
			at_bat_outcome = 'strikeout'	
GROUP BY	pitcher_name, season_type, pitch_name, strikeouts, times_thrown_2outs
ORDER BY	2 DESC, 3


-- 12. How Many Field Outs per Type Of Pitch, Regular vs Post Season
SELECT
	pitcher_name, season_type, pitch_name, 
	COUNT(at_bat_outcome) AS field_outs
FROM
	Portfolio_SR..musgrove_data
WHERE
	at_bat_outcome IS NOT NULL
	AND at_bat_outcome = 'field_out'
	OR at_bat_outcome LIKE '%double_play%'
GROUP BY
	pitcher_name, pitch_name, season_type
ORDER BY
	2 DESC, 3;


-- 13. How Many Batters Did He Face per Game, Regular & Post Season
SELECT	
	game_date,
	season_type,
	COUNT(DISTINCT at_bat_number) AS batters_faced,
	SUM(COUNT(DISTINCT at_bat_number)) OVER (PARTITION BY season_type ORDER BY game_date) AS batters_faced_to_date,
	SUM(COUNT(DISTINCT at_bat_number)) OVER (PARTITION BY season_type) AS total_batters_faced
FROM	
	Portfolio_SR..musgrove_data_2
GROUP BY 
	game_date, season_type
ORDER BY 
	1

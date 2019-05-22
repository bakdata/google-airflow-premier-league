CREATE OR REPLACE VIEW `{0}.{1}.v_latest_result` AS
WITH results AS (
  SELECT
    date,
    match,
    SUBSTR(match, 0, 3) AS home_team,
    COUNTIF(STARTS_WITH(match, scorer_team)) AS home_goals,
    COUNTIF(ENDS_WITH(match, scorer_team)) AS away_goals,
    SUBSTR(match, 4) AS away_team
  FROM `{0}.{1}.scorer`
  GROUP BY date, match, scorer_team
  UNION ALL
  SELECT
    date, match, home_team_code, 0, 0, away_team_code
  FROM `{0}.{1}.matchweek`
  WHERE match NOT IN (SELECT match FROM `{0}.{1}.scorer`)
)
SELECT
  date,
  home_team,
  CONCAT(CAST(home_goals AS STRING), ' - ', CAST(away_goals AS String)) AS result,
  away_team,
  SUM(CASE WHEN home_goals > away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS home_team_pts,
  SUM(CASE WHEN home_goals < away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS away_team_pts
FROM results GROUP BY 1,2,3,4
ORDER BY date DESC
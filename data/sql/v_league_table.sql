CREATE OR REPLACE VIEW `{0}.{1}.v_league_table` AS
WITH results AS (  
  SELECT
    matchweek,
    match,
    SUBSTR(match, 0, 3) AS home_team,
    COUNTIF(STARTS_WITH(match, scorer_team)) AS home_goals,
    COUNTIF(ENDS_WITH(match, scorer_team)) AS away_goals,
    SUBSTR(match, 4) AS away_team
  FROM `{0}.{1}.scorer`
  GROUP BY matchweek, match, scorer_team
  UNION ALL
  SELECT 
    matchweek, match, home_team_code, 0, 0, away_team_code
  FROM `{0}.{1}.matchweek`
  WHERE match NOT IN (SELECT match FROM `{0}.{1}.scorer`) 
  ORDER BY matchweek
), points AS (
SELECT 
  home_team AS team,
  SUM(CASE WHEN home_goals > away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS pts,
  COUNTIF(home_goals > away_goals) as wins,
  COUNTIF(home_goals = away_goals) as draws,
  SUM(home_goals) AS goals_for,
  SUM(away_goals) AS goals_against,
  COUNT(DISTINCT match) AS played
FROM results GROUP BY 1
UNION ALL
SELECT away_team AS team,
  SUM(CASE WHEN home_goals < away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS pts,
  COUNTIF(home_goals < away_goals) as wins,
  COUNTIF(home_goals = away_goals) as draws,
  SUM(away_goals) AS goals_for,
  SUM(home_goals) AS goals_against,
  COUNT(DISTINCT match) AS played
FROM results GROUP BY 1
)
SELECT 
  team,
  SUM(played) AS played, 
  SUM(wins) AS wins, 
  SUM(draws) AS draws, 
  SUM(played) - (SUM(wins) + SUM(draws)) AS losses, 
  SUM(goals_for) AS goals_for,
  SUM(goals_against) AS goals_against,
  SUM(goals_for) - SUM(goals_against) AS goals_diff,
  SUM(pts) AS pts 
FROM points GROUP BY 1 ORDER BY 9 DESC
WITH points AS (
SELECT 
  home_team AS team,
  SUM(CASE WHEN home_goals > away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS pts,
  COUNTIF(home_goals > away_goals) as wins,
  COUNTIF(home_goals = away_goals) as draws,
  SUM(home_goals) AS goals_for,
  SUM(away_goals) AS goals_against,
  COUNT(DISTINCT match) AS played
FROM `$GC_PROJECT_ID.view.matches` GROUP BY 1
UNION ALL
SELECT away_team AS team,
  SUM(CASE WHEN home_goals < away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS pts,
  COUNTIF(home_goals < away_goals) as wins,
  COUNTIF(home_goals = away_goals) as draws,
  SUM(away_goals) AS goals_for,
  SUM(home_goals) AS goals_against,
  COUNT(DISTINCT match) AS played
FROM `$GC_PROJECT_ID.view.matches` GROUP BY 1
), teams AS (
SELECT DISTINCT team_name, team_code FROM (
SELECT home_team as team_name, home_team_code as team_code FROM `$GC_PROJECT_ID.warehouse.matchweek`
UNION ALL
SELECT away_team as team_name, away_team_code as team_code FROM `$GC_PROJECT_ID.warehouse.matchweek`
))
SELECT 
  team_name,
  SUM(played) AS played, 
  SUM(wins) AS wins, 
  SUM(draws) AS draws, 
  SUM(played) - (SUM(wins) + SUM(draws)) AS losses, 
  SUM(goals_for) AS goals_for,
  SUM(goals_against) AS goals_against,
  SUM(goals_for) - SUM(goals_against) AS goals_diff,
  SUM(pts) AS pts 
FROM points JOIN teams on team = team_code
GROUP BY 1 ORDER BY 9 DESC, 8 DESC
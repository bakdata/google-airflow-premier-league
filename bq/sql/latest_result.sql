SELECT
  date,
  home_team,
  CONCAT(CAST(home_goals AS STRING), ' - ', CAST(away_goals AS String)) AS result,
  away_team,
  SUM(CASE WHEN home_goals > away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS home_team_pts,
  SUM(CASE WHEN home_goals < away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS away_team_pts
FROM `$GC_PROJECT_ID.view.matches` GROUP BY 1,2,3,4
ORDER BY date DESC
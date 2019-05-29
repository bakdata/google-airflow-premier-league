SELECT
  week,
  date,
  match,
  SUBSTR(match, 0, 3) AS home_team,
  COUNTIF(STARTS_WITH(match, scorer_team)) AS home_goals,
  COUNTIF(ENDS_WITH(match, scorer_team)) AS away_goals,
  SUBSTR(match, 4) AS away_team
FROM `$GC_PROJECT_ID.warehouse.scorer`
GROUP BY 1,2,3
UNION ALL
SELECT
  week, date, match, home_team_code, 0, 0, away_team_code
FROM `$GC_PROJECT_ID.warehouse.matchweek`
WHERE match NOT IN (SELECT match FROM `$GC_PROJECT_ID.warehouse.scorer`)
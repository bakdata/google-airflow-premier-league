CREATE OR REPLACE VIEW `{0}.{1}.goal_scorers` AS
WITH 
all_goals AS (
  SELECT COUNT(*) as goals, player, scorer_team FROM `{0}.{2}.scorer`
  GROUP BY 2,3
), 
teams AS (
  SELECT DISTINCT team, code FROM (
    SELECT home_team AS team, home_team_code AS code FROM `{0}.{2}.matchday`
    UNION ALL
    SELECT away_team AS team, away_team_code AS code FROM `{0}.{2}.matchday`
  )
)
SELECT player, team, goals
FROM all_goals JOIN teams ON scorer_team = code 
ORDER BY goals DESC
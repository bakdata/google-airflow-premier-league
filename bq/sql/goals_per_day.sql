WITH goals_per_day AS (
  SELECT date, player, count(cdc_hash) as goals_daily
  FROM `$GC_PROJECT_ID.warehouse.scorer`
  group by player, date
  order by date
)
SELECT t1.date, t1.player, SUM(t2.goals_daily) as goals_total
FROM goals_per_day as t1
JOIN goals_per_day as t2 on (
  t1.player = t2.player and
  t1.date >= t2.date
)
group by t1.date, t1.player
order by t1.date
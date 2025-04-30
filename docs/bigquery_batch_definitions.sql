-- BigQuery バッチ定義 v0.2
-- 
-- ダッシュボード集計用の中間テーブルを生成・更新するSQLスクリプト
-- Cloud Scheduler + BigQuery のスケジュールクエリとして利用

-- ===================================================================
-- ① daily_summary_table の集計
-- ===================================================================
CREATE OR REPLACE TABLE quumo.dashboard_daily_summary AS
SELECT
  date,
  client_id,
  store_id,
  SUM(traffic) AS traffic,
  SUM(entries) AS entries,
  SUM(stays) AS stays,
  SUM(purchases) AS purchases,
  SAFE_DIVIDE(SUM(entries), NULLIF(SUM(traffic), 0)) AS entry_rate,
  SAFE_DIVIDE(SUM(stays), NULLIF(SUM(entries), 0)) AS stay_rate,
  SAFE_DIVIDE(SUM(purchases), NULLIF(SUM(entries), 0)) AS purchase_rate,
  CURRENT_TIMESTAMP() AS created_at
FROM quumo.dashboard_hourly_summary
GROUP BY date, client_id, store_id;

-- ===================================================================
-- ② dashboard_weekday_summary（曜日別）
-- ===================================================================
CREATE OR REPLACE TABLE quumo.dashboard_weekday_summary AS
SELECT
  client_id,
  store_id,
  EXTRACT(DAYOFWEEK FROM date) AS weekday,
  AVG(traffic) AS avg_traffic,
  AVG(entries) AS avg_entries,
  AVG(stays) AS avg_stays,
  AVG(purchases) AS avg_purchases,
  SAFE_DIVIDE(AVG(entries), NULLIF(AVG(traffic), 0)) AS avg_entry_rate,
  SAFE_DIVIDE(AVG(stays), NULLIF(AVG(entries), 0)) AS avg_stay_rate,
  SAFE_DIVIDE(AVG(purchases), NULLIF(AVG(entries), 0)) AS avg_purchase_rate,
  CURRENT_TIMESTAMP() AS created_at
FROM quumo.dashboard_hourly_summary
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY client_id, store_id, weekday;

-- ===================================================================
-- ③ dashboard_monthly_summary（YYYY-MM）
-- ===================================================================
CREATE OR REPLACE TABLE quumo.dashboard_monthly_summary AS
SELECT
  FORMAT_DATE('%Y-%m', date) AS year_month,
  client_id,
  store_id,
  SUM(traffic) AS traffic,
  SUM(entries) AS entries,
  SUM(stays) AS stays,
  SUM(purchases) AS purchases,
  SAFE_DIVIDE(SUM(entries), NULLIF(SUM(traffic), 0)) AS entry_rate,
  SAFE_DIVIDE(SUM(stays), NULLIF(SUM(entries), 0)) AS stay_rate,
  SAFE_DIVIDE(SUM(purchases), NULLIF(SUM(entries), 0)) AS purchase_rate,
  CURRENT_TIMESTAMP() AS created_at
FROM quumo.dashboard_hourly_summary
GROUP BY year_month, client_id, store_id;

-- ===================================================================
-- ④ dashboard_quarterly_summary（YYYY-Qx）
-- ===================================================================
CREATE OR REPLACE TABLE quumo.dashboard_quarterly_summary AS
SELECT
  FORMAT('%d-Q%d', EXTRACT(YEAR FROM date), EXTRACT(QUARTER FROM date)) AS year_quarter,
  client_id,
  store_id,
  SUM(traffic) AS traffic,
  SUM(entries) AS entries,
  SUM(stays) AS stays,
  SUM(purchases) AS purchases,
  SAFE_DIVIDE(SUM(entries), NULLIF(SUM(traffic), 0)) AS entry_rate,
  SAFE_DIVIDE(SUM(stays), NULLIF(SUM(entries), 0)) AS stay_rate,
  SAFE_DIVIDE(SUM(purchases), NULLIF(SUM(entries), 0)) AS purchase_rate,
  CURRENT_TIMESTAMP() AS created_at
FROM quumo.dashboard_hourly_summary
GROUP BY year_quarter, client_id, store_id;

-- ===================================================================
-- ⑤ dashboard_yearly_summary（YYYY）
-- ===================================================================
CREATE OR REPLACE TABLE quumo.dashboard_yearly_summary AS
SELECT
  EXTRACT(YEAR FROM date) AS year,
  client_id,
  store_id,
  SUM(traffic) AS traffic,
  SUM(entries) AS entries,
  SUM(stays) AS stays,
  SUM(purchases) AS purchases,
  SAFE_DIVIDE(SUM(entries), NULLIF(SUM(traffic), 0)) AS entry_rate,
  SAFE_DIVIDE(SUM(stays), NULLIF(SUM(entries), 0)) AS stay_rate,
  SAFE_DIVIDE(SUM(purchases), NULLIF(SUM(entries), 0)) AS purchase_rate,
  CURRENT_TIMESTAMP() AS created_at
FROM quumo.dashboard_hourly_summary
GROUP BY year, client_id, store_id;

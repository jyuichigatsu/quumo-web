# クライアント向けダッシュボード API仕様書 v0.2

---

## 1. GET `/api/dashboard/summary`

### 用途
- 当日の主要指標サマリーを取得する

### パラメータ

| 名前 | 型 | 必須 | 説明 |
|:---|:---|:---|:---|
| client_id | string | ✅ | 対象クライアントのID |
| date | string (YYYY-MM-DD) | ❌ | 省略時は当日 |

### レスポンス例（JSON）

```json
{
  "date": "2025-04-28",
  "store_name": "渋谷店",
  "traffic": 1200,
  "entries": 320,
  "entry_rate": 0.267,
  "stays": 180,
  "stay_rate": 0.562,
  "purchases": 75,
  "purchase_rate": 0.234
}
```

---

## 2. GET `/api/dashboard/funnel`

### 用途
- 通行 → 入店 → 購買のファネル構造データを取得する

### パラメータ

| 名前 | 型 | 必須 | 説明 |
|:---|:---|:---|:---|
| client_id | string | ✅ | クライアントID |
| date | string | ✅ | 対象日 |

### レスポンス例

```json
{
  "traffic": 1200,
  "entries": 320,
  "purchases": 75,
  "entry_rate": 0.267,
  "purchase_rate": 0.234
}
```

---

## 3. GET `/api/dashboard/timeseries`

### 用途
- 指定期間の各指標推移（時系列グラフ用）を取得

### パラメータ

| 名前 | 型 | 必須 | 説明 |
|:---|:---|:---|:---|
| client_id | string | ✅ | クライアントID |
| from | string (YYYY-MM-DD) | ✅ | 開始日 |
| to | string (YYYY-MM-DD) | ✅ | 終了日 |
| metric | string | ✅ | 指標名（例: traffic, entries, purchases） |
| interval | string | ❌ | 粒度（day, hour, weekday, month, quarter, year）※デフォルト: day |

### レスポンス例

```json
{
  "metric": "entries",
  "unit": "人",
  "values": [
    { "date": "2025-04-21", "value": 300 },
    { "date": "2025-04-22", "value": 275 },
    { "date": "2025-04-23", "value": 290 }
  ]
}
```

---

# 🧱 中間テーブル設計（課金・パフォーマンス最適化）

---

## 📌 1. `daily_summary_table`

### 用途
- ダッシュボードの1日単位のサマリー表示用

### スキーマ

| カラム名 | 型 | 説明 |
|:---|:---|:---|
| date | DATE | 日付 |
| client_id | STRING | クライアントID |
| store_id | STRING | 店舗ID |
| traffic | INTEGER | 通行量 |
| entries | INTEGER | 入店数 |
| stays | INTEGER | エリア滞在数 |
| purchases | INTEGER | 購買数 |
| entry_rate | FLOAT | entries ÷ traffic |
| stay_rate | FLOAT | stays ÷ entries |
| purchase_rate | FLOAT | purchases ÷ entries |
| created_at | TIMESTAMP | 集計生成日時（UTC） |

---

## 📌 2. `hourly_summary_table`

### 用途
- ドリルダウンや1時間単位グラフ用

### スキーマ（上記に hour を追加）

| カラム名 | 型 | 説明 |
|:---|:---|:---|
| date | DATE | 日付 |
| hour | INTEGER | 時間（0〜23）|
| client_id | STRING | クライアントID |
| store_id | STRING | 店舗ID |
| traffic | INTEGER | 通行量 |
| entries | INTEGER | 入店数 |
| stays | INTEGER | エリア滞在数 |
| purchases | INTEGER | 購買数 |
| entry_rate | FLOAT | entries ÷ traffic |
| stay_rate | FLOAT | stays ÷ entries |
| purchase_rate | FLOAT | purchases ÷ entries |
| source | STRING | データソース（actcast/manual/pos等）|
| created_at | TIMESTAMP | 集計生成日時（UTC） |

---

## 📌 3. `timeseries_metrics_table`

### 用途
- metric別の推移取得用（拡張性高い形式）

### スキーマ

| カラム名 | 型 | 説明 |
|:---|:---|:---|
| date | DATE | 日付 |
| hour | INTEGER | 時間（null許容） |
| client_id | STRING | クライアントID |
| store_id | STRING | 店舗ID |
| metric_type | STRING | 指標名（traffic, entries, purchasesなど） |
| value | FLOAT | 指標値 |
| source | STRING | データソース |
| created_at | TIMESTAMP | 集計生成日時 |

---

# 📘 時系列集計ビュー（補助分析）

> Viewではなく、Cloud Scheduler等で定期的に物理テーブルとして生成推奨

| テーブル名 | 集約軸 | 用途 |
|:---|:---|:---|
| `dashboard_weekday_summary` | weekday(0=日) | 曜日別傾向 |
| `dashboard_hourly_summary` | hour(0–23) | 時間帯傾向 |
| `dashboard_monthly_summary` | month | 月別集計（例: 2025-04） |
| `dashboard_quarterly_summary` | quarter | 四半期単位（例: 2025-Q2） |
| `dashboard_yearly_summary` | year | 年単位 |

---

### 🔁 集計方式：例（SQL）

```sql
CREATE OR REPLACE TABLE coumera.dashboard_weekday_summary AS
SELECT
  client_id,
  store_id,
  EXTRACT(DAYOFWEEK FROM date) AS weekday,
  AVG(traffic) AS avg_traffic,
  AVG(entries) AS avg_entries,
  AVG(purchases) AS avg_purchases
FROM coumera.hourly_summary_table
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY client_id, store_id, weekday
```

---

## ✍️ 変更履歴

| 日付 | 内容 | 編集者 |
|:---|:---|:---|
| 2025-04-28 | 初版作成 | 51h |
| 2025-04-29 | 集計済みテーブル構成にリファイン、時間/曜日/月別対応を追記 | 51h |

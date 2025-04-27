# BigQuery テーブルスキーマ（QuuMo-web連携まとめ）

---

## FaceInsight

### テーブル名
`your_dataset_name.FaceInsight`

### テーブル説明
Actcast FaceInsightアプリケーションから取得した来店者属性情報を格納するためのテーブル。

### スキーマ一覧

| カラム名 | データ型 | 説明 |
|:---|:---|:---|
| date_at | DATE | 計測対象の日付 |
| hour | INTEGER | 計測対象の時間（0〜23時） |
| deviceid | STRING | 計測デバイスの一意なID |
| devicename | STRING | デバイスの設置場所名称または任意名 |
| age | FLOAT | 推定年齢（数値型、例：32.5歳など） |
| gender | STRING | 推定性別（例: male, female） |
| genderscore | FLOAT | 性別推定の信頼度スコア（0〜1.0） |
| direction | STRING | 通過方向情報（例: forward, backward） |
| tags | STRING | 検出対象に付与されたタグ情報（カンマ区切り想定） |
| created_at | DATETIME | レコード作成日時（UTC基準） |

---

## IdleInsight

### テーブル名
`your_dataset_name.IdleInsight`

### テーブル説明
Actcast IdleInsightアプリケーションから取得した、エリア内の滞留データを格納するためのテーブル。

### スキーマ一覧

| カラム名 | データ型 | 説明 |
|:---|:---|:---|
| date_at | DATE | 計測対象の日付 |
| hour | INTEGER | 計測対象の時間（0〜23時） |
| deviceid | STRING | 計測デバイスの一意なID |
| devicename | STRING | デバイスの設置場所名称または任意名 |
| area_id | INTEGER | 滞留エリアID |
| duration | FLOAT | 滞留時間（秒単位） |
| intime | DATETIME | エリアへの入場時刻（UTC） |
| outtime | DATETIME | エリアからの退出時刻（UTC） |
| tags | STRING | 検出対象に付与されたタグ情報（カンマ区切り想定） |
| created_at | DATETIME | レコード作成日時（UTC基準） |

---

## VisionInsight

### テーブル名
`your_dataset_name.VisionInsight`

### テーブル説明
Actcast VisionInsightアプリケーションから取得した、個別人物追跡・滞留データを格納するためのテーブル。

### スキーマ一覧

| カラム名 | データ型 | 説明 |
|:---|:---|:---|
| date_at | DATE | 計測対象の日付 |
| hour | INTEGER | 計測対象の時間（0〜23時） |
| deviceid | STRING | 計測デバイスの一意なID |
| devicename | STRING | デバイスの設置場所名称または任意名 |
| age | STRING | 推定年齢カテゴリ（例: 20s, 30s） |
| gender | STRING | 推定性別（例: male, female） |
| mask | BOOLEAN | マスク着用の有無（true/false） |
| in_position | STRING | 検出開始時の座標/エリア情報 |
| in_timestamp | DATETIME | 検出開始時刻（UTC） |
| out_position | STRING | 検出終了時の座標/エリア情報 |
| out_timestamp | DATETIME | 検出終了時刻（UTC） |
| frontal_time | FLOAT | 正面を向いていた累計時間（秒単位） |
| frontal_list | STRING | 正面向き検出リスト（詳細情報、JSON形式想定） |
| tags | STRING | 対象に付与された任意タグ（カンマ区切り） |
| created_at | DATETIME | レコード作成日時（UTC基準） |

---

## WalkerInsight

### テーブル名
`your_dataset_name.WalkerInsight`

### テーブル説明
Actcast WalkerInsightアプリケーションから取得した、ライン通過人数データを格納するためのテーブル。

### スキーマ一覧

| カラム名 | データ型 | 説明 |
|:---|:---|:---|
| date_at | DATE | 計測対象の日付 |
| hour | INTEGER | 計測対象の時間（0〜23時） |
| deviceid | STRING | 計測デバイスの一意なID |
| devicename | STRING | デバイスの設置場所名称または任意名 |
| line_id | INTEGER | 計測ラインID |
| forward | INTEGER | 順方向（通常、入店方向）で通過した人数 |
| backward | INTEGER | 逆方向（通常、退店方向）で通過した人数 |
| tags | STRING | 記録対象に付与された任意タグ情報（カンマ区切り想定） |
| created_at | DATETIME | レコード作成日時（UTC基準） |

---

# 変更履歴

| 日付 | 内容 | 編集者 |
|:---|:---|:---|
| 2025-04-27 | 初版作成 | 51h |

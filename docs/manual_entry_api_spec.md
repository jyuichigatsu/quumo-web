# API設計：手動入力データ管理API v0.2

---

## 1. POST `/api/manual-entry`

### 用途
- 手入力された来店/通行/購買等のデータを保存する

### 認証
- Firebase Authenticationトークン（Bearer Token）を必須

### リクエストBody（JSON）
```json
{
  "client_id": "client_abc",
  "store_id": "store_xyz",
  "date": "2025-04-28",
  "hour": 14,
  "traffic": 1200,
  "entries": 300,
  "stays": 180,
  "purchases": 75,
  "notes": "GWイベント開催日"
}
```

### バリデーションルール
| フィールド | バリデーション |
|:---|:---|
| `client_id` / `store_id` | 存在確認（ログインユーザーが所属） |
| `date` | 過去90日以内 / 未来日不可 |
| `hour` | 0〜23 or null |
| `traffic`, `entries`, `stays`, `purchases` | 0以上の整数 |
| `notes` | 255文字以内 |

### 保存先
- BigQuery: `quumo.manual_entry_table`
- Firebase: ログインユーザーから `user_id` を自動挿入

### 成功レスポンス（200 OK）
```json
{
  "status": "success",
  "message": "Data saved",
  "data_id": "entry_abc123"
}
```

### 失敗レスポンス
- 400 Bad Request
- 401 Unauthorized

---

## 2. PATCH `/api/manual-entry/{id}`

### 用途
- 既存の手動入力データを更新する（部分更新対応）

### 認証
- Firebase Authenticationトークン必須

### リクエストBody（JSON）
```json
{
  "traffic": 1200,
  "entries": 320,
  "stays": 200,
  "purchases": 75,
  "notes": "修正後メモ"
}
```

### バリデーションルール
| フィールド | バリデーション |
|:---|:---|
| `traffic`, `entries`, `stays`, `purchases` | 0以上の整数 |
| `notes` | 255文字以内 |

### 更新内容
- 対象レコードを部分更新
- `updated_at` を上書き

### 成功レスポンス（200 OK）
```json
{
  "status": "success",
  "message": "Entry updated",
  "data_id": "entry_abc123"
}
```

### エラーレスポンス
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found

---

## 3. DELETE `/api/manual-entry/{id}`

### 用途
- 手動入力データを削除（ソフトデリート）

### 認証
- Firebase Authenticationトークン必須

### 処理内容
- `deleted_at` フィールドに現在時刻をセット（物理削除しない）

### 成功レスポンス（200 OK）
```json
{
  "status": "success",
  "message": "Entry deleted (soft)"
}
```

### エラーレスポンス
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found

---

## ✍️ 変更履歴
| 日付 | 内容 | 編集者 |
|:---|:---|:---|
| 2025-04-29 | 初版作成（POSTのみ） | 51h |
| 2025-04-29 | PATCH / DELETEエンドポイントを追記 | 51h |


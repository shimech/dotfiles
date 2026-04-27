---
name: n-plus-one
description: データベースにアクセスするコードを書く・直す前後で必ず使用するスキル。N+1 クエリが発生していないかを機械的に検査する。ORM 呼び出し・リポジトリ層・GraphQL resolver・REST handler・バッチ処理など、ループとクエリが共存しうるあらゆる場面で発動。「DB アクセス書いて」「クエリ追加して」「一覧取得して」「ユーザーごとに〜取得」「N+1」「eager load」「preload」「include」「JOIN にして」などのトリガーで使用。
---

# N+1 Query Check

DB を触るコードを書く・直すなら、このスキルを通す。N+1 クエリは「書いた瞬間は動くが、データが増えると指数的に遅くなる」最も埋め込みやすい性能バグ。Claude が特に犯しやすいので、機械的に検査する。

## いつ使うか

**SQL・ORM・リポジトリ・データソース・GraphQL resolver・REST handler・バッチジョブを編集するすべての作業で、着手前と完了後に通す。** 「指示通り取れていれば OK」では足りない。**取得回数のオーダー** を必ず検査する。

トリガーになる典型シグナル:
- `for` / `forEach` / `map` / `Promise.all(items.map(...))` の中に DB 呼び出しがある
- 関数の戻り値に配列があり、その各要素を別関数で「整形」「拡張」している
- GraphQL の field resolver で親オブジェクトの `id` から子を引いている
- ORM の lazy relation（`user.posts` / `user.profile` など）にループ内でアクセス
- 「一覧 + 各行の詳細」「ユーザーごとに〜」「件ごとに〜」という仕様

## ステップ 1: クエリ発生点の棚卸し（変更前）

まず **「このリクエスト / 関数で発行される SQL の本数を、入力サイズの関数として書き出す」**。沈黙して書き始めない。

成果物: 「**発行されるクエリの本数を入力サイズ N の式で表したもの**」と「**N に依存して増える呼び出し点の一覧**」。

例:
```
入力: userIds (N 件)
- users 取得: 1 回
- 各 user の posts 取得: N 回   ← N+1
- 各 post の comments 取得: N*M 回   ← さらに悪化
合計: 1 + N + N*M
```

この時点で `N` や `N*M` が出ていれば N+1 確定。書く前に潰す。

## ステップ 2: 検出パターン（grep / 目視）

以下のパターンを **着手前と完了後の両方で** 検査する。該当しないものは「該当なし」と明示。

### 2-1. ループ内 DB 呼び出し

```ts
// BAD
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { userId: user.id } });
}

// BAD（Promise.all で並列化しても N+1 は N+1）
const results = await Promise.all(
  users.map(u => prisma.post.findMany({ where: { userId: u.id } }))
);
```

検出 grep の例:
- `rg -n "for .*\{[\s\S]*?(prisma|knex|db|repo|repository|query|find|select)\." -U`
- `rg -n "\.map\(.*=>\s*(await\s+)?(prisma|knex|db|repo)" `
- `rg -n "forEach\(.*=>\s*(await\s+)?(prisma|knex|db|repo)"`

### 2-2. ORM の lazy relation 経由アクセス

| ORM / 言語 | 危険な書き方 | 正しい書き方 |
|---|---|---|
| **Prisma (TS)** | `findMany` 後に `result.posts` を触る（include なし） | `include: { posts: true }` / `select` で関連取得 |
| **TypeORM (TS)** | `find` で `relations` 指定なし → `entity.posts` | `relations: ['posts']` / `leftJoinAndSelect` |
| **Sequelize (TS/JS)** | `findAll` 後に `instance.getX()` | `include: [{ model: X }]` |
| **Drizzle (TS)** | `db.query.users.findMany()` で `with` なし | `with: { posts: true }` |
| **ActiveRecord (Ruby)** | `User.all.each { \|u\| u.posts }` | `User.includes(:posts)` / `preload` / `eager_load` |
| **Django ORM (Py)** | `User.objects.all()` 後の `user.posts.all()` | `select_related('profile')` / `prefetch_related('posts')` |
| **SQLAlchemy (Py)** | デフォルトの lazy=`select` でループ内アクセス | `selectinload()` / `joinedload()` / `lazy='selectin'` |
| **GORM (Go)** | `db.Find(&users)` 後に `user.Posts` | `db.Preload("Posts").Find(&users)` |
| **Ent (Go)** | `WithPosts()` を付け忘れ | `client.User.Query().WithPosts().All(ctx)` |
| **sqlx / 生 SQL (Go/Rust)** | 親クエリ → 子をループで `SELECT WHERE id = ?` | `WHERE id IN (?)` で一括 → アプリ側で再構成 |

### 2-3. GraphQL field resolver

```ts
// BAD: 親が複数件返るとき、resolver が件数分発火する
Post: {
  author: (post) => userRepo.findById(post.authorId),
}
```

正しくは **DataLoader** でバッチ化:
```ts
const userLoader = new DataLoader(ids => userRepo.findByIds(ids));
Post: {
  author: (post) => userLoader.load(post.authorId),
}
```

### 2-4. シリアライザ / ビュー層での遅延取得

- Rails view で `<%= @users.each { \|u\| u.profile.name } %>`
- DRF / GraphQL serializer 内で `obj.related.something`
- Next.js の RSC で props を回しながら `await fetchX(item.id)`

「presentation 層に着いてから DB を引く」は最頻出の見落とし。**呼び出し元の loop と組み合わさって初めて N+1 になる** ため、関数単体では気付けない。**呼び出し元まで辿る**。

### 2-5. キャッシュ / メモ化されているように「見える」だけ

```ts
// BAD: 同一トランザクション内でも毎回クエリが飛ぶ
function getUser(id) { return prisma.user.findUnique({ where: { id } }); }
items.map(i => getUser(i.userId)); // ← N 回発行
```

「関数で包んだから安全」は誤り。**実際にキャッシュ層 / DataLoader / identity map があるか** を確認する。

## ステップ 3: 解消パターン

検出したら、以下のいずれかで潰す。

### 3-1. Eager loading / preload / include

最も素直。ORM の機能で 1〜2 クエリにまとめる。

```ts
// Prisma
const users = await prisma.user.findMany({
  where: { id: { in: ids } },
  include: { posts: { include: { comments: true } } },
});
```

注意点:
- ネストが深いと **Cartesian explosion**（行数が積で爆発）が起きうる。`select` で必要列だけにする / `prefetch` 系（別クエリ + JOIN）に切り替える
- 1:N が複数並ぶと JOIN が爆発する。SQLAlchemy の `selectinload` / Django の `prefetch_related` のように **別クエリでまとめて IN 取得** する戦略が有利な場合あり

### 3-2. IN 句で一括取得 + アプリ側で再構成

ORM の機能が貧弱、または生 SQL のとき:

```ts
const userIds = items.map(i => i.userId);
const users = await db.query(`SELECT * FROM users WHERE id IN (?)`, [userIds]);
const byId = new Map(users.map(u => [u.id, u]));
const enriched = items.map(i => ({ ...i, user: byId.get(i.userId) }));
```

注意:
- IN 句の **要素数上限**（PostgreSQL は実用上 数千〜、Oracle は 1000、SQLite は 999）。超える場合は chunk
- `Map` 化を忘れて再度 `users.find(...)` するとアプリ側で O(N²) になる

### 3-3. DataLoader（GraphQL / 多層 resolver）

リクエスト単位でバッチ + キャッシュ。`facebook/dataloader` 系を使う。

```ts
const loader = new DataLoader(async (ids: string[]) => {
  const rows = await userRepo.findByIds(ids);
  const byId = new Map(rows.map(r => [r.id, r]));
  return ids.map(id => byId.get(id) ?? null); // 順序保持が必須
});
```

注意:
- **返却順は入力 ids の順序** に揃える（DataLoader の契約）
- リクエスト跨ぎでインスタンスを使い回すと、別ユーザーのデータが漏れる

### 3-4. JOIN を生 SQL で書く

ORM が複雑になりすぎるなら素の SQL に降りる。N+1 を避けるためだけに ORM のために変な抽象を書かない。

### 3-5. そもそも取得しない

「画面で使っていない関連」を ORM のデフォルトで引いていないか。**必要なときだけ取得する** ように設計を見直す（`ideal` skill にバトン）。

## ステップ 4: 完了後の検査

修正後に必ず実行する。

1. **発行クエリ本数を再カウント**: ステップ 1 と同じ式を再度書き、N に依存しないこと（定数 or O(log N)）を確認する。
2. **実測で確認できる手段があれば実測する**:
   - Rails: `Bullet` gem / `ActiveRecord::Base.logger`
   - Django: `django-debug-toolbar` / `connection.queries`
   - Prisma: `log: ['query']` を有効化してテスト実行
   - SQLAlchemy: `echo=True` / `sqlalchemy.engine` ロガー
   - GORM: `db.Debug()` / `Logger.LogMode`
   - 一般: テスト中に発行クエリ数を assert する仕組み（`expect(queryCount).toBe(2)` のような）
3. **テスト**: N=1 と N=10 など **件数を変えて** 動作させ、クエリ本数が件数に比例しないことを確認。比例していたら N+1 が残っている。
4. **EXPLAIN（疑わしいとき）**: JOIN にした場合は `EXPLAIN` で行数推定を確認。Cartesian explosion の兆候がないか。
5. **境界条件**: N=0（空配列）、N=1、N が IN 句上限超えのケースを確認。
6. **キャッシュ前提を疑う**: 「DataLoader / identity map があるから大丈夫」と判断したなら、その層が **本当にこのコードパスを通る** ことを確認。

スキップする項目があれば理由を報告に明記する。沈黙してスキップしない。

## ステップ 5: 報告

```
## N+1 チェック結果

### 対象
<関数 / エンドポイント / resolver>

### クエリオーダー
- 修正前: 1 + N + N*M  (users + 各 user の posts + 各 post の comments)
- 修正後: 3            (users / posts (IN) / comments (IN))

### 適用した解消パターン
- include / IN 一括 / DataLoader / JOIN / その他

### 検証
- 実測手段: Prisma `log: ['query']` を有効化してテストで発行回数を確認 / Bullet で警告ゼロ / etc.
- N=10 で発行: 3 回（件数非依存を確認）
- 境界: N=0 / N=1 / IN 上限超え (chunk あり / なし)

### 残課題と理由
- `legacy/oldHandler.ts:120` — 別 PR で対応 / 呼び出し頻度が極小なため一旦保留
```

## よくある罠

- **`Promise.all` で並列化したから OK と勘違い**: 並列でも DB に投げる本数は同じ。コネクション枯渇でむしろ悪化することすらある。
- **「関数で包んだから一回で済む」**: メモ化していなければ毎回発行。**実装を読まずにキャッシュを仮定しない**。
- **`include` を足したつもりが `select` で打ち消し**: Prisma で `select` を指定すると `include` は使えない。relation を `select` 内で明示する。
- **JOIN 爆発に気付かない**: 1:N を 2 本 JOIN すると行数が積で増える。1 行のオーダーで遅くなり、メモリも食う。`prefetch` 別クエリ戦略に切り替える。
- **件数 1 でテストして満足**: `expect(query).toHaveBeenCalledTimes(1)` のような検査を **N=1 だけ** で書いて N+1 を見逃す。**N を変えて検査する**。
- **GraphQL resolver 単体だけ見る**: resolver は親が複数件返ったときだけ N+1 になる。**呼び出し元を辿る**。
- **lazy relation のデフォルトを忘れる**: TypeORM / SQLAlchemy はデフォルトが lazy。「明示的に eager にしていない＝ N+1 確定」。
- **キャッシュの有効範囲を超える**: DataLoader はリクエストスコープが原則。バックグラウンドジョブ / cron では別途設計。
- **「ユーザーには見えないから」と先延ばし**: データ増加で線形以上に悪化する。**初回実装で潰す** のが圧倒的に安い。

## 他 skill との連携

- **`coherence`** — 影響範囲調査の延長として N+1 を検査するときに、相互に呼び合う。コード変更全般の整合性は coherence、DB アクセスの本数検査は本 skill。
- **`ideal`** — 「そもそもこのデータ取得自体が責務として正しいか」まで遡るときに委譲。
- **`best-practice`** — 採用 ORM の最新の eager loading 推奨 API を裏取りしたいとき。
- **`rethink`** — 「include を盛りすぎて逆に遅くなっていないか」など、決めた方針自体を疑い直したいとき。

---
name: ci-monitor
description: CIの状態を確認し、失敗していれば原因を分析・修正してpushし、成功するまで監視を続けるスキル。「CI確認して」「CIが落ちてる」「CI直して」「CIの状態見て」「CI通るまでお願い」「greenにして」などのトリガーで使用。CI/CD、GitHub Actions、テスト失敗、ビルドエラーに関連する話題では積極的に使用する。
---

# CI Monitor

CIを監視し、失敗を修正し、成功するまで面倒を見るスキル。

## 現在のCIステータス
!`bash ${CLAUDE_SKILL_DIR}/scripts/gh-ci-status.sh $ARGUMENTS`

## ワークフロー

1. 上記のCIステータスを分析
2. 状態に応じた対応（実行中→待機、失敗→修正、成功→完了）
3. 成功するまでループ

## ステータス再取得

ループ時やpush後の再確認:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/gh-ci-status.sh
```

オプション: `--branch <name>`, `--repo <owner/repo>`

## 状態に応じた対応

### 実行中 (in_progress / queued)

バックグラウンドでポーリングし、完了時に `gh-ci-status.sh` の結果を返す（`run_in_background` を使用）:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/gh-ci-poll.sh
```

オプション: `--interval <seconds>`（デフォルト20秒）, `--branch <name>`, `--repo <owner/repo>`

ポーリング開始時にユーザーに「CIの完了を待っています」と伝える。
通知が届いたら、返された結果（`gh-ci-status.sh` と同じ形式）をそのまま使って対応に進む。

### 失敗 (failure)

CIステータスの出力にアノテーション（ファイル・行番号・メッセージ）または失敗ログが含まれるので、直接修正箇所を特定できる。

修正するときは、同じパターンの箇所が他にないか確認し、あればまとめて直す。

- **修正が明確な場合**: コード修正 → commit → push → ステータス再取得へ戻る
- **判断が難しい場合**: ユーザーに尋ねる（後述）

### 成功 (success)

ユーザーに報告して完了。

## 修正とpush

```bash
git add <files>
git commit -m "$(cat <<'EOF'
<type>(<scope>): <message>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push
```

**コミットメッセージには必ず `Co-Authored-By: Claude <noreply@anthropic.com>`
署名を含める**（Claude Code のグローバル方針。例外なし）。モデル名・版は
Claude Code 本体の指示に合わせて差し替えて構わないが、署名そのものは省略しない。

push後はステータス再取得に戻り、新しいCI runを監視する。

## ユーザーに尋ねるべき場面

以下の場合は自分で判断せず、状況を説明してユーザーの指示を仰ぐ:

- **自分の変更と無関係に見える失敗**: flakyに見えても、自分の変更が影響していないか一度確認してから判断する
- **複数の修正方針がある**: テストを直すべきかコードを直すべきか判断がつかない
- **設計・アーキテクチャに関わる変更**: 型の変更、API変更、依存関係の追加など
- **テストをスキップ・削除する判断**: テスト自体が間違っている可能性がある場合
- **3回以上同じCIが失敗**: ループしている可能性があるので方針を再検討

尋ねるときは、失敗内容・考えられる原因・選択肢を簡潔に提示する。

## 注意事項

- ポーリング中はバックグラウンド実行を使い、トークン消費を最小限にする
- push先は現在のブランチ。force pushはしない
- 修正コミットは問題ごとに分ける（1修正1コミット）

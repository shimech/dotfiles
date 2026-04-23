---
name: wt
description: Use when the user wants to create a git worktree, set up a `.worktreerc` for a repo, sync gitignored files (like `.env`) into a worktree, or launch tmux windows tied to a branch. Triggers on phrases like "make a worktree", "set up wt for this repo", "sync .env to the worktree", "add a tmux layout for my branch", "create .worktreerc".
---

# wt — per-branch worktree + env setup + tmux launcher

`wt` is a shell command installed from this dotfiles repo at `bin/wt`
(symlinked to `~/.local/bin/wt`). It wraps `git worktree add` with:

1. Fixed path convention — `<repo-root>/.claude/worktrees/<sanitized-branch>`
2. Sync of gitignored files (e.g. `.env`) from the primary checkout into the worktree
3. Per-repo environment setup (e.g. `mise install`, `pnpm install`)
4. tmux window launch (current session if inside tmux, new session otherwise)

The `wt` command itself is generic. All repo-specific policy lives in a single
file per repo: `<repo-root>/.worktreerc` (a shell script sourced by `wt`).
Globally gitignored via `.config/git/ignore`.

## Invocation

```sh
wt <branch>                 # new branch from HEAD, or jump to existing worktree
wt <branch> --from main     # new branch based on main
wt attach                   # fzf over existing worktrees, run only the tmux hook
wt attach <branch>          # direct-select an existing worktree by branch
wt-switch                   # fzf over existing branches, then wt
```

Idempotent: running `wt <branch>` a second time just reuses the existing worktree.

`wt attach` is the lightweight form for jumping back into a worktree you
already set up. It skips `WT_SYNC_PATHS` and `wt_env_setup` and only runs
`wt_tmux_windows` (or the default single-window fallback), using the selected
worktree's path as the cwd.

## Per-repo config: `.worktreerc`

Three optional hooks. `.worktreerc` is a shell script (no extension); `wt`
sources it after creating the worktree but before syncing / env setup / tmux.

```bash
# Paths relative to the repo root to rsync into the new worktree.
# Usually gitignored files that dev needs (env, local settings).
WT_SYNC_PATHS=(
  ".env"
  ".env.local"
  ".claude/settings.local.json"
)

# Runs with cwd = the new worktree directory.
wt_env_setup() {
  mise install
  pnpm install
}

# Runs with these vars available:
#   $WT_PATH       absolute path of the new worktree
#   $WT_BRANCH     branch name (unsanitized, e.g. feat/foo)
#   $WT_REPO_ROOT  primary working tree root
# Inside tmux: windows are added to the current session.
# Outside tmux: `wt` starts a "wt-<repo>-<sanitized>" session first, then
# calls this function targeting that session.
wt_tmux_windows() {
  tmux new-window -n "[api] $WT_BRANCH" -c "$WT_PATH"
  tmux send-keys "claude" C-m

  tmux new-window -n "[api][dash] $WT_BRANCH" -c "$WT_PATH"
  tmux send-keys "colima-start && pnpm run docker:db" C-m
}
```

If a hook isn't defined, `wt` falls back:
- No `WT_SYNC_PATHS` → nothing is synced
- No `wt_env_setup` → no setup step
- No `wt_tmux_windows` → one window named `[<repo>] <branch>` at `$WT_PATH`

## Common tasks

### "Set up wt for this repo"

1. Read `.gitignore` and the user's workflow docs to find which gitignored
   files are needed for dev (commonly `.env`, `.env.local`, `.envrc`,
   `.claude/settings.local.json`, IDE-local configs).
2. Detect the package manager / runtime manager from files in the repo:
   - `mise.toml` / `.tool-versions` → `mise install`
   - `pnpm-lock.yaml` → `pnpm install`
   - `yarn.lock` → `yarn install`
   - `package-lock.json` → `npm install`
   - `go.mod` → `go mod download`
   - `Gemfile` → `bundle install`
   - `requirements.txt` / `pyproject.toml` → ask the user, Python setup varies
3. Ask the user what tmux layout they want (single window? multi-window like
   NeMS.yml does with editor + dashboard?).
4. Write `<repo>/.worktreerc` with the three hooks.
5. Remind the user the file is gitignored globally (so no commit needed).

### "Add more files to sync"

Edit `WT_SYNC_PATHS` in `<repo>/.worktreerc`. Paths are relative
to the repo root. Directories work too (rsync -a --relative preserves the
tree). If the path doesn't exist at sync time, it's silently skipped.

### "Worktree already exists error"

`wt` reuses existing worktrees by design. If you hit a real conflict
(stale worktree, dangling lock), clean up manually:

```sh
git worktree list                                  # see what's registered
git worktree remove <repo>/.claude/worktrees/<x>   # remove a worktree
git worktree prune                                 # drop stale references
```

### "I want tmuxinator-style multi-window output"

`wt_tmux_windows` can do anything `tmux` supports. For layouts similar to
`~/.config/tmuxinator/NeMS.yml`:

```bash
wt_tmux_windows() {
  local base="[repo] $WT_BRANCH"

  tmux new-window -n "$base" -c "$WT_PATH"
  tmux split-window -h -t "$base" -c "$WT_PATH"
  tmux split-window -v -t "$base" -c "$WT_PATH"
  tmux send-keys -t "$base.0" "claude" C-m
  tmux send-keys -t "$base.1" "vim ." C-m

  tmux new-window -n "[repo][dash] $WT_BRANCH" -c "$WT_PATH"
  tmux send-keys "pnpm run dev" C-m
}
```

## Critical files in this dotfiles repo

- `bin/wt` — the command itself
- `bin/setup.sh` — installs the `~/.local/bin/wt` symlink
- `.zshrc` — defines `wt-switch` (fzf → wt)
- `.config/git/ignore` — excludes `.claude/worktrees/`, `*.local.*`, and `.worktreerc`

## Non-goals

- Automatic invocation from git hooks (user triggers `wt` explicitly)
- Editing `.gitignore` to hide the worktree dir (already handled globally)
- Syncing state *back* from worktree to primary (one-way only)

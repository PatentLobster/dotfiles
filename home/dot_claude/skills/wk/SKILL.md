---
name: wk
description: >-
  Find or add tmux/Neovim keybindings for THIS user's chezmoi-managed dotfiles
  (invoke as /wk; "wk" = which-key / keybindings).
  Use whenever the user asks how to do something in tmux or nvim ("how do I
  split a pane", "what's the keybinding for...", "is there a shortcut to...",
  "rebind X", "add a mapping for Y", "I want a hotkey that..."), or asks to
  change/add a tmux or nvim shortcut. Trigger even when they don't say
  "keybinding" — phrasings like "how do I jump to the next window in tmux" or
  "make space-f open files in neovim" count. Resolves the live binding against
  their actual config, and if none exists, adds it to the chezmoi source and
  runs chezmoi apply (never commits, never pushes).
---

# keybindings-finder

Answer "how do I do X in tmux/nvim with *my* setup?" — find the existing binding, or add one. **Lead with the answer/commands**, then keep it tight. Terse is the goal, but *terse ≠ incomplete* — a complete short answer beats a clipped one. List every relevant binding, not just the first; a one-line discovery pointer or nav tip earns its place when it helps the user self-serve next time. Skip the intro essay and the recap.

## Source files (edit these, never the rendered `$HOME` copies)

| What | chezmoi source | Live target |
|------|----------------|-------------|
| tmux | `$(chezmoi source-path)/dot_tmux.conf.local` | `~/.tmux.conf.local` |
| nvim | `$(chezmoi source-path)/dot_config/nvim/lua/mappings.lua` | `~/.config/nvim/lua/mappings.lua` |

Get the repo root with `chezmoi source-path` (don't hardcode it). **Never edit `dot_tmux.conf` — that's upstream gpakosz.** Prefix is `C-b` (and `C-a` as `prefix2`). nvim leader is space; defaults come from NvChad, tmux defaults from gpakosz.

## Step 1 — Find the existing binding (live + source)

Run the relevant discovery, don't guess from memory:

**tmux:**
```sh
tmux list-keys 2>/dev/null | grep -iE '<keyword>'        # live, includes gpakosz defaults
grep -nE '<keyword>' "$(chezmoi source-path)/dot_tmux.conf.local"
```

**nvim:** grep the source; for NvChad defaults the user can't recall, point them to `<leader>` + which-key or `:Telescope keymaps`.
```sh
grep -nE '<keyword>' "$(chezmoi source-path)/dot_config/nvim/lua/mappings.lua"
```

If it exists, report it and stop. **List all the relevant bindings you found**, not just one — the user often half-remembers there are several. Rank best-first when there's more than one, mark the recommended, one-line why each:
```
1. <leader>ff  — Telescope find files (fuzzy, recommended)   Space f f
2. <leader>fw  — live grep (search file contents)            Space f w
3. <leader>fa  — find all incl. hidden/ignored               Space f a
```
End find answers with a one-line **discovery pointer** so they can browse the rest themselves:
- tmux → `prefix Space` (which-key menu)
- nvim → `Space` (which-key), `:Telescope keymaps`, or NvChad cheatsheet `Space c h`

Add a nav/usage tip only when it's genuinely useful (e.g. "in Telescope, `C-v` opens in a vertical split"). Don't pad.

## Step 2 — Doesn't exist? Propose, then add it

State the binding you'll add and the exact line, then edit the source + apply. Don't ask permission for the apply (the user already opted into add-and-apply) — but never commit/push.

**tmux** — append near the other `bind` lines in `dot_tmux.conf.local`:
```sh
# example: bind | split-window -h -c "#{pane_current_path}"
```
**nvim** — add a `map(...)` under the `-- add yours here` section of `mappings.lua` with a `desc`.

Pick a key that's **free** — re-run the Step 1 discovery on the candidate key first; if taken, pick another and say so.

## Step 3 — Apply + reload

```sh
chezmoi diff && chezmoi apply        # chezmoi knows its own source root — no cd needed
```
- **tmux**: `tmux source ~/.tmux.conf 2>/dev/null` (only if a tmux server is running) → binding is live now.
- **nvim**: mappings load on next nvim launch (or `:so ~/.config/nvim/lua/mappings.lua`). Say so — don't claim it's live in a running instance.

Report the final binding in one line.

## Output rules

- Commands and the answer first. No intro paragraph, no "Great question!", no summary essay.
- One line of context max around each command block.
- Rank options when there's more than one; mark the recommended one.
- Never `git commit` / `git push`.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal, cross-platform dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). The working tree is chezmoi's *source directory* — files here use chezmoi's naming conventions and template syntax, and chezmoi renders them into `$HOME` on `apply`.

## Critical: the source root is `home/`, not the repo root

`.chezmoiroot` contains `home`, so chezmoi treats `home/` as the source directory. Everything chezmoi manages lives under `home/`. The repo root holds only meta files (`README.md`, `install.sh`, `scripts/`, CI). When editing a managed dotfile, edit the source under `home/` — never the rendered file in `$HOME` directly (it will be overwritten on next apply).

## chezmoi naming conventions (how to read filenames)

Filenames encode metadata via prefixes; the rendered target name strips them:
- `dot_foo` → `~/.foo` (e.g. `dot_zshrc.tmpl` → `~/.zshrc`)
- `*.tmpl` → rendered as a Go text/template with chezmoi's `.chezmoi.*` and `[data]` variables
- `executable_foo` → target gets `+x` (the `home/dot_dotfiles/bin/` scripts)
- `encrypted_*.age` → age-encrypted (e.g. `encrypted_dot_gitconfig.age`); `--exclude=encrypted` skips these
- `create_dot_foo` → created only if absent, never overwritten
- `run_once_*` → script run once (tracked by content hash); `run_onchange_*` → re-run when the script's content changes; numeric prefixes (`01_`) order them

## Common commands

```sh
chezmoi apply              # render source → $HOME (the core "deploy my changes" command)
chezmoi diff               # preview what apply would change
chezmoi edit ~/.zshrc      # edit the source file backing a target, then apply
chezmoi cd                 # drop into the source dir (here)
chezmoi data               # dump the template variables available to .tmpl files
chezmoi execute-template < file.tmpl   # test-render a template
```

After editing any file under `home/`, run `chezmoi diff` then `chezmoi apply` to deploy. There is no build step.

## Testing

CI (`.github/workflows/ci.yaml`) runs `scripts/test.sh` across a matrix of OS variants. The test harness installs the dotfiles from scratch inside throwaway Docker containers (`mcr.microsoft.com/devcontainers/base`) to verify a clean install works.

```sh
scripts/test.sh --variant devcontainer --os ubuntu-22.04   # run one matrix cell
scripts/test.sh --variant wsl --os ubuntu-20.04            # WSL-shim variant
scripts/test.sh --variant darwin                           # runs ./scripts/install.sh locally (no Docker)
scripts/test.sh -d ...                                     # -d enables DOTFILES_DEBUG
scripts/docker_test.sh                                     # install in a container and drop into an interactive zsh
```

Test plumbing (`DOTFILES_TEST=true`, `REMOTE_CONTAINERS`) suppresses interactive prompts during install. `scripts/test.sh` is Argbash-generated — edit the `ARG_*` comments at the top, not the generated parser body.

## Architecture / install flow

1. **Bootstrap** — `install.sh` (repo root, the `https://itz.is/dot` target) installs chezmoi, then `chezmoi init --apply`. `scripts/install.sh` is the version invoked by the test harness; it honors `DOTFILES_ONE_SHOT` / `DOTFILES_DEBUG`.
2. **Config prompt** — `home/.chezmoi.toml.tmpl` prompts once (via `promptStringOnce`/`promptBoolOnce`) for `email`, `storeSecrets`, `installApps`, `installCasks` and writes them into `[data]`. These flags gate template branches throughout the repo. Codespaces (`REMOTE_CONTAINERS` set) skip prompts and take defaults.
3. **External deps** — `home/.chezmoiexternal.toml` pulls third-party code into `~/.dotfiles/` at apply time: oh-my-zsh, zsh plugins (autosuggestions, syntax-highlighting, fzf-tab, etc.), the gpakosz tmux config, and Vundle. These are *not* vendored in git; refreshed every 168h.
4. **`run_` scripts** — `home/dot_dotfiles/scripts/<os>/run_once_before_01_*` install OS packages per platform (`osx`, `debian`, `amzn`, `fedora`); `run_onchange_osx_configure.sh.tmpl` runs `brew bundle` against the Brewfiles. `run_once_after_install.sh.tmpl` does final setup (Mason/vim plugins, `chsh` to zsh). All source `dot_dotfiles/scripts/common.sh` for logging helpers (`info`/`success`/`fail`).

## Shell configuration layout

`~/.zshrc` (`dot_zshrc.tmpl`) is the entry point but is intentionally thin: it sets `$DOTFILES`/`$DOT_ZSH`, picks an OS-specific `plugins=(...)` list and `$PATH`, sources oh-my-zsh, then sources the real config from `~/.dotfiles/zsh/`:
- `home/dot_dotfiles/zsh/aliases.zsh.tmpl` — aliases (note `zshconfig`, `vsync`, etc.)
- `home/dot_dotfiles/zsh/functions.zsh.tmpl` — shell functions
- `home/dot_dotfiles/zsh/custom/themes/lobster.zsh-theme` — the prompt theme
- `home/dot_dotfiles/bin/executable_*` — custom CLI tools, on `$PATH` via `$DOTFILES/bin`

OS branching in templates keys off `.chezmoi.os` (`darwin`/`linux`), `.chezmoi.arch`, and `.chezmoi.osRelease.id` (`amzn` etc.).

## Other managed app configs

Under `home/dot_config/`: `nvim/` (see below), `ghostty/`, `karabiner/`. `home/dot_claude/` ships Claude Code's own `settings.json` and `hooks/` (tmux status + agent-state hooks) into `~/.claude/`.

### tmux (gpakosz/oh-my-tmux)

Two files render into `$HOME`:
- `dot_tmux.conf` → `~/.tmux.conf` is the **upstream gpakosz `.tmux` config — do not edit it.** It carries a `/!\ do not edit this file` banner; chezmoi also pulls the upstream repo into `~/.dotfiles/tmux/plugins/tmux/` via `.chezmoiexternal.toml`. Changes here will be lost / diverge from upstream.
- `dot_tmux.conf.local` → `~/.tmux.conf.local` is **the file to edit** — all personal overrides live here (the gpakosz pattern). It holds the theme colour palette (`tmux_conf_theme_colour_*`), pane/status styling, and behavior toggles like `tmux_conf_new_pane_retain_current_path`.

Prefix is the default `C-b` with `C-a` added as a secondary GNU-screen-style prefix (`prefix2`). Plugins use TPM via the `set -g @plugin` lines near the bottom of `.tmux.conf.local`; the only active one is `alexwforsythe/tmux-which-key` (which-key menu bound to `prefix` + `Space`). `tmux_conf_24b_colour=false` — 24-bit colour is off.

### Neovim (NvChad v2.5 starter)

`home/dot_config/nvim/` is an NvChad **starter** config (not NvChad itself — NvChad is pulled in as a plugin). Structure follows the NvChad convention:
- `init.lua` — bootstraps lazy.nvim, loads `NvChad/NvChad` (branch `v2.5`), then `lua/plugins/`. `<leader>` is space.
- `lazy-lock.json` — the lazy.nvim lockfile; commit it when plugins change.
- `lua/chadrc.lua` — NvChad UI/theme config (`ChadrcConfig`); theme is `onedark`.
- `lua/plugins/init.lua` — **where plugins are added.** Active extras beyond NvChad defaults: `conform.nvim` (formatting), `nvim-lspconfig`, `github/copilot.vim`, and `coder/claudecode.nvim` (Claude Code integration under `<leader>a*`, with `:ClaudeCode*` commands registered via `cmd =` so they exist on a cold start).
- `lua/mappings.lua` — custom keymaps (`;`→`:`, `jk`→Esc, `<leader>gr`/`<leader>gb` Go run/build, Copilot accept on `<C-l>`, `<leader>cc` toggles Claude Code).
- `lua/configs/` — per-plugin setup (`lspconfig.lua`, `conform.lua`, `lazy.lua`). `conform.lua` formats Lua with `stylua`; format-on-save is commented out.
- `.stylua.toml` — formatter config for the Lua in this dir.

Plugins are managed by **lazy.nvim** (`:Lazy`), LSP servers/formatters by **Mason** (`:Mason`); `run_once_after_install.sh.tmpl` runs `:MasonInstallAll` on first install. The `vsync` shell alias copies a live `~/.config/nvim` back into this source tree for iterating outside chezmoi.

## Conventions

- Brew packages are split into `dot_dotfiles/brew/minimal.Brewfile` (gated by `installApps`) and `casks.Brewfile` (gated by `installCasks`).
- Keep changes platform-aware: anything in a `run_` script or `.tmpl` that touches packages/paths should branch on `.chezmoi.os`, and a clean install must still pass `scripts/test.sh` on the Linux variants.
- `vsync` alias copies a live `~/.config/nvim` back into the source tree — handy when iterating on nvim config outside chezmoi.
#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

log_color() {
  color_code="$1"
  shift

  printf '\033[%sm%s\033[0m\n' "${color_code}" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_task() {
  log_blue "🔃" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  log_task "Installing chezmoi to '${chezmoi}'"
  if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL https://get.chezmoi.io)"
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- https://get.chezmoi.io)"
  else
    error "To install chezmoi, you must have curl or wget."
  fi
  sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

# Resolve the repo root (parent of this script's dir). Using $0's path directly
# avoids the broken stdin case (`sh < install.sh`) where command -v resolves to sh.
script_dir="$(cd -P -- "$(dirname -- "$0")/.." && pwd -P)"

set -- init --source="${script_dir}" --verbose=false --exclude=encrypted --no-tty

if [ -n "${DOTFILES_ONE_SHOT-}" ]; then
  set -- "$@" --one-shot
else
  set -- "$@" --apply
fi

if [ -n "${DOTFILES_DEBUG-}" ]; then
  set -- "$@" --debug
fi

log_task "Running 'chezmoi $*'"
# replace current process with chezmoi
exec "${chezmoi}" "$@"
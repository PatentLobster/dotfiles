#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
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


if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL https://get.chezmoi.io)"
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- https://get.chezmoi.io)"
  else
    error "To install chezmoi, you must have curl or wget."
fi

sh -c "${chezmoi_install_script}"  -- init --apply https://github.com/patentlobster/dotfiles.git --exclude=encrypted
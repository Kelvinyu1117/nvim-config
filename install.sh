#!/bin/sh
# Install or update this Neovim config on any machine (macOS, Linux, a remote server).
# Safe to re-run: running it again IS the update command.
#
#   curl -fsSL https://raw.githubusercontent.com/Kelvinyu1117/nvim-config/main/install.sh | sh
#   # or, from a clone:
#   ./install.sh
#
# Environment:
#   NVIM_CONFIG_DIR  where to clone the repo (default: ~/nvim-config)
#   XDG_CONFIG_HOME  where the `nvim` link goes (default: ~/.config)
set -eu

REPO_URL="https://github.com/Kelvinyu1117/nvim-config.git"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/nvim"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}
have() { command -v "$1" >/dev/null 2>&1; }

# 1. Requirements --------------------------------------------------------------
have git || die "git is required"
have nvim || die "Neovim is not installed. Install Neovim 0.12+ first (README: Requirements)."

version=$(nvim --version | head -n 1 | sed -n 's/^NVIM v\([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')
[ -n "$version" ] || die "could not read the Neovim version from 'nvim --version'"
major=${version% *}
minor=${version#* }
if [ "$major" -eq 0 ] && [ "$minor" -lt 12 ]; then
  die "Neovim $major.$minor found, but 0.12+ is required (README: Requirements)"
fi

for tool in rg fzf lazygit curl unzip; do
  have "$tool" || warn "'$tool' not found (README: Requirements)"
done
have fd || have fdfind || warn "'fd' not found (README: Requirements)"
have cc || have clang || have gcc || warn "no C compiler found; treesitter parsers can't be built"

# 2. Get or update the repo ----------------------------------------------------
script_dir=""
case "$0" in
*install.sh) script_dir=$(cd "$(dirname "$0")" && pwd) ;;
esac

if [ -n "$script_dir" ] && [ -f "$script_dir/nvim/init.lua" ]; then
  REPO="$script_dir"
else
  REPO="${NVIM_CONFIG_DIR:-$HOME/nvim-config}"
fi

if [ -d "$REPO/.git" ]; then
  info "Updating $REPO"
  git -C "$REPO" pull --ff-only ||
    warn "could not fast-forward $REPO (local changes?); continuing with the current checkout"
else
  [ -e "$REPO" ] && die "$REPO exists but is not a git clone; set NVIM_CONFIG_DIR to another folder"
  info "Cloning into $REPO"
  git clone "$REPO_URL" "$REPO"
fi

# 3. Link ~/.config/nvim -> <repo>/nvim -----------------------------------------
mkdir -p "$CONFIG_HOME"
if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$REPO/nvim" ]; then
  info "$TARGET already points to $REPO/nvim"
else
  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    backup="$TARGET.bak.$(date +%Y%m%d%H%M%S)"
    info "Moving the existing $TARGET to $backup"
    mv "$TARGET" "$backup"
  fi
  ln -s "$REPO/nvim" "$TARGET"
  info "Linked $TARGET -> $REPO/nvim"
fi

# 4. Plugins -------------------------------------------------------------------
# Neovim can exit successfully even after init.lua or an Ex command fails.
# Check errors before Lazy (which may not have loaded) and again before quitting.
check_errors='lua if vim.v.errmsg ~= "" then vim.api.nvim_err_writeln(vim.v.errmsg); vim.cmd("cquit 1") end'
if [ -f "$REPO/nvim/lazy-lock.json" ]; then
  info "Installing plugins at the versions pinned in lazy-lock.json"
  plugin_action=restore
else
  info "Installing plugins (no lockfile yet)"
  plugin_action=sync
fi
nvim --headless -c "$check_errors" "+Lazy! $plugin_action" -c "$check_errors" +qa ||
  die "plugin installation failed; fix the Neovim errors above and re-run this script"

cat <<EOF

Done. Next steps:
  1. Start nvim and let Mason install the language servers (watch with :Mason), then restart once.
  2. Run :checkhealth and fix anything red.
  3. On a machine with an NVIDIA GPU: run :CudaClangdSetup once.
  4. If nvim/lazy-lock.json changed, commit it so your other machines get the same versions:
       git -C "$REPO" add nvim/lazy-lock.json && git -C "$REPO" commit -m "Update plugins"
To update later, run this script again.
EOF

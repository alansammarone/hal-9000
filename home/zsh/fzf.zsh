# Trigger completion with ;<TAB> instead of **<TAB>
export FZF_COMPLETION_TRIGGER=';'

# Common junk directories to exclude (but still show .gitignored files like .env)
_fzf_exclude_dirs=(.git node_modules .venv __pycache__ .cache dist build target .pixi .mypy_cache)

# fd flags: --hidden (show dotfiles), --follow (symlinks), --no-ignore (show .gitignored files)
_fd_base="fd --hidden --follow --no-ignore"
for dir in $_fzf_exclude_dirs; do
  _fd_base="$_fd_base --exclude $dir"
done

export FZF_DEFAULT_COMMAND="$_fd_base"
export FZF_CTRL_T_COMMAND="$_fd_base"                    # ctrl+t: file picker
export FZF_ALT_C_COMMAND="$_fd_base --type d"            # alt+c: directory picker

# Display: 60% height, reverse layout, border, preview on right
export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --preview-window=right:50%:wrap'

# Preview with syntax highlighting (bat) → tree view (eza) → plain text (cat)
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :500 {} 2>/dev/null || eza --tree --level=2 --color=always {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} | head -200'"
export FZF_COMPLETION_OPTS="--preview 'bat --color=always --style=numbers --line-range :500 {} 2>/dev/null || eza --tree --level=2 --color=always {} 2>/dev/null || cat {}'"

# Custom completion functions called by fzf when using ;<TAB>
# Use same fd command with exclusions. _compgen_path is for files, _compgen_dir for directories only.
_fzf_compgen_path() {
  local exclude_args=()
  for dir in $_fzf_exclude_dirs; do
    exclude_args+=(--exclude "$dir")
  done
  fd --hidden --follow --no-ignore "${exclude_args[@]}" . "$1"
}

_fzf_compgen_dir() {
  local exclude_args=()
  for dir in $_fzf_exclude_dirs; do
    exclude_args+=(--exclude "$dir")
  done
  fd --type d --hidden --follow --no-ignore "${exclude_args[@]}" . "$1"
}

# Load fzf shell integration (keybinds, completion)
source <(fzf --zsh)

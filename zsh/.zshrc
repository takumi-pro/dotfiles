
# =============================================================================
# PATH
# =============================================================================

export PATH="/opt/homebrew/bin:$PATH" # Homebrew
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH" # MySQL
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH" # PostgreSQL
# export PATH="/opt/homebrew/opt/ruby/bin:$PATH" # Ruby (Homebrew)
export PATH="$HOME/go/bin:$PATH" # Go
export PATH="$HOME/.pyenv/shims:$PATH" # Python (pyenv)
export PATH="$HOME/.local/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH" # asdf (Node.js / pnpm 等)

# Ruby (rbenv)
if [[ -d ~/.rbenv ]]; then
  # export PATH="${HOME}/.rbenv/bin:${PATH}"
  eval "$(rbenv init -)"
fi


# =============================================================================
# Google Cloud SDK
# =============================================================================

if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi


# =============================================================================
# ツール設定
# =============================================================================

# Terraform補完
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# GPG
export GPG_TTY=$(tty)

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# powerlevel10k
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# エイリアス
# =============================================================================

# ghq管理下のリポジトリを検索
function ghf() {
  local repo=$(ghq list -p | fzf)
  [ -n "$repo" ] && cd "$repo"
}

# ghq管理下のリポジトリを検索してnvimで開く
function ghv() {
  local repo=$(ghq list -p | fzf)
  [ -n "$repo" ] && cd "$repo" && nvim "$repo"
}

alias atc="$HOME/Documents/algorithms-practice/atc"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# =============================================================================
# PATH
# =============================================================================

export PATH="$HOME/.local/bin:$PATH"


# =============================================================================
# ツール設定
# =============================================================================

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =============================================================================
# powerlevel10k
# =============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

# =============================================================================
# プラグイン
# =============================================================================
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# =============================================================================
# ホストマシン独自の設定をロード
# =============================================================================

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"


{ config, pkgs, lib, ... }:
{
  home.username = "takumi";
  # home.homeDirectory = "/Users/takumi";
  home.stateVersion = "24.11";

  home.sessionPath = [
    "${config.home.homeDirectory}/.asdf/shims"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.pyenv/shims"
    "${config.home.homeDirectory}/go/bin"
    "/opt/homebrew/opt/postgresql@15/bin"
    "/opt/homebrew/opt/mysql-client/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;

    shellAliases = {
      atc = "$HOME/Documents/algorithms-practice/atc";
    };

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        # powerlevel10k（Brew管理・移行まで暫定）
        source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

        # zsh plugins（Brew管理・移行まで暫定）
        source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        # Ruby (rbenv)
        if [[ -d "$HOME/.rbenv" ]]; then
          eval "$(rbenv init -)"
        fi

        # Google Cloud SDK
        [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
        [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

        # Terraform補完
        autoload -U +X bashcompinit && bashcompinit
        complete -o nospace -C /opt/homebrew/bin/terraform terraform

        # GPG
        export GPG_TTY=$(tty)

        # fzf（Brew管理・移行まで暫定）
        [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

        # ghq + fzf helpers
        function ghf() {
          local repo
          repo=$(ghq list -p | fzf)
          [ -n "$repo" ] && cd "$repo"
        }

        function ghv() {
          local repo
          repo=$(ghq list -p | fzf)
          [ -n "$repo" ] && cd "$repo" && nvim "$repo"
        }

        [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
      ''
    ];
  };

  home.file.".p10k.zsh".source = ./zsh/.p10k.zsh;
}

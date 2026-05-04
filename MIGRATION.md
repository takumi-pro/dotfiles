# Homebrew → Nix 移行記録

このリポジトリは macOS の dotfiles を **手動 symlink + Homebrew** から **nix-darwin + home-manager (+ Homebrew は当面残置)** へ段階的に移行している途中です。各 Phase の状態をここで管理します。

## 全体ロードマップ

| Phase | 内容 | 状態 | 完了日 |
| --- | --- | --- | --- |
| 0 | 出発点 (手動 symlink + Homebrew) | Done | 〜2026-05-03 |
| 1 | nix-darwin + home-manager 導入 / zsh を宣言化 | Done | 2026-05-04 |
| 2 | CLI ツールを Homebrew → nixpkgs へ | Planned | - |
| 3 | tmux / nvim / gh-dash を home-manager で宣言化 | Planned | - |
| 4 | macOS の system defaults を宣言化 | Planned | - |
| 5 | 言語ツールチェーン (pyenv/rbenv/asdf) の整理 | TBD | - |

---

## Phase 0: 出発点 (Done)

**State**

- `~/.zshrc` / `~/.p10k.zsh` / `~/.tmux.conf` / `~/.config/nvim` などはすべて **dotfiles リポジトリへの手動 symlink**
- パッケージは `brew install` を直接実行 (Brewfile なし)
- 主要パッケージ: `gh`, `ghq`, `nvim`, `bat`, `ripgrep`, `fzf`, `jq`, `tmux`, `powerlevel10k`, `terraform`, `lazydocker`, `lazysql`, version managers (`asdf`, `pyenv`, `rbenv`, `nodenv`)

**問題意識**

- 環境再現が手作業 (どのbrewパッケージが必要か、どこに symlink するかが暗黙)
- 設定の差分が宣言で見えない
- 新しい Mac への展開コストが高い

---

## Phase 1: nix-darwin + home-manager で zsh を宣言化 (Done — 2026-05-04)

**Goal**

- Determinate Nix を入れた上で nix-darwin + home-manager を導入し、**zsh だけを宣言的に書き直す**。CLI ツール本体や他 dotfiles は Phase 1 の対象外 (Homebrew 留置)。

**Done**

- Determinate Nix インストール (`/etc/nix/nix.conf` で flakes 既定有効)
- リポジトリルートに `flake.nix` と `home.nix` を作成
- `flake.nix` に `mkDarwinConfig = { username, hostname }: ...` を導入し、将来ホスト追加が 1 行で済む形に
- `system.primaryUser = "takumi";` / `users.users.takumi = { name; home; }` を宣言
- `nix.enable = false;` (Determinate Nix が nix を管理しているので nix-darwin 側では off)
- `homebrew = { enable = true; brews = [ "powerlevel10k" "zsh-autosuggestions" "zsh-syntax-highlighting" "fzf" "ghq" ]; }` で zsh 周りの brew パッケージを宣言化
- `programs.zsh` で zshrc 相当を宣言
  - `shellAliases.atc`
  - `home.sessionPath` で PATH (asdf / .local / pyenv / go / postgres / mysql / brew)
  - `initContent` (= `lib.mkMerge [ (lib.mkBefore p10k-instant-prompt) initBody ]`) に rbenv / gcloud SDK / terraform 補完 / GPG_TTY / fzf / `ghf` `ghv` 関数 / `~/.p10k.zsh` の source
- `home.file.".p10k.zsh".source = ./zsh/.p10k.zsh;` で 91KB のカスタム p10k 設定を nix store 経由 symlink
- 適用コマンドが `sudo darwin-rebuild switch --flake .#takumi` に統一

**つまずいたところと解決**

| 症状 | 原因 | 解決 |
| --- | --- | --- |
| `system activation must now be run as root` | nix-darwin の仕様変更で `switch` 系は root 必須に ([#1457](https://github.com/nix-darwin/nix-darwin/issues/1457)) | `sudo` を付けて実行 |
| `home.homeDirectory is not of type 'absolute path'` | nix-darwin × home-manager 統合は `users.users.<name>.home` を読みにいくが、未宣言だと null | darwin module 側で `users.users.takumi = { name = "takumi"; home = "/Users/takumi"; }` を宣言 ([HM #6557](https://github.com/nix-community/home-manager/issues/6557)) |
| `programs.zsh.initExtraFirst` / `initExtra` deprecated | home-manager 25 系で `initContent` に統合された | `initContent = lib.mkMerge [ (lib.mkBefore "...") "..." ]` に書き換え |
| `Using 'builtins.derivation' to create ... 'options.json' ... without a proper context` | 上流バグ ([HM #7935](https://github.com/nix-community/home-manager/issues/7935), [nixpkgs #485682](https://github.com/NixOS/nixpkgs/issues/485682)) | 上流の修正待ち。ユーザー設定からは対処不要 |

**Phase 1 で残した暫定対応 (Phase 2 で解消)**

- powerlevel10k / zsh-autosuggestions / zsh-syntax-highlighting / fzf を **brew で**入れて、`initContent` から `/opt/homebrew/share/...` を `source` している
- `~/.fzf.zsh` を `source` (brew の fzf installer が生成したファイル)
- `dotfiles/zsh/.zshrc` (旧手動 symlink 用) は残置 (動作安定後に削除)

---

## Phase 2: CLI ツールを Homebrew → nixpkgs へ (Planned)

**Goal**

zsh の起動に絡む CLI ツールと開発で日常的に使う CLI ツールを、`homebrew.brews` から `home.packages` へ移行する。Homebrew への依存を減らす。

**スコープ候補 (優先度順)**

1. zsh 起動経路に乗っているもの: `powerlevel10k` (`programs.zsh.plugins` 経由) / `fzf` (`programs.fzf.enable = true`) / `zsh-autosuggestions` (`programs.zsh.autosuggestion.enable = true`) / `zsh-syntax-highlighting` (`programs.zsh.syntaxHighlighting.enable = true`)
2. 開発で常用: `gh` / `ghq` / `bat` / `ripgrep` / `fd` / `jq` / `tree` / `lazydocker` / `lazysql`
3. 言語ツールチェーン本体: `terraform` / `nvim` / `tmux` (Phase 3 と相談)

**Done 判定**

- `homebrew.brews` から該当エントリが消える
- `~/.zshrc` (生成物) から `/opt/homebrew/share/...` の source 行が消える
- `which gh` が `/nix/store/...` または `~/.nix-profile/bin/...` を返す

**注意点**

- nixpkgs 版と brew 版でバージョン差が出る (LTS 寄りなのは nixpkgs)
- `terraform` は不自由ライセンス問題が出るので `nixpkgs.config.allowUnfree = true` か `nixpkgs.config.allowUnfreePredicate` の検討が必要
- p10k は nixpkgs に入っているので `programs.zsh.plugins = [{ name = "powerlevel10k"; src = pkgs.zsh-powerlevel10k; file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme"; }]` の形に

---

## Phase 3: tmux / nvim / gh-dash を home-manager で宣言化 (Planned)

**Goal**

残っている dotfiles (`tmux/.tmux.conf`, `nvim/`, `gh-dash/config.yml`) を home-manager で宣言管理し、手動 symlink 運用を廃止する。

**方針**

- tmux: `programs.tmux.enable = true` + `programs.tmux.plugins` (TPM 互換)。`.tmux.conf` 本体は `programs.tmux.extraConfig` か `home.file` で配置
- nvim: `programs.neovim.enable = true` + lua 設定をそのまま `xdg.configFile."nvim/" = { source = ./nvim; recursive = true; }` で配置
- gh-dash: `xdg.configFile."gh-dash/config.yml".source = ./gh-dash/config.yml;`

**確認事項**

- tmux の TPM (plugin manager) と home-manager の plugin 機構の干渉
- `tmux/sessionizer.sh` のような実行ファイルの扱い (`home.file.".local/bin/sessionizer".source = ...; mode = "0755"`)
- nvim 起動が壊れないこと (Lazy.nvim / mason 等の整合性)

---

## Phase 4: macOS system defaults を宣言化 (Planned)

**Goal**

Dock、Finder、Keyboard 等の macOS 設定を `system.defaults.*` で宣言する。新マシンセットアップで GUI ポチポチが不要になる。

**候補**

- `system.defaults.dock.autohide`
- `system.defaults.finder.AppleShowAllExtensions`
- `system.defaults.NSGlobalDomain.KeyRepeat` / `InitialKeyRepeat`
- `system.keyboard.enableKeyMapping`
- Karabiner-Elements 設定 (cask は `homebrew.casks` 管理に)

---

## Phase 5: 言語ツールチェーンの整理 (TBD)

**Goal**

`pyenv` / `rbenv` / `asdf` の併用状態を見直す。プロジェクト単位の nix `devShell` に寄せるか、現状維持か判断する。

**論点**

- チームメンバーが nix を使っていない場合、devShell ベースのワークフローが個人で完結するか
- 既存プロジェクト (`.tool-versions` 等) との互換性
- mise / aqua への乗り換えも候補

---

## 参考

- [nix-darwin manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [home-manager manual](https://nix-community.github.io/home-manager/)
- [Determinate Nix](https://docs.determinate.systems/)

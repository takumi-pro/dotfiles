# takumi's dotfiles

macOS 用の dotfiles。**nix-darwin + home-manager** で管理し、Homebrew は当面残置 (移行段階は [MIGRATION.md](./MIGRATION.md) 参照)。

## 構成

| パス | 役割 |
| --- | --- |
| `flake.nix` | nix-darwin の入口。`mkDarwinConfig { username, hostname }` で `darwinConfigurations.takumi` を生成 |
| `home.nix` | home-manager 設定 (zsh / PATH / aliases / p10k 等) |
| `zsh/.p10k.zsh` | powerlevel10k カスタム設定 (`home.file` で `~/.p10k.zsh` に symlink) |
| `zsh/.zshrc` | 旧手動 symlink 用 (Phase 1 移行で deprecated。後で削除予定) |
| `tmux/` | tmux 設定 (Phase 3 で home-manager 化予定) |
| `nvim/` | Neovim 設定 (Phase 3 で home-manager 化予定) |
| `gh-dash/` | gh-dash 設定 (Phase 3 で home-manager 化予定) |

## 初期セットアップ (新しい Mac)

### 1. Nix をインストール

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.nixos.org | sh -s -- install
```

完了したら一度ターミナルを開き直し、`nix --version` で確認。

### 2. Homebrew をインストール

`flake.nix` の `homebrew.enable = true` が brew 本体を前提にするので、`darwin-rebuild` の前にインストールしておく。

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

途中で Xcode Command Line Tools のインストールも求められる (これで `git` も入る)。完了後、`brew --version` を確認。

### 3. このリポジトリを clone

`~/codes/github.com/<owner>/<repo>` レイアウト (ghq 互換) に置く。`ghq` を入れてから `ghq get` でも、`git clone` 直叩きでも良い。

```sh
# A) ghq を使う場合 (推奨)
brew install ghq
ghq get github.com/takumi-pro/dotfiles

# B) git clone を直接叩く場合
mkdir -p ~/codes/github.com/takumi-pro
git clone https://github.com/takumi-pro/dotfiles ~/codes/github.com/takumi-pro/dotfiles
```

### 4. 初回ブートストラップ

`darwin-rebuild` がまだ PATH にないので `nix run` で起動する。`sudo` 必須 (nix-darwin は `switch` を root 権限でしか受け付けない)。

```sh
cd ~/codes/github.com/takumi-pro/dotfiles
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#takumi
```

完了するとターミナル新規起動で `darwin-rebuild` が使えるようになる。

## 日常運用

```sh
cd ~/codes/github.com/takumi-pro/dotfiles

# 設定変更を反映
sudo darwin-rebuild switch --flake .#takumi

# 評価だけ (副作用なし)
sudo darwin-rebuild check --flake .#takumi

# inputs を最新化 (nixpkgs / home-manager / nix-darwin の更新)
nix flake update
sudo darwin-rebuild switch --flake .#takumi

# 直前世代へロールバック
sudo darwin-rebuild --rollback
```

## 移行履歴

Homebrew → Nix への段階的移行の進捗と決定事項は [MIGRATION.md](./MIGRATION.md) で管理。

{
  description = "takumi's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };

      mkDarwinConfig = { username, hostname }: nix-darwin.lib.darwinSystem {
        inherit system pkgs;
        specialArgs = { inherit username hostname; };
        modules = [
          {
            system.stateVersion = 5;
            system.primaryUser = username;
            nix.enable = false;

            users.users.${username} = {
              name = username;
              home = "/Users/${username}";
            };

            # Homebrew
            homebrew = {
              enable = true;
              brews = [
                "powerlevel10k"
                "zsh-autosuggestions"
                "zsh-syntax-highlighting"
                "fzf"
                "ghq"
                "gh"
                "neovim"
                "tmux"
                "lazydocker"
                "ripgrep"
              ];
              casks = [
                "font-hack-nerd-font"
              ];
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };
    in {
      darwinConfigurations.takumi = mkDarwinConfig {
        username = "takumi";
        hostname = "takumi";
      };

      darwinConfigurations.takumi-igarashi = mkDarwinConfig {
        username = "takumi-igarashi";
        hostname = "takumi-igarashi";
      };
    };
}

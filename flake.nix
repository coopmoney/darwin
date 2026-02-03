{
  description = "Cooper's Darwin system configuration";

  inputs = {
    # Core
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2311.559232.tar.gz";

    # Flake framework
    flake-parts.url = "https://flakehub.com/f/hercules-ci/flake-parts/0.1.419.tar.gz";

    # nix-darwin
    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.2511.5835.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Determinate Systems
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    agenix.url = "github:ryantm/agenix";

    # Tools
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    devenv.url = "github:cachix/devenv/latest";
    direnv-instant.url = "github:Mic92/direnv-instant";


    # Theming
    catppuccin.url = "https://flakehub.com/f/catppuccin/nix/1.2.1.tar.gz";

    # Neovim
    nixvim.url = "github:nix-community/nixvim";

    # Claude Code
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems to build for
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Import flake modules
      imports = [
        ./flake-modules
      ];
    };
}

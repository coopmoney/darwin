{
  description = "Cooper's Darwin system configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Flake framework
    flake-parts.url = "github:hercules-ci/flake-parts";

    # nix-darwin
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Determinate Systems
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tools
    flox.url = "github:flox/flox/latest";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/0.1.26.tar.gz";

    # Theming
    catppuccin.url = "github:catppuccin/nix";

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

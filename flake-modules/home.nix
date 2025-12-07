# Standalone home-manager configurations (for non-darwin systems)
{ inputs, self, ... }:

let
  users = import ../users;
in
{
  flake = {
    homeConfigurations = {
      "coopermaruyama@macbook-pro" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs self;
          hostname = "macbook-pro";
          user = users.coopermaruyama;
        };
        modules = [
          ../hosts/macbook-pro/home.nix
          inputs.catppuccin.homeModules.catppuccin
        ];
      };

      "coopermaruyama@coopers-mac-studio" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs self;
          hostname = "coopers-mac-studio";
          user = users.coopermaruyama;
        };
        modules = [
          ../hosts/coopers-mac-studio/home.nix
          inputs.catppuccin.homeModules.catppuccin
        ];
      };
    };
  };
}


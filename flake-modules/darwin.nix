# Darwin system configurations
{ inputs, self, ... }:

let
  # Load user profiles
  users = import ../users;
in
{
  flake = {
    # Darwin system configurations
    darwinConfigurations = {
      "Coopers-MacBook-Pro" = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs self;
          hostname = "coopers-macbook-pro";
          user = users.coopermaruyama;
        };
        modules = [
          # Core darwin modules
          ../modules/darwin

          # Host-specific configuration
          ../hosts/macbook-pro

          # Determinate Nix
          inputs.determinate.darwinModules.default

          # Home Manager integration
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs self;
                hostname = "coopers-macbook-pro";
                user = users.coopermaruyama;
              };
              users.${users.coopermaruyama.username} = {
                imports = [
                  ../hosts/macbook-pro/home.nix
                  inputs.catppuccin.homeModules.catppuccin
                ];
              };
            };
          }
        ];
      };
      

      "Coopers-Mac-Studio" = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs self;
          hostname = "coopers-mac-studio";
          user = users.coopermaruyama;
        };
        modules = [
          ../modules/darwin
          ../hosts/coopers-mac-studio
          inputs.determinate.darwinModules.default
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs self;
                hostname = "coopers-mac-studio";
                user = users.coopermaruyama;
              };
              users.${users.coopermaruyama.username} = {
                imports = [
                  ../hosts/coopers-mac-studio/home.nix
                  inputs.catppuccin.homeModules.catppuccin
                ];
              };
            };
          }
        ];
      };
    };
  };
}


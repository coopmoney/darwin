# Helper functions for creating darwin and home-manager configurations
{ inputs, self }:

let
  users = import ../users;
  hosts = import ../hosts;

  # Create a darwin system configuration for a host
  mkDarwinHost =
    hostId:
    let
      hostConfig = hosts.${hostId};
      user = users.${hostConfig.user};
    in
    inputs.darwin.lib.darwinSystem {
      system = hostConfig.system;
      specialArgs = {
        inherit inputs self hostId;
        hostname = hostId;
        user = user;
        hostConfig = hostConfig;
      };
      modules = [
        # Core darwin modules
        ../modules/darwin

        # Host-specific configuration (if it exists)
        ../hosts/${hostId}

        # Determinate Nix
        inputs.determinate.darwinModules.default

        # Agenix secrets management
        inputs.agenix.darwinModules.default

        # Home Manager integration
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit inputs self hostId;
              hostname = hostId;
              user = user;
              hostConfig = hostConfig;
            };
            users.${user.username} = {
              imports = [
                ../hosts/${hostId}/home.nix
                inputs.catppuccin.homeManagerModules.catppuccin
              ];
            };
          };
        }
      ];
    };

  # Create a standalone home-manager configuration for a host
  mkHomeConfig =
    hostId:
    let
      hostConfig = hosts.${hostId};
      user = users.${hostConfig.user};
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${hostConfig.system};
      extraSpecialArgs = {
        inherit inputs self hostId;
        hostname = hostId;
        user = user;
        hostConfig = hostConfig;
      };
      modules = [
        ../hosts/${hostId}/home.nix
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
    };

  # Generate all darwin configurations from hosts
  mkAllDarwinHosts = builtins.mapAttrs (hostId: _: mkDarwinHost hostId) hosts;

  # Generate all home configurations from hosts
  # Creates entries like "username@hostname"
  mkAllHomeConfigs = builtins.listToAttrs (
    builtins.map (
      hostId:
      let
        hostConfig = hosts.${hostId};
        user = users.${hostConfig.user};
      in
      {
        name = "${user.username}@${hostId}";
        value = mkHomeConfig hostId;
      }
    ) (builtins.attrNames hosts)
  );

  # Generate darwin configurations with custom hostnames as keys
  # This maps hostname -> configuration
  mkDarwinConfigsByHostname = builtins.listToAttrs (
    builtins.map (
      hostId:
      let
        hostConfig = hosts.${hostId};
      in
      {
        name = hostConfig.hostname;
        value = mkDarwinHost hostId;
      }
    ) (builtins.attrNames hosts)
  );

in
{
  inherit
    mkDarwinHost
    mkHomeConfig
    mkAllDarwinHosts
    mkAllHomeConfigs
    mkDarwinConfigsByHostname
    ;
}

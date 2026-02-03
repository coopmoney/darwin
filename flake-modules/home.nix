# Standalone home-manager configurations (for non-darwin systems)
{ inputs, self, ... }:

let
  mkHost = import ../lib/mkHost.nix { inherit inputs self; };
  users = import ../users;
in
{
  flake = {
    # Home configurations - automatically generated from hosts/default.nix
    # The key is "username@hostname" (e.g., "coopermaruyama@macbook-pro")
    homeConfigurations = mkHost.mkAllHomeConfigs;
  };
}

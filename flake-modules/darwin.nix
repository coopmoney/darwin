# Darwin system configurations
{ inputs, self, ... }:

let
  mkHost = import ../lib/mkHost.nix { inherit inputs self; };
in
{
  flake = {
    # Darwin system configurations - automatically generated from hosts/default.nix
    # The key is the darwinHostname (e.g., "Coopers-Mac-Studio")
    darwinConfigurations = mkHost.mkDarwinConfigsByHostname;
  };
}

# Compatibility shim for nix-shell
# This allows the VS Code nix-env-selector to work with this flake-based project
let
  # Get the flake
  flake = builtins.getFlake (toString ./.);
  
  # Get the system
  system = builtins.currentSystem;
  
  # Get the devShell for the current system
  devShell = flake.devShells.${system}.default;
in
  devShell

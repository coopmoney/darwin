{ pkgs, ... }:

{
  # Font configuration
  # Note: Most fonts are handled via Homebrew casks in packages.nix
  # This file can be extended with additional font packages from nixpkgs
  
  fonts = {
    # Install fonts from nixpkgs
    packages = with pkgs; [
      source-code-pro
      # Add more fonts here as needed:
      # fira-code
      # jetbrains-mono
      # nerdfonts
    ];
  };
}
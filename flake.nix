{
  description = "Cooper's Darwin system configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

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

    # Flox
    flox = {
      url = "github:flox/flox/latest";
    };

    # FH
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/0.1.26.tar.gz";

    # Catppuccin theme
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , darwin
    , home-manager
    , catppuccin
    , ...
    }@inputs:
    let
      inherit (self) outputs;

      # Systems supported
      systems = [ "aarch64-darwin" "x86_64-darwin" ];

      # User configurations
      users = {
        coopermaruyama = {
          name = "coopermaruyama";
          fullName = "Cooper Maruyama";
          email = "cooper@darkmatter.io";
          gitKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+M/DHDlKgayM6wsiX6r704pE+2qENOsKcytC7sBhKA";
        };
      };

      # Helper function to create nixpkgs for each system
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Helper functions for creating configurations
      mkDarwinConfiguration = hostname: user:
        darwin.lib.darwinSystem rec {
          system = "aarch64-darwin"; # Change if needed for specific machines
          specialArgs = {
            inherit inputs outputs hostname;
            inherit (users.${user}) name fullName email gitKey;
            flake = self;
            darwinModules = ./modules/darwin;
            hmModules = ./modules/home-manager;
          };
          modules = [
            # System configuration
            ./hosts/${hostname}

            # Determinate
            inputs.determinate.darwinModules.default

            # Home Manager integration
            home-manager.darwinModules.home-manager
            {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              extraSpecialArgs = {
                inherit inputs outputs hostname;
                inherit (users.${user}) name fullName email gitKey;
                hmModules = ./modules/home-manager;
              };
              users.${users.${user}.name} = {
                imports = [
                  ./home/${user}/${hostname}
                  catppuccin.homeModules.catppuccin
                ];
              };
            };
            }
          ];
        };

      mkHomeConfiguration = system: user: hostname:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs outputs hostname;
            inherit (users.${user}) name fullName email gitKey;
            hmModules = ./modules/home-manager;
          };
          modules = [
            ./home/${user}/${hostname}
            catppuccin.homeModules.catppuccin
          ];
        };
    in
    {
      # Darwin configurations
      darwinConfigurations = {
        "Coopers-MacBook-Pro" = mkDarwinConfiguration "macbook-pro" "coopermaruyama";
      "Coopers-Mac-Studio" = mkDarwinConfiguration "coopers-mac-studio" "coopermaruyama";
      };

      # Standalone home-manager configurations
      homeConfigurations = {
        "coopermaruyama@macbook-pro" = mkHomeConfiguration "aarch64-darwin" "coopermaruyama" "macbook-pro";
        "coopermaruyama@coopers-mac-studio" = mkHomeConfiguration "aarch64-darwin" "coopermaruyama" "coopers-mac-studio";
      };

      # Packages
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          reload-nix-darwin-configuration = pkgs.writeShellApplication {
            name = "reload-nix-darwin-configuration";
            runtimeInputs = [ darwin.packages.${system}.darwin-rebuild ];
            text = ''
              SYSTEM_NAME=$(scutil --get ComputerName)
              echo "🔄 Rebuilding Darwin configuration for $SYSTEM_NAME..."
              darwin-rebuild switch --flake ".#$SYSTEM_NAME"
              echo "✅ Darwin configuration applied!"
            '';
          };

          # Make this the default package for 'nix run'
          default = self.packages.${system}.reload-nix-darwin-configuration;
        }
      );

      # Apps
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.reload-nix-darwin-configuration}/bin/reload-nix-darwin-configuration";
        };
      });

      # Development shell
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              nil
              git
              self.packages.${system}.reload-nix-darwin-configuration
            ];
          };
        }
      );

      # Formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}

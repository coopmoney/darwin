# Nix quick reference (macOS, multi-user, Determinate Nix)

Initialization
- Add to your shell or run per-session:
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

Where things live
- /etc/nix/nix.conf — managed by installer (don’t edit)
- /etc/nix/nix.custom.conf — your overrides (flakes enabled here)
- ~/.nix-profile — per-user profile symlink
- /nix/var/nix/profiles/default — system profile
- /nix/store — immutable content-addressed store
- Logs: /var/log/determinate-nix-daemon.log
- Daemon: systems.determinate.nix-daemon (launchctl label)

Common commands
- Search: nix search nixpkgs ripgrep
- Install (user profile): nix profile install nixpkgs#jq
- List installed: nix profile list
- Upgrade all: nix profile upgrade '.*'
- Remove (by index): nix profile remove 0
- Run once (ephemeral): nix run nixpkgs#hello
- Build a package: nix build nixpkgs#hello
- Flakes (in a repo):
  - nix flake init
  - nix flake update
  - nix develop
- Show config: nix config show
- Diagnostics: nix config check
- Daemon status: launchctl print system/systems.determinate.nix-daemon | grep -E 'state =|pid ='
- Tail logs: sudo tail -f /var/log/determinate-nix-daemon.log

Maintenance
- Garbage collect: sudo nix store gc --delete-older-than 30d
- Optimise store (hardlink dedup): sudo nix store optimise -v

Notes
- Flakes are enabled globally via /etc/nix/nix.custom.conf:
  experimental-features = nix-command flakes
- With newer Nix, nix run nixpkgs#pkg works without -c. 

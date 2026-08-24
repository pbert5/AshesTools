# Consumption guide

See outputs with `nix flake show github:pbert5/AshesTools`. `packages` are
installable buildEnv bundles, `devShells` are generated environments, `apps`
are discovery commands, `lib` exposes raw set functions, and the module outputs
are optional NixOS/Home Manager wrappers.

Persistent installation:

```sh
nix profile install github:pbert5/AshesTools#shell-core
nix profile list
nix profile history
nix profile upgrade
nix profile remove nix-dev
nix profile rollback
```

Temporary use does not modify the profile:

```sh
nix shell github:pbert5/AshesTools#network
nix shell github:pbert5/AshesTools#shell-core github:pbert5/AshesTools#nix-dev
```

Development use is a shell with the bundle on `PATH`:

```sh
nix develop github:pbert5/AshesTools#nix-dev
nix build github:pbert5/AshesTools#nix-dev
```

Downstream NixOS, Home Manager, and flakes should pass their own `pkgs`:

```nix
environment.systemPackages = inputs.ashes-tools.lib.sets.nix-dev pkgs;
home.packages = inputs.ashes-tools.lib.sets.workstation-cli pkgs;
devShells.default = pkgs.mkShell { packages = inputs.ashes-tools.lib.sets.nix-dev pkgs; };
```

The same definitions also power the modules. Add
`inputs.ashes-tools.nixosModules.default` or
`inputs.ashes-tools.homeModules.default`, then set
`ashesTools.sets = [ "shell-core" "network" ];`.

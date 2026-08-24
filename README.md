# Ashes Tools

Ashes Tools is a reusable catalog of personal Nix package sets. Each set is
defined once under `lib/sets.nix` and exposed as raw packages, an installable
bundle, and a development shell.

```sh
nix flake show github:pbert5/AshesTools
nix run github:pbert5/AshesTools#list-sets
nix profile install github:pbert5/AshesTools#nix-dev
nix shell github:pbert5/AshesTools#network
nix develop github:pbert5/AshesTools#nix-dev
```

For declarative consumers, use your own `pkgs` instance:

```nix
environment.systemPackages = inputs.ashes-tools.lib.sets.nix-dev pkgs;
home.packages = inputs.ashes-tools.lib.sets.shell-core pkgs;
devShells.default = pkgs.mkShell { packages = inputs.ashes-tools.lib.sets.nix-dev pkgs; };
```

The optional `nixosModules.default` and `homeModules.default` modules are thin
wrappers around that same resolver. Enable a module and set
`ashesTools = { enable = true; sets = [ "shell-core" "nix-dev" ]; };`.

`nix shell` is temporary, `nix profile install` is persistent and imperative,
and NixOS/Home Manager are persistent and declarative. `nix develop` creates a
project environment rather than changing a user profile. Use `nix profile list`,
`nix profile history`, `nix profile rollback`, `nix profile upgrade`, and
`nix profile remove <element>` to manage profile bundles.

## Local nested development

Ashes Tools normally consumes the remote `github:pbert5/AwesomeNixSets` input.
The nested checkout is a Git submodule for editing, not dependency resolution:

```sh
git submodule update --init --recursive
nix flake check --override-input awesome-nix-sets path:./packages/AwesomeNixSets
```

Nix Arbor similarly overrides its remote `ashes-tools` input with
`path:./packages/AshesTools`. These temporary overrides do not change lock files.
Transitive overrides are most reliable at the repository boundary being edited;
check Ashes Tools directly for nested Awesome Nix work, then check Arbor with
its Ashes Tools override.

See `docs/consumption.md` for profile generations, NixOS/Home Manager examples,
and the remote/local distinction.

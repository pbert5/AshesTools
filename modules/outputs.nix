{ inputs, ... }:
{
  flake = {
    lib = import ../lib/sets.nix { awesomeNixSets = inputs.awesome-nix-sets; };
    nixosModules.default = import ./nixos.nix;
    homeModules.default = import ./home-manager.nix;
  };
  perSystem = { pkgs, ... }:
    let
      setsLib = import ../lib/sets.nix { awesomeNixSets = inputs.awesome-nix-sets; };
      meta = setsLib.metadata pkgs;
      bundle = name: info: pkgs.buildEnv {
        inherit name;
        paths = setsLib.sets.${name} pkgs;
        pathsToLink = [ "/bin" "/share" ];
        ignoreCollisions = false;
        meta.description = info.description;
      };
      bundles = builtins.mapAttrs bundle meta;
      inventory = pkgs.writeText "ashes-tools-sets.txt" (builtins.concatStringsSep "\n" (builtins.concatLists (builtins.attrValues (builtins.mapAttrs (name: info: [
        "${name}\t${info.category}\t${info.description}"
        (builtins.concatStringsSep " " info.availablePackageNames)
      ]) meta))));
      listSets = pkgs.writeShellApplication {
        name = "ashes-tools-list-sets";
        runtimeInputs = [ pkgs.gawk ];
        text = ''
          awk -F '\t' '{ print $1 "\n  " $3 "\n  packages: " $4 }' ${inventory}
        '';
      };
      describeSet = pkgs.writeShellApplication {
        name = "ashes-tools-describe-set";
        runtimeInputs = [ pkgs.gawk pkgs.gnugrep ];
        text = ''
          set_name="''${1:-}"
          if [[ -z "$set_name" ]]; then echo "usage: describe-set SET" >&2; exit 2; fi
          grep -F -m1 "$set_name" ${inventory} | awk -F '\t' '{ print $1 "\n  " $3 "\n  packages: " $4 }'
        '';
      };
    in {
      packages = bundles // { list-sets = listSets; describe-set = describeSet; };
      devShells = builtins.mapAttrs (_: package: pkgs.mkShell { packages = [ package ]; }) bundles;
      apps = {
        list-sets = { type = "app"; program = "${listSets}/bin/ashes-tools-list-sets"; meta.description = "List Ashes Tools package sets"; };
        describe-set = { type = "app"; program = "${describeSet}/bin/ashes-tools-describe-set"; meta.description = "Describe an Ashes Tools package set"; };
      };
      checks = {
        set-metadata = pkgs.runCommand "ashes-tools-set-metadata" { } ''
          test ${toString (builtins.length (builtins.attrNames meta))} -gt 0
          touch $out
        '';
        bundles-evaluate = pkgs.runCommand "ashes-tools-bundles-evaluate" { } ''
          test ${toString (builtins.length (builtins.attrNames bundles))} -gt 0
          touch $out
        '';
      };
    };
}

{ config, lib, pkgs, ... }:
let
  ashes = import ../lib/sets.nix;
  cfg = config.ashesTools;
in {
  options.ashesTools = {
    enable = lib.mkEnableOption "Ashes Tools package sets";
    sets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "shell-core" ];
      description = "Ashes Tools set names to add to systemPackages.";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.concatMap (name: ashes.sets.${name} pkgs) cfg.sets;
  };
}

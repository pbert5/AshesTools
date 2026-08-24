{ awesomeNixSets ? null }:
let
  select = pkgs: names: builtins.concatLists (map (name: if builtins.hasAttr name pkgs then [ (builtins.getAttr name pkgs) ] else [ ]) names);
  definitions = {
    shell-core = { description = "Small, broadly useful shell and terminal tools"; category = "shell"; members = [ "git" "jq" "yq" "ripgrep" "fd" "fzf" "just" "direnv" "nix-direnv" "navi" "yazi" ]; };
    nix-dev = { description = "Nix development, inspection, formatting, and linting tools"; category = "nix"; members = [ "nix" "nh" "nix-output-monitor" "nix-tree" "nix-diff" "nix-index" "nil" "statix" "deadnix" "nixfmt" ]; };
    vcs = { description = "Version-control and Git hosting tools"; category = "development"; members = [ "git" "gh" "git-lfs" ]; };
    search = { description = "Fast file, text, and package search tools"; category = "shell"; members = [ "ripgrep" "fd" "fzf" "nix-index" "nix-search-cli" ]; };
    data = { description = "Small command-line data processing tools"; category = "shell"; members = [ "jq" "yq" "dasel" "jc" ]; };
    network = { description = "Network inspection, transfer, and troubleshooting tools"; category = "administration"; members = [ "curl" "wget" "httpie" "dogdns" "nmap" "socat" "mtr" ]; };
    system = { description = "Workstation and system administration utilities"; category = "administration"; members = [ "htop" "btop" "procps" "lsof" "pciutils" "usbutils" "file" "tree" "which" ]; };
    remote-admin = { description = "Remote administration and transfer utilities"; category = "administration"; members = [ "openssh" "rsync" "tmux" "mosh" ]; };
    containers = { description = "Container and image tooling"; category = "development"; members = [ "docker" "podman" "skopeo" "dive" ]; };
    filesystem = { description = "Filesystem navigation and inspection tools"; category = "system"; members = [ "ncdu" "dua" "dust" "tree" "file" "moreutils" ]; };
    development = { description = "General development toolchain utilities"; category = "development"; members = [ "gcc" "gnumake" "pkg-config" "cmake" "gdb" "python3" "shellcheck" ]; };
    workstation-cli = { description = "Curated workstation command-line toolkit"; category = "bundle"; compose = [ "shell-core" "vcs" "search" "data" "network" "system" "filesystem" ]; };
    nix-workstation = { description = "Workstation CLI tools plus the Nix power-user toolkit"; category = "bundle"; compose = [ "workstation-cli" "nix-dev" ]; };
    nix-power-user = { description = "Nix tools plus selected installable Awesome Nix utilities"; category = "bundle"; compose = [ "nix-workstation" ]; awesome = [ "commandLine" "development" ]; };
  };
  resolveNames = name: seen: if builtins.elem name seen then throw "Ashes Tools set composition cycle at ${name}" else let definition = builtins.getAttr name definitions; in (definition.members or [ ]) ++ builtins.concatLists (map (child: resolveNames child (seen ++ [ name ])) (definition.compose or [ ]));
  allNames = name: definition: (resolveNames name [ ]) ++ builtins.concatLists (map (child: allNames child (builtins.getAttr child definitions)) (definition.awesome or [ ]));
  awesomeMembers = name: pkgs: if awesomeNixSets == null then [ ] else (builtins.getAttr name awesomeNixSets.lib.sets) pkgs;
  packages = pkgs: name: let definition = builtins.getAttr name definitions; in pkgs.lib.unique ((select pkgs (resolveNames name [ ])) ++ builtins.concatLists (map (name: awesomeMembers name pkgs) (definition.awesome or [ ])));
  metadata = pkgs: builtins.mapAttrs (name: definition: definition // { inherit name; packageNames = pkgs.lib.unique (allNames name definition); availablePackageNames = builtins.filter (member: builtins.hasAttr member pkgs) (pkgs.lib.unique (allNames name definition)); }) definitions;
in { inherit definitions packages metadata; sets = builtins.mapAttrs (name: _: pkgs: packages pkgs name) definitions; }

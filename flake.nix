{
  description = "hardenedlinux debian home-manager profile";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs";
    master.url = "nixpkgs/703f052de185c3dd1218165e62b105a68e05e15f";
    nixpkgs-hardenedlinux.url = "github:hardenedlinux/nixpkgs-hardenedlinux";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    #zeek  packages
    detect-ransomware-filenames = { url = "github:corelight/detect-ransomware-filenames"; flake = false; };
    spl-spt = { url = "github:GTrunSec/spl-spt"; flake = false; };
    zeek-EternalSafety = { url = "github:lexibrent/zeek-EternalSafety"; flake = false; };
    IRC-Zeek-package = { url = "github:stratosphereips/IRC-Zeek-package"; flake = false; };

  };

  #outputs = inputs@{ self, nixpkgs, hardenedlinux-pkgs, master, flake-utils, emacs-overlay }:
  outputs = inputs: with builtins;let
      python-packages-overlay = (import "${inputs.nixpkgs-hardenedlinux}/nix/python-packages-overlay.nix");
      packages-overlay = (import "${inputs.nixpkgs-hardenedlinux}/nix/packages-overlay.nix");
      in
    (inputs.flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                python-packages-overlay
                packages-overlay
          ];
        };
          in
          {
            devShell = import ./shell.nix { inherit pkgs; pkgsChannel = inputs.nixpkgs;};
          }
        )
    );
  }

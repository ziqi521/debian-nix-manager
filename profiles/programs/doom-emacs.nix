{ config, lib, pkgs, ... }:


let
  updatefont = ''fc-cache -f -v'';
  updateInit = "bash .doom.d/bin/emacs.sh";
  emacs-overlay-rev = (builtins.fromJSON (builtins.readFile ../../flake.lock)).nodes.emacs-overlay.locked.rev;
    overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${emacs-overlay-rev}.tar.gz";
    }))
  ];

  emacsPkgs  = import ../../nix/master-pkgs.nix {inherit overlays;};
  
in
{

  home.activation.linkEmacsPrivate = config.lib.dag.entryAfter [ "writeBoundary" ] ''

     if [ ! -d "$HOME/.emacs.d" ];then
         ${pkgs.git}/bin/git clone https://github.com/GTrunSec/doom-emacs.git --depth=1 -b my-doom ~/.emacs.d
      if [ ! -d "$HOME/.emacs.d/bin/doom" ];then
       mv $HOME/.emacs.d $HOME/.emacs.d-backup
       ${pkgs.git}/bin/git clone https://github.com/GTrunSec/doom-emacs.git --depth=1  -b my-doom ~/.emacs.d
       fi
     fi

     if [ ! -d "$HOME/.doom.d" ];then
     mkdir -p $HOME/.doom.d/
     mkdir -p $HOME/.doom.d/etc
     fi

     if [ ! -d "$HOME/.doom.d/modules" ];then
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/lisp" $HOME/.doom.d/lisp
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/bin" $HOME/.doom.d/bin
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/snippets" $HOME/.doom.d/snippets
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/modules" $HOME/.doom.d/modules
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/Makefile" $HOME/.doom.d/Makefile
     fi

     if [ ! -d "$HOME/.doom.d/modules/my-code" ];then
          mkdir -p $HOME/.doom.d/modules/private/my-org
          mkdir -p $HOME/.doom.d/modules/private/my-code
          mkdir -p $HOME/.doom.d/autoload
     fi
   '';

  #fonts
  home.file.".local/share/fonts/my-font" = {
    source = ../../dotfiles/my-font;
    onChange = updatefont;
  };


  # editors
  home.file.".doom.d/init.org" = {
    source = ../../dotfiles/doom/init.org;
    onChange = updateInit;
  };
  home.file.".doom.d/xah-fly-keys.org" = {
    source = ../../dotfiles/doom/xah-fly-keys.org;
    onChange = updateInit;
  };

  programs.emacs.enable = true;
  
  programs.emacs.package = (emacsPkgs.emacsGcc.override({
    imagemagick = emacsPkgs.imagemagick;
  })).overrideAttrs(old: rec {
    configureFlags = (old.configureFlags or []) ++ ["--with-imagemagick"
                                                    "--with-nativecomp"
                                                   ];
  });
  programs.emacs.extraPackages = epkgs: with epkgs;[
    vterm
  ];
  services.emacs.enable = true;
}

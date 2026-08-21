{
  description = "My nvim configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        runtimeDeps = with pkgs; [
          git
          ripgrep
          fd
          gcc
          gnumake
          lua-language-server
          nixd
          pyright
          nodejs_22
          stylua
        ];

        wrappedNvim = pkgs.symlinkJoin {
          name = "nvim";
          paths = [pkgs.neovim-unwrapped];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
          '';
        };
      in {
        packages.default = wrappedNvim;
        apps.default = {
          type = "app";
          program = "${wrappedNvim}/bin/nvim";
        };
      }
    );
}

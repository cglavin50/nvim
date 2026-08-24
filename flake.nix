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
  }: let
    nixosModule = {pkgs, ...}: {
      environment.systemPackages = [self.packages.${pkgs.system}.default];
    };

    overlay = final: _prev: {
      neovim-cglavin = self.packages.${final.system}.default;
    };
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        configDir = pkgs.stdenv.mkDerivation {
          name = "nvim-config";
          src = ./.;
          installPhase = ''
            mkdir -p $out/nvim
            cp init.lua $out/nvim/
            cp -r lua $out/nvim/
          '';
        };

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

        # vim.pack.add writes nvim-pack-lock.json into XDG_CONFIG_HOME/nvim,
        # so we need a writable copy of the config. On first run (or after a
        # flake update changes the store path), sync from the nix store into
        # ~/.local/share/nvim-cglavin/nvim/ which is user-writable.
        wrappedNvim = pkgs.writeShellScriptBin "nvim" ''
          cfg_parent="''${XDG_DATA_HOME:-$HOME/.local/share}/nvim-cglavin"
          cfg_dir="$cfg_parent/nvim"

          if [[ ! -f "$cfg_dir/.nix-revision" ]] || \
             [[ "$(cat "$cfg_dir/.nix-revision")" != "${configDir}" ]]; then
            mkdir -p "$cfg_dir"
            cp -rT "${configDir}/nvim" "$cfg_dir"
            chmod -R u+w "$cfg_dir"
            printf '%s' '${configDir}' > "$cfg_dir/.nix-revision"
          fi

          export PATH="${pkgs.lib.makeBinPath runtimeDeps}:$PATH"
          export XDG_CONFIG_HOME="$cfg_parent"
          exec ${pkgs.neovim-unwrapped}/bin/nvim "$@"
        '';
      in {
        packages.default = wrappedNvim;
        apps.default = {
          type = "app";
          program = "${wrappedNvim}/bin/nvim";
        };
      }
    )
    // {
      nixosModules.default = nixosModule;
      overlays.default = overlay;
    };
}

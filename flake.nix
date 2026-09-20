{
  description = "My nvim configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSystem = nixpkgs.lib.genAttrs supportedSystems;

    # CLI tools needed outside/independent of nvim's own LSP runtime:
    # shell utilities, native compilers for treesitter parser builds, and
    # stylua as a standalone formatter CLI. LSP servers/formatters that
    # Mason already tracks via ensure_installed (see lua/config/lsp.lua)
    # belong there, not here — avoids two managers installing the same
    # binary under different paths.
    runtimeDeps = pkgs:
      with pkgs; [
        git
        ripgrep
        fd
        gcc
        gnumake
        nodejs_22
        stylua
      ];

    homeModule = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.nvim-cglavin;
    in {
      options.programs.nvim-cglavin = {
        enable =
          lib.mkEnableOption "cglavin's neovim configuration"
          // {default = true;};
        configPath = lib.mkOption {
          type = lib.types.path;
          default = "${config.home.homeDirectory}/coding/nvim";
          description = ''
            Path to the writable git checkout of this repo (NOT a nix store
            path). vim.pack.add() writes nvim-pack-lock.json and clones
            plugins directly into stdpath('config'), so ~/.config/nvim is
            symlinked straight to this checkout rather than copied from the
            store.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;

          # home-manager's neovim module otherwise wants to own
          # ~/.config/nvim/init.lua itself (for provider/wrapper lua),
          # which collides with the whole-directory symlink below.
          # sideloadInitLua injects that lua via a wrapper flag instead
          # of writing a file, leaving init.lua entirely ours.
          sideloadInitLua = true;
        };

        home.packages = runtimeDeps pkgs;

        xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink cfg.configPath;
      };
    };
  in {
    homeModules.default = homeModule;

    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        packages = runtimeDeps pkgs;
      };
    });
  };
}

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

    # CLI tools the config's LSP/formatter/treesitter setup expects on $PATH.
    # Plugins themselves are NOT listed here: vim.pack.add() (see lua/) owns
    # plugin installation/pinning natively via nvim-pack-lock.json.
    runtimeDeps = pkgs:
      with pkgs; [
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

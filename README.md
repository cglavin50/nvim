# Nvim Config

Rewritten nvim config with 0.12 conventions, using OOB vim.pack (no lazy loading/optimizations).

Slowing porting my existing plugins over to mini.nvim as much as possible, as I like the tooling I've used so far and am a fan of existing within a single ecosystem.

## File Structure

- `lua/`
    - `config/`
        - Holds core (neo)vim configurations
        - Some plugins are managed here that are used WITH neovim native functionality (ex: Mason to configure LSPs)
    - `plugins/`
        - Holds general plugin configurations that don't cleanly fit into the above

## Usage

This repo is a plain git checkout consumed by two things:

1. **`vim.pack`** (native, built into Neovim 0.12+) installs/pins plugins by
   itself, writing `nvim-pack-lock.json` back into this checkout. Commit
   lockfile bumps like any other dependency change.
2. **Nix**, via `homeModules.default` in `flake.nix`, provisions the runtime
   toolchain (LSP servers, formatters, ripgrep/fd, etc.) and symlinks this
   checkout to `~/.config/nvim`. It does NOT vendor or pin plugins — that's
   `vim.pack`'s job — so a Lua/plugin change only needs `git pull`, never a
   Nix rebuild.

On any machine with home-manager (standalone or via NixOS/nix-darwin), clone
this repo to `~/coding/nvim` (or set `programs.nvim-cglavin.configPath`) and
add the module:

```nix
{
  inputs.nvim-cglavin.url = "github:cglavin50/nvim";
  # home-manager module list:
  #   inputs.nvim-cglavin.homeModules.default
}
```

This is a rather obtuse way of working with neovim (installing, and linking) - however this allows me to use my lua configuration OOB on my nixos machines, while allowing me to use and edit my configuration on my work laptop (macos).

### Bootstrapping a machine with no existing home-manager (e.g. a fresh macOS box)

Standalone home-manager needs no nix-darwin/NixOS:

```nix
# ~/.config/home-manager/flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-cglavin.url = "github:cglavin50/nvim";
  };

  outputs = {home-manager, nixpkgs, nvim-cglavin, ...}: {
    homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {system = "aarch64-darwin";};
      modules = [
        nvim-cglavin.homeModules.default
        {
          home.username = "cooper";
          home.homeDirectory = "/Users/cooper";
          home.stateVersion = "25.11";
          programs.home-manager.enable = true;
        }
      ];
    };
  };
}
```

then `git clone git@github.com:cglavin50/nvim.git ~/coding/nvim && nix run home-manager/master -- switch --flake ~/.config/home-manager`.

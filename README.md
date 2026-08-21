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

This config is wrapped in a nix flake so I can use it both on my personal machine (nixos), as well as any work devices (aka macos).

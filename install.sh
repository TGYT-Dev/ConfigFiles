#!/bin/bash
set -e

# Get the absolute path to this dotfiles repository
DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$HOME/.config"

echo "Setting up dotfiles from $DOTFILES_DIR"

mkdir -p "$CONFIG_DIR"

# Loop through all directories in this repo
for app in "$DOTFILES_DIR"/*; do
    # Only process directories (skip .git, README.md, install.sh, archive, etc.)
    if [ -d "$app" ] && [ "$(basename "$app")" != ".git" ] && [ "$(basename "$app")" != "archive" ]; then
        app_name="$(basename "$app")"
        echo "Installing $app_name config..."
        
        target="$CONFIG_DIR/$app_name"

        # Backup existing config if it's a real directory/file and NOT a symlink
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  Backing up existing $app_name config to ${target}.bak"
            rm -rf "${target}.bak"
            mv "$target" "${target}.bak"
        fi
        
        # Remove old symlink if it exists
        if [ -L "$target" ]; then
            rm "$target"
        fi

        # Create symlink pointing to the repo directory
        ln -sf "$app" "$target"
        echo "  Symlinked $app_name -> $app"
    fi
done

# Reload mako if it's running
if command -v makoctl >/dev/null 2>&1 && pgrep -x mako >/dev/null 2>&1; then
    echo "Reloading mako..."
    makoctl reload || true
fi

# Reload sway if we are in a sway session
if [ -n "$SWAYSOCK" ] && command -v swaymsg >/dev/null 2>&1; then
    echo "Reloading sway..."
    swaymsg reload || true
fi

echo "All configurations installed successfully!"

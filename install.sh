#!/usr/bin/env bash

#
# Khronos31 | install.sh
#

SCRIPT_PATH="$(realpath -P "$0")"
WORKDIR="$(dirname "$SCRIPT_PATH")"
cd "$WORKDIR"

timestamp="$(date +%Y%m%d_%H%M%S)"

dotfiles=(.bash_profile .bashrc .zshrc .commonrc .common_aliases .gitconfig)

for file in "${dotfiles[@]}"; do
  if [ -e "$HOME/$file" ]; then
    if [ -h "$HOME/$file" ]; then
      unlink "$HOME/$file"
    else
      mv "$HOME/$file" "$HOME/$file-$timestamp.old"
    fi
  fi
  if [ -f "$WORKDIR/$file" ]; then
    echo "$file" is symlink to "$WORKDIR/$file"
    ln -s "$WORKDIR/$file" "$HOME/$file"
  fi
done

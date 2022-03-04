#!/usr/bin/env bash

#
# Khronos31 | install.sh
#

timestamp="$(date +%Y%m%d_%H%M%S)"

dotfiles=(.bash_profile .bashrc .zshrc .commonrc .common_aliases .gitconfig)

for file in "${dotfiles[@]}"; do
  if [ -e "$HOME/$file" ]; then
    mv "$HOME/$file" "$HOME/$file-$timestamp.old"
  fi
  cp "$file" "$HOME/$file"
  chmod 644 "$HOME/$file"
done

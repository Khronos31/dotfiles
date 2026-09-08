#!/bin/sh

#
# Khronos31 | install.sh
#

# realpath(1) の -P は GNU coreutils 固有で、macOS/BSD の realpath には無い
# (usage: realpath [-q] [path ...])。失敗すると SCRIPT_PATH が空になり、
# WORKDIR が "." になって相対パスの壊れた symlink を張ってしまうため、
# シェル組み込みだけで解決する。
#
# このスクリプトは実行される前提（source されない）ため $0 でよい。
# BASH_SOURCE は bash 固有で、bash が無い環境（Alpine 等）で動かなくなる。
SCRIPT_PATH="$0"
while [ -h "$SCRIPT_PATH" ]; do
  link_dir="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  case "$SCRIPT_PATH" in
    /*) ;;
    *) SCRIPT_PATH="$link_dir/$SCRIPT_PATH" ;;
  esac
done
WORKDIR="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"

if [ ! -f "$WORKDIR/install.sh" ]; then
  echo "install.sh: スクリプトの位置を特定できませんでした: '$WORKDIR'" >&2
  exit 1
fi

cd "$WORKDIR" || exit 1

timestamp="$(date +%Y%m%d_%H%M%S)"

# 配列は bash 固有のため、位置パラメータで持つ。
# 空白区切りの変数を for に渡す方法は使えない。zsh は既定で単語分割しないため、
# zsh install.sh と叩かれたときに1要素として扱われ、黙って何もしなくなる。
set -- .profile .bash_profile .bashrc .zshenv .zshrc .shrc \
       .common_env .commonrc .common_aliases .gitconfig

for file in "$@"; do
  if [ -e "$HOME/$file" ] || [ -h "$HOME/$file" ]; then
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

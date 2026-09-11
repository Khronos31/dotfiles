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
set -- .profile .bash_profile .bashrc .zshenv .zprofile .zshrc .shrc \
       .common_env .commonrc .common_aliases .gitconfig

# 既存のリンクを外す道具を先に決める。
#
# unlink はリンクを1本消すだけで、-f も -r も持たない。判定を間違えたときに
# 被害が広がらないので優先する。ただし busybox には unlink applet が無い
# （OpenWrt 25.12.5 で実測。`busybox --list` に載っていない）。
# 無い環境では rm で落とすが、-f は付けない——存在は上で確かめているので、
# 消せなかったときは黙らせずに失敗させる。
if command -v unlink >/dev/null 2>&1; then
  remove_link() { unlink "$1"; }
else
  remove_link() { rm "$1"; }
fi

failed=0

for file in "$@"; do
  if [ -e "$HOME/$file" ] || [ -h "$HOME/$file" ]; then
    if [ -h "$HOME/$file" ]; then
      remove_link "$HOME/$file" || { failed=1; continue; }
    else
      mv "$HOME/$file" "$HOME/$file-$timestamp.old" || { failed=1; continue; }
    fi
  fi
  if [ -f "$WORKDIR/$file" ]; then
    # 張れたことを確認してから言う。先に表示すると、失敗しても成功したように
    # 見える。OpenWrt で unlink が無く ln が File exists で落ちたとき、
    # 10本すべてについて「symlink to ...」と表示しながら1本も張れていなかった。
    if ln -s "$WORKDIR/$file" "$HOME/$file"; then
      echo "$file" is symlink to "$WORKDIR/$file"
    else
      echo "install.sh: $file の symlink を張れませんでした" >&2
      failed=1
    fi
  fi
done

# 機械固有の設定は、追跡ファイルへの symlink ではなく $HOME の実ファイルに置く。
# 雛形が無いと「どこに何を書けるか」が読み取れないため、無い場合だけ作る。
#
# ⚠️ 既にある場合は中身を持っている。上書きも .old への退避もしない
#    （上の symlink 群と違い、ここには復元元が無い）。
for file in .common_env.local .commonrc.local .gitconfig.local; do
  if [ -e "$HOME/$file" ] || [ -h "$HOME/$file" ]; then
    echo "$file already exists; left untouched"
    continue
  fi
  case "$file" in
    .common_env.local)
      cat > "$HOME/$file" <<'EOF'
#
# この機械にしか無い事情を書く。git では追跡しない。
# .common_env の末尾から読まれる。
#
# コマンドの有無で判定できないもの — 「この機械にこれを入れた」という事実
# そのもの — を置く。path_prepend が使える。
#
# POSIX sh として読まれるため [[ ]] や配列は書けない。対話シェル向けの設定は
# .commonrc.local の担当。
#
# 例:
#   path_prepend "$HOME/.grok/bin"
#   export DISABLE_AUTOUPDATER=1
#
EOF
      ;;
    .commonrc.local)
      cat > "$HOME/$file" <<'EOF'
#
# この機械にしか無い対話用の設定を書く。git では追跡しない。
# .commonrc の末尾から読まれる。
#
# bash/zsh の構文が使えるので、補完の読み込みなど POSIX sh で書けないものを
# 置く。環境変数や PATH は .common_env.local の担当。
#
# 例:
#   [ -d /opt/homebrew ] && fpath+=(/opt/homebrew/share/zsh/site-functions)
#
EOF
      ;;
    .gitconfig.local)
      cat > "$HOME/$file" <<'EOF'
# この機械にしか無い git の設定を書く。git では追跡しない。
# .gitconfig の末尾から include される（後に読んだものが勝つ）。
#
# ~/.gitconfig は追跡ファイルへの symlink なので、そちらに書くと
# リポジトリ本体が汚れる。パスを含む設定は必ずこちらへ。
#
# 例:
#   [http]
#   	sslCAInfo = /var/jb/etc/ssl/certs/cacert.pem
#
#   [credential "https://github.com"]
#   	helper =
#   	helper = !/data/data/com.termux/files/usr/bin/gh auth git-credential
EOF
      ;;
  esac
  echo "$file created from template"
done

# 1本でも張れなかったら非ゼロで終わる。呼び出し側（デプロイスクリプト等）が
# 気づけるようにするため。表示だけで済ませると、今回の OpenWrt のように
# 「成功したように見えて何も張れていない」が通ってしまう。
exit "$failed"

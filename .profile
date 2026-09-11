#
# Khronos31 | .profile
#
# ログインシェルと、デスクトップセッション(GDM/Xsession等)が読む。
# /bin/sh で実行されるので POSIX の範囲で書く。
#
# bash は ~/.bash_profile がある場合このファイルを読まない。そのため
# 環境変数の本体は ~/.common_env に置き、.profile と .bash_profile の
# 両方からそれを読む形にしている。

[ -f ~/.common_env ] && . ~/.common_env

# dotfiles に新しいコミットが来ていれば知らせる（定義は .common_env）。
# bash のログインシェルは .bash_profile 経由でここを通るので、呼ぶのはここ1箇所でよい。
command -v dotfiles_update_check >/dev/null 2>&1 && dotfiles_update_check

# ash / dash / ksh は、対話シェルの初期化に $ENV が指すファイルを読む
# （bash の .bashrc、zsh の .zshrc に相当するものが無い）。Alpine のように
# ログインシェルが /bin/sh の環境で、対話層の設定を読ませるために指定する。
ENV="$HOME/.shrc"
export ENV

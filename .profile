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

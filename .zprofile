#
# Khronos31 | .zprofile
#
# zsh のログインシェルは ~/.zshenv を読んだ「後」に /etc/zprofile を読む。
# そこで PATH を export で丸ごと組み立て直す環境があり(macOS の path_helper、
# Procursus の /var/jb/etc/zprofile)、.zshenv で足した分が消える。
# 消された後にもう一度読み直して復旧させる。
#
# bash は /etc/profile → ~/.bash_profile の順なので、この問題は起きない。
# .common_env は冪等なので、二重に読んでも PATH は重複しない。

[ -f ~/.common_env ] && . ~/.common_env

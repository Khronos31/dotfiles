#
# Khronos31 | .zshenv
#
# zsh はログイン・対話・非対話を問わず必ずこれを読む。zsh 側で
# 環境変数を通す経路はここ一本でよい(.zshrc は対話専用)。

[ -f ~/.common_env ] && . ~/.common_env

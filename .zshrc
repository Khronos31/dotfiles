#
# Khronos31 | .zshrc
#

[[ $- != *i* ]] && return

[ -r ~/.commonrc ] && . ~/.commonrc

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000

[[ -v PATHEXT ]] &&
eval 'command_not_found_handler() {
  local ext
  for ext in ${=PATHEXT//;/ }; do
    if command -v "$1$ext" >/dev/null 2>&1; then
      "$1$ext" "${@:2}"
      return $?
    fi
  done
  {
    '"$(declare -f command_not_found_handler|head -n -1|tail -n +2)"'
  }
  printf "%s: command not found\n" "$1" 1>&2
  return 127
}'

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if command -v tput >/dev/null && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PROMPT='[%?] %B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b%# '
else
  PROMPT='[%?] %n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
update_terminal_title() {
  local cwd="${PWD/#"$HOME"/"~"}"
  printf '\e]0;%s\a' "$USER@$HOST:$cwd"
}
autoload -Uz add-zsh-hook
case "$TERM" in
  xterm*|rxvt*)
    case "$TERM_PROGRAM" in
      NewTerm|Apple_Terminal) ;;
      *) add-zsh-hook precmd update_terminal_title ;;
    esac
    ;;
  *) ;;
esac

[ -n "$clip_command" ] &&
eval "yy() {
  printf '%s' \"\$history[\$((HISTCMD-1))]\" |
    $clip_command
}"
unset clip_command

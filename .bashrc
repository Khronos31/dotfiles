#
# Khronos31 | .bashrc
#

[[ $- != *i* ]] && return

[ -f ~/.commonrc ] && . ~/.commonrc

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

HISTFILE="$HOME/.bash_history"
HISTSIZE=1000
HISTFILESIZE=1000

[[ -v PATHEXT ]] &&
eval 'command_not_found_handle() {
  local ext
  for ext in ${PATHEXT//;/ }; do
    if command -v "$1$ext" >/dev/null 2>&1; then
      "$1$ext" "${@:2}"
      return $?
    fi
  done
  '"$(declare -f command_not_found_handle|tail -n +2)"'
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
  PS1='[$?] \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='[$?] \u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    case "$TERM_PROGRAM" in
      NewTerm|Apple_Terminal) ;;
      *) PS1="\[\e]0;\u@\h:\w\a\]$PS1";;
    esac
    ;;
  *) ;;
esac

[ -n "$clip_command" ] &&
eval "yy() {
  local hist=\"\$(fc -ln -1)\"
  printf '%s' \"\${hist:2}\" |
    $clip_command
}"
unset clip_command

if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

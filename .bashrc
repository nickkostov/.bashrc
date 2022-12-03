#!/bin/bash env

source .bash_aliases
source ./installs/installs.sh

case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth

shopt -s histappend

HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac


if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

FMT_BOLD="\e[1m"
FMT_RESET="\e[0m"
FMT_UNBOLD="\e[21m"
FG_BLACK="\e[36m"
FG_BLUE="\e[34m"
FG_CYAN="\e[36m"
FG_GREEN="\e[32m"
FG_MAGENTA="\e[35m"
FG_RED="\e[31m"
FG_WHITE="\e[97m"
BG_BLUE="\e[44m"
BG_GREEN="\e[42m"
BG_MAGENTA="\e[45m"
function __short_wd_cygwin() 
{
    num_dirs=3
    newPWD="${PWD/#$HOME/~}"
    if [ $(echo -n $newPWD | awk -F '/' '{print NF}') -gt $num_dirs ]; then
        newPWD=$(echo -n "$newPWD" | awk -F '/' '{print $1 "/.../" $(NF-1) "/" $(NF)}')
    fi
    echo -n "$newPWD"
}
function __short_wd_cygpath() 
{
    num_dirs=3
    newPWD=$(cygpath -C ANSI -w ${PWD/#$HOME/~})
    if [ $(echo -n $newPWD | awk -F '\\' '{print NF}') -gt $num_dirs ]; then
        newPWD=$(echo -n $newPWD | awk -F '\\' '{print $1 "\\...\\" $(NF-1) "\\" $(NF)}')
    fi
    echo -n $newPWD
}
FMT_RESET="\[\e[0m\]"
FMT_UNBOLD="\[\e[22m\]"
FG_BLACK="\[\e[30m\]"
FG_BLUE="\[\e[34m\]"
FG_CYAN="\[\e[36m\]"
FG_GREEN="\[\e[32m\]"
FG_GREY="\[\e[37m\]"
FG_MAGENTA="\[\e[35m\]"
FG_WHITE="\[\e[97m\]"
BG_BLUE="\[\e[44m\]"
BG_CYAN="\[\e[46m\]"
BG_GREEN="\[\e[42m\]"
BG_MAGENTA="\[\e[45m\]"
export PS1=\
"\n${FG_BLUE}╭─${FG_MAGENTA}◀${BG_MAGENTA}${FG_CYAN}${FMT_BOLD}\d ${FG_WHITE}\t${FMT_UNBOLD} ${FG_MAGENTA}${BG_BLUE}▶ "\
"${FG_GREY}\$(__short_wd_cygwin) ${FG_BLUE}${BG_CYAN}▶ "\
"${FG_BLACK}📂 \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) "\
"📄 \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l) "\
"🔗 \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l) "\
"${FMT_RESET}${FG_CYAN}"\
"\$(git branch 2> /dev/null | grep '^*' | colrm 1 2 | xargs -I BRANCH echo -n \"${BG_GREEN}▶${FG_BLACK}🔀 BRANCH ${FMT_RESET}${FG_GREEN}\")"\
"\n${FG_BLUE}╰▶${FG_CYAN}🚀 ${FMT_RESET}"
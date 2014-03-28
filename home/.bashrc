# Check for an interactive session
[ -z "$PS1" ] && return

# Prompt
#PS1='[\u@\h \W]\$ '
#PS1='\[\e[1m\]┌─[\u@\h][\W]\n\[\e[1m\]└─[\$]\[\e[0m\] '
#PS1='┌─[\u]-[\w]\n└─[\$] '
PS1='\[\e[0;31m\]┌─[\u]-[\w]\n\[\e[0;31m\]└─[\$]\[\e[0m\] '

# Vim keybindings
set -o vi

# Colors for ls
alias ls='ls --color=auto'
eval `dircolors -b`

# Colors for grep
export GREP_COLOR="1;32"
alias grep='grep --color=auto'

# Colors for man
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'

alias gksu='gksu-polkit'

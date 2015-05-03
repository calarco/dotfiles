#! /bin/sh

source $HOME/.homesick/repos/homeshick/homeshick.sh

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
setopt HIST_IGNORE_DUPS

export EDITOR=vim
bindkey -v

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       history-beginning-search-backward
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     history-beginning-search-forward
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

zstyle ':completion:*' menu select
zstyle :compinstall filename '/home/calarco/.zshrc'

autoload -Uz compinit
compinit

autoload -U promptinit
promptinit

vim_ins_mode="%F{black}%K{yellow} INSERT%F{yellow}'"
vim_cmd_mode="%F{black}%K{white} COMMND%F{white}'"
vim_mode=$vim_ins_mode

last="%(?,%F{green}"$'\ue0b2'"%F{black}%K{green} ✔ %K{green},%F{red}"$'\ue0b2'"%F{white}%K{red} ✘ %K{red})"

# Fix a bug when you C-c in CMD mode and you'd be prompted with CMD mode indicator, while in fact you would be in INS mode
# Fixed by catching SIGINT (C-c), set vim_mode to INS and then repropagate the SIGINT, so if anything else depends on it, we will not break it
function TRAPINT() {
	vim_mode=$vim_ins_mode
	return $(( 128 + $1 ))
}

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init zle-keymap-select {
		printf '%s' "${terminfo[smkx]}"
		vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
		PROMPT=$vim_mode"%K{blue}"$'\ue0b0'\
"%F{white}%K{blue} %n %F{blue}%K{magenta}"$'\ue0b0'\
"%F{white}%K{magenta} %~ %F{magenta}%k"$'\ue0b0'"%f "
		RPROMPT=$last\
"%F{white}"$'\ue0b2'"%F{black}%K{white} %T %K{white}"
		zle reset-prompt
	}
	function zle-line-finish {
		printf '%s' "${terminfo[rmkx]}"
		vim_mode=$vim_ins_mode
	}
fi
zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-finish

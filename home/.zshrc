export EDITOR=vim
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=/usr/lib/jvm/default

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original false
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %l%s
zstyle ':completion:*' squeeze-slashes true
zstyle :compinstall filename '/home/sebastian/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
unsetopt notify
bindkey -e
# End of lines configured by zsh-newuser-install

# Extra plugins {{{

autoload -U add-zsh-hook

## Smarter help and a bash-like help function
unalias run-help 2>/dev/null
autoload run-help
alias help='run-help'

## autocompletion for vlc based on --help
compdef _gnu_generic vlc

## Magic quoting in URLs to save me from typing quoted strings
autoload -U url-quote-magic
autoload -Uz bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic


## Fish shell like syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_HIGHLIGHT_STYLES[comment]='none'

# }}}

# zshoptions {{{

setopt TRANSIENT_RPROMPT
setopt print_exit_value
setopt COMPLETE_IN_WORD
setopt INTERACTIVE_COMMENTS

## History control
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory extendedglob
setopt HIST_IGNORE_DUPS

# }}}

# Call rehash after any pacman/yay operation. A behaviour more accurate could
# be achieved through `zstyle ':completion:*' rehash true`. {{{

TRAPUSR1() { rehash }

rehash_precmd() {
  [[ $history[$[ HISTCMD -1 ]] == *(pacman|yay)* ]] && killall -USR1 zsh
}

add-zsh-hook precmd rehash_precmd

# }}}

# Zsh normally leaves the stty intr setting alone and handles the INT
# signal.  Which means that when you type ^C, you're sending a signal
# to the tty process group, not a normal keystroke to the shell input.
# This has some helpful side-effects for process management, but means
# the the line editor exits.
#
# In order to behave the way you want, you have to trap the INT signal
# and print the ^C yourself: {{{

## will be redefined later
updatemyprompt() { }

local _trapped='no'
TRAPINT() {
  print -n -u2 '^C'

  _trapped='yes'
  updatemyprompt

  return $((128+$1))
}

# }}}

# Key bindings {{{

## Native keys

### Tab
bindkey "^I" expand-or-complete-prefix

### Alt + F
bindkey "^[f" emacs-forward-word

### Ctrl + U
bindkey "^U" backward-kill-line

### Ctrl + W

bindkey "^w" kill-region

### Ctrl + G

bindkey "^g" deactivate-region

## Extended keys

function () {
	typeset -A key

	### Shift+Tab isn't available in the zkbd map
	key[Shift+Tab]="^[	"

	if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
		### If application mode/terminfo is available
		function zle-line-init () {
			echoti smkx
		}
		function zle-line-finish () {
			echoti rmkx
		}
		zle -N zle-line-init
		zle -N zle-line-finish

		### List of desired keys
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

		key[Shift+Tab]=${terminfo[kcbt]}
	else
		### Fallback to manually managed user-driven database
		printf 'Failed to setup keys using terminfo (application mode unsuported).\n'
		printf 'Jumping to zkbd fallback.\n'

		autoload zkbd
		function zkbd_file() {
			[[ -f ~/.zkbd/${TERM}-${VENDOR}-${OSTYPE} ]] && printf '%s' ~/".zkbd/${TERM}-${VENDOR}-${OSTYPE}" && return 0
			[[ -f ~/.zkbd/${TERM}-${DISPLAY}		  ]] && printf '%s' ~/".zkbd/${TERM}-${DISPLAY}"		  && return 0
			return 1
		}

		[[ ! -d ~/.zkbd ]] && mkdir ~/.zkbd
		keyfile=$(zkbd_file)
		ret=$?
		if [[ ${ret} -ne 0 ]]; then
			zkbd
			keyfile=$(zkbd_file)
			ret=$?
		fi
		if [[ ${ret} -eq 0 ]] ; then
			source "${keyfile}"
		else
			printf 'Failed to setup keys using zkbd.\n'
		fi
		unfunction zkbd_file; unset keyfile ret
	fi

	### Setup keys accordingly

	[[ -n "${key[Home]}"	 ]]  && bindkey  "${key[Home]}"		beginning-of-line
	[[ -n "${key[End]}"		 ]]  && bindkey  "${key[End]}"		end-of-line
	[[ -n "${key[Insert]}"	 ]]  && bindkey  "${key[Insert]}"	overwrite-mode
	[[ -n "${key[Delete]}"	 ]]  && bindkey  "${key[Delete]}"	delete-char
	[[ -n "${key[Up]}"		 ]]  && bindkey  "${key[Up]}"		history-beginning-search-backward
	[[ -n "${key[Down]}"	 ]]  && bindkey  "${key[Down]}"		history-beginning-search-forward
	[[ -n "${key[Left]}"	 ]]  && bindkey  "${key[Left]}"		backward-char
	[[ -n "${key[Right]}"	 ]]  && bindkey  "${key[Right]}"	forward-char
	[[ -n "${key[PageUp]}"	 ]]  && bindkey  "${key[PageUp]}"	beginning-of-buffer-or-history
	[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

	### Shift+Tab on completion list
	zmodload zsh/complist
	bindkey -M menuselect "${key[Shift+Tab]}" reverse-menu-complete
}

# }}}

# Aliases {{{

alias ls='ls --color=auto'
alias cgrep='grep --color=always -I'
alias grep='grep --color=auto -I'
alias less='less -Ri'

# }}}

# Prompt {{{

autoload -U colors && colors

setopt prompt_subst

autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git

## %n: username
## %m: hostname
## %~: working dir
## %?: last command's exit status

updatemyprompt() {
  # vcs_info_msg_0_ var {{{
  vcs_info
  # }}}

  # Last command status {{{
  local _PROMPT_CHAR=""
  local _DOLLAR='%(!.#.$)'

  if [ x"$_trapped" = x"yes" ]; then
	_PROMPT_CHAR="${_DOLLAR}"
  else
	_PROMPT_CHAR="%(?::%{$bg[red]%})${_DOLLAR}%{$reset_color%}"
  fi
  # }}}

  PROMPT='%{$fg[cyan]%}%(!:%{$bg[red]%}:)%n%(!:%{%k%}:)'
  if [[ ! -z $SSH_TTY ]]; then
	PROMPT="${PROMPT}"' @ %m'
  fi
  PROMPT="${PROMPT}"' %{$fg[magenta]%}%~ %{$reset_color%}'"${_PROMPT_CHAR}"' '
}

add-zsh-hook precmd updatemyprompt

function () {
  # Functions are NOT really local, but I keep this style anyway
  updatemyprompt_preexec() { _trapped='no' }
  add-zsh-hook preexec updatemyprompt_preexec
}

RPROMPT='%{$fg[yellow]%}${vcs_info_msg_0_}%{$reset_color%}'

# }}}

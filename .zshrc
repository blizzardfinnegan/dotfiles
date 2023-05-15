source $HOME/.config/zsh/zsh-autosuggestions.zsh
source $HOME/.config/zsh/extract.zsh
source $HOME/.config/zsh/paradox.zsh

setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt correct_all
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt share_history
setopt prompt_subst

function is-true { 
	[[ -n "$1" && "$1" == (1|[Yy]([Ee][Ss]|)|[Tt]([Rr][Uu][Ee]|)|[Oo]([Nn]|)) ]]
}

function prompt-pwd {
	setopt localoptions extendedglob
	#local current_pwd="${PWD/#$HOME/~}"
	#local ret_directory
	#if [["$current_pwd" == (#m)[/~] ]]; then
	#	ret_directory="$PWD"
	#else
  		ret_directory="${${${${(@j:/:M)${(@s:/:)current_pwd}##.#?}:h}%/}//\%/%%}/${${current_pwd:t}//\%/%%}"
	#fi
	#ret_directory="$PWD"
	#unset current_pwd

	print ""
}
# store colors
MAGENTA="\[\033[0;35m\]"
YELLOW="\[\033[01;33m\]"
BLUE="\[\033[00;34m\]"
LIGHT_GRAY="\[\033[0;37m\]"
CYAN="\[\033[0;36m\]"
GREEN="\[\033[00;32m\]"
RED="\[\033[0;31m\]"
VIOLET='\[\033[01;35m\]'
 
function color_my_prompt {
  local __user_and_host="$GREEN\u@\h"
  local __cur_location="$BLUE\W"           # capital 'W': current directory, small 'w': full file path
  local __git_branch_color="$GREEN"
  local __prompt_tail="$VIOLET$"
  local __user_input_color="$GREEN"
  local __git_branch=$(__git_ps1); 
  
  # colour branch name depending on state
  if [[ "${__git_branch}" =~ "*" ]]; then     # if repository is dirty
      __git_branch_color="$RED"
  elif [[ "${__git_branch}" =~ "$" ]]; then   # if there is something stashed
      __git_branch_color="$YELLOW"
  elif [[ "${__git_branch}" =~ "%" ]]; then   # if there are only untracked files
      __git_branch_color="$LIGHT_GRAY"
  elif [[ "${__git_branch}" =~ "+" ]]; then   # if there are staged files
      __git_branch_color="$CYAN"
  fi
   
  # Build the PS1 (Prompt String)
  PS1="$__user_and_host $__cur_location$__git_branch_color$__git_branch $__prompt_tail$__user_input_color "
}
 
# configure PROMPT_COMMAND which is executed each time before PS1
export PROMPT_COMMAND=color_my_prompt
 
# if .git-prompt.sh exists, set options and execute it
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_HIDE_IF_PWD_IGNORED=true
GIT_PS1_SHOWCOLORHINTS=true
. ~/.config/zsh/git-prompt.zsh
precmd_funtions+=prompt-pwd

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

export LANG=en_IE.UTF-8
export EDITOR="nvim"

alias history="fc -t '%d-%m-%Y' -l 1"
alias l="exa -lah"
alias zshconfig="nvim ~/.zshrc"

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye > /dev/null

